#if defined(WEBRTC_LINUX)

#include <sys/types.h>
#include <unistd.h>

#include <algorithm>
#include <cstdlib>
#include <cstring>
#include <string_view>
#include <vector>

#include <pipewire/pipewire.h>
#include <spa/param/audio/format-utils.h>
#include <spa/utils/dict.h>
#include <spa/utils/result.h>
#include <spa/utils/ringbuffer.h>

#include "rtc_base/logging.h"
#include "libwebrtc-sys/include/sys_audio_capture/linux_capture.h"

const struct pw_stream_events kCaptureStreamEvents = {
    .version       = PW_VERSION_STREAM_EVENTS,
    .state_changed = SysAudioSource::OnCaptureStreamStateChanged,
    .param_changed = SysAudioSource::OnCaptureStreamParamChanged,
    .process       = SysAudioSource::OnCaptureStreamProcess,
};

const struct pw_proxy_events kSinkProxyEvents = {
    .version = PW_VERSION_PROXY_EVENTS,
    .bound   = SysAudioSource::OnSinkProxyBound,
    .destroy = SysAudioSource::OnSinkProxyDestroy,
};

const struct pw_registry_events kRegistryEvents = {
    .version       = PW_VERSION_REGISTRY_EVENTS,
    .global        = SysAudioSource::OnRegistryGlobal,
    .global_remove = SysAudioSource::OnRegistryGlobalRemove,
};

SysAudioSource::SysAudioSource() {
  part_buffer_.resize(kRecordingPartSamples);
  source_ = bridge::LocalAudioSource::Create(webrtc::AudioOptions(), nullptr);
}

SysAudioSource::~SysAudioSource() {
  StopCapture();
}

bool SysAudioSource::StartCapture() {
  std::lock_guard<std::recursive_mutex> lock(mutex_);
  if (recording_) {
    return false;
  }

  pw_init(nullptr, nullptr);

  pw_loop_ = pw_main_loop_new(nullptr);
  if (!pw_loop_) {
    RTC_LOG(LS_ERROR) << "`SysAudioSource`: `pw_main_loop_new` failed";
    return false;
  }

  pw_ctx_ = pw_context_new(pw_main_loop_get_loop(pw_loop_), nullptr, 0);
  if (!pw_ctx_) {
    RTC_LOG(LS_ERROR) << "`SysAudioSource`: `pw_context_new` failed";
    pw_main_loop_destroy(pw_loop_);
    pw_loop_ = nullptr;
    return false;
  }

  pw_core_ = pw_context_connect(pw_ctx_, nullptr, 0);
  if (!pw_core_) {
    RTC_LOG(LS_ERROR) << "`SysAudioSource`: `pw_context_connect` failed";
    pw_context_destroy(pw_ctx_);
    pw_ctx_ = nullptr;
    pw_main_loop_destroy(pw_loop_);
    pw_loop_ = nullptr;
    return false;
  }

  pw_registry_ = pw_core_get_registry(pw_core_, PW_VERSION_REGISTRY, 0);
  if (!pw_registry_) {
    RTC_LOG(LS_ERROR) << "`SysAudioSource`: `pw_core_get_registry` failed";
    pw_core_disconnect(pw_core_);
    pw_core_ = nullptr;
    pw_context_destroy(pw_ctx_);
    pw_ctx_ = nullptr;
    pw_main_loop_destroy(pw_loop_);
    pw_loop_ = nullptr;
    return false;
  }

  pw_registry_add_listener(pw_registry_, &registry_listener_,
                           &kRegistryEvents, this);

  CreateVirtualSink();
  if (!sink_proxy_) {
    RTC_LOG(LS_ERROR) << "`SysAudioSource`: `CreateVirtualSink` failed";
    pw_proxy_destroy(reinterpret_cast<struct pw_proxy*>(pw_registry_));
    pw_registry_ = nullptr;
    pw_core_disconnect(pw_core_);
    pw_core_ = nullptr;
    pw_context_destroy(pw_ctx_);
    pw_ctx_ = nullptr;
    pw_main_loop_destroy(pw_loop_);
    pw_loop_ = nullptr;
    return false;
  }

  recording_ = true;
  capture_fifo_.size = static_cast<uint32_t>(kRecordingFrequency *
                                             kRecordingChannels *
                                             2);
  capture_fifo_.buffer.resize(capture_fifo_.size);
  spa_ringbuffer_init(&capture_fifo_.ring);
  pw_thread_ = std::thread([this]() { pw_main_loop_run(pw_loop_); });
  return true;
}

void SysAudioSource::StopCapture() {
  {
    std::lock_guard<std::recursive_mutex> lock(mutex_);
    if (!recording_) {
      return;
    }
    recording_ = false;
  }

  if (pw_loop_) {
    pw_main_loop_quit(pw_loop_);
  }
  if (pw_thread_.joinable()) {
    pw_thread_.join();
  }

  if (capture_stream_.stream) {
      if (pw_stream_get_state(capture_stream_.stream, nullptr) !=
          PW_STREAM_STATE_UNCONNECTED) {
        pw_stream_disconnect(capture_stream_.stream);
      }
      spa_hook_remove(&capture_stream_.listener);
      pw_stream_destroy(capture_stream_.stream);
      capture_stream_.stream = nullptr;
      capture_stream_.format_valid = false;
  }

  for (auto& [node_id, proxies] : link_proxies_by_node_) {
    for (struct pw_proxy* link : proxies) {
      if (link) {
        pw_proxy_destroy(link);
      }
    }
  }
  link_proxies_by_node_.clear();

  if (sink_proxy_) {
    spa_hook_remove(&sink_proxy_listener_);
    pw_proxy_destroy(sink_proxy_);
    sink_proxy_ = nullptr;
    sink_id_ = SPA_ID_INVALID;
    sink_serial_.clear();
    sink_input_ports_.clear();
  }

  target_nodes_.clear();

  if (pw_registry_) {
    spa_hook_remove(&registry_listener_);
    pw_proxy_destroy(reinterpret_cast<struct pw_proxy*>(pw_registry_));
    pw_registry_ = nullptr;
  }
  if (pw_core_) {
    pw_core_disconnect(pw_core_);
    pw_core_ = nullptr;
  }
  if (pw_ctx_) {
    pw_context_destroy(pw_ctx_);
    pw_ctx_ = nullptr;
  }
  if (pw_loop_) {
    pw_main_loop_destroy(pw_loop_);
    pw_loop_ = nullptr;
  }
  spa_ringbuffer_init(&capture_fifo_.ring);
}

bool SysAudioSource::ProcessRecordedPart(bool /*firstInCycle*/) {
  {
    std::lock_guard<std::recursive_mutex> lock(mutex_);
    if (!recording_) {
      return false;
    }
  }

  AudioFifo* fifo = &capture_fifo_;
  if (fifo->size == 0) {
    return false;
  }

  uint32_t read_index = 0;
  int32_t available =
      spa_ringbuffer_get_read_index(&fifo->ring, &read_index);
  if (available <= 0 || available < kRecordingPartSamplesBytes) {
    return false;
  }

  spa_ringbuffer_read_data(
      &fifo->ring,
      fifo->buffer.data(), fifo->size,
      read_index % fifo->size,
      part_buffer_.data(), kRecordingPartSamplesBytes);
  spa_ringbuffer_read_update(&fifo->ring,
                             static_cast<int32_t>(read_index + kRecordingPartSamplesBytes));

  source_->OnData(part_buffer_.data(),
                  kBitsPerSample,
                  kRecordingFrequency,
                  kRecordingChannels,
                  kRecordingPart);
  return true;
}

webrtc::scoped_refptr<bridge::LocalAudioSource> SysAudioSource::GetSource() {
  return source_;
}

void SysAudioSource::CreateVirtualSink() {
  struct pw_properties* props = pw_properties_new(
      PW_KEY_FACTORY_NAME, "support.null-audio-sink",
      PW_KEY_MEDIA_CLASS, "Stream/Input/Audio",
      PW_KEY_NODE_VIRTUAL, "true",
      SPA_KEY_AUDIO_POSITION, kRecordingChannels == 1 ? "FL" : "FL,FR",
      nullptr);
  if (!props) {
    return;
  }
  pw_properties_setf(props, PW_KEY_NODE_NAME, "medea-sysaudio-mix");
  pw_properties_setf(props, PW_KEY_AUDIO_CHANNELS, "%u",
                     static_cast<unsigned>(kRecordingChannels));

  sink_proxy_ = reinterpret_cast<struct pw_proxy*>(pw_core_create_object(
      pw_core_, "adapter", PW_TYPE_INTERFACE_Node, PW_VERSION_NODE,
      &props->dict, 0));
  pw_properties_free(props);
  if (!sink_proxy_) {
    return;
  }

  sink_id_ = SPA_ID_INVALID;
  sink_serial_.clear();
  sink_input_ports_.clear();

  pw_proxy_add_listener(sink_proxy_, &sink_proxy_listener_,
                        &kSinkProxyEvents, this);
}

void SysAudioSource::OnSinkReady() {
  if (capture_stream_.stream) {
    return;
  }
  if (sink_serial_.empty() ||
      sink_input_ports_.size() != static_cast<size_t>(kRecordingChannels)) {
    return;
  }

  struct pw_properties* props =
      pw_properties_new(PW_KEY_TARGET_OBJECT, sink_serial_.c_str(), nullptr);
  if (!props) {
    RTC_LOG(LS_ERROR) << "`SysAudioSource`: `pw_properties_new` failed";
    return;
  }

  capture_stream_.parent = this;
  capture_stream_.stream =
      pw_stream_new(pw_core_, "medea-sys-audio-capture", props);
  if (!capture_stream_.stream) {
    RTC_LOG(LS_ERROR) << "`SysAudioSource`: `pw_stream_new` failed";
    return;
  }

  pw_stream_add_listener(capture_stream_.stream, &capture_stream_.listener,
                          &kCaptureStreamEvents, &capture_stream_);

  uint8_t pod_buf[512];
  struct spa_pod_builder pod_builder =
      SPA_POD_BUILDER_INIT(pod_buf, sizeof(pod_buf));

  struct spa_audio_info_raw info;
  spa_zero(info);
  info.format = SPA_AUDIO_FORMAT_S16;
  info.rate = kRecordingFrequency;
  info.channels = kRecordingChannels;

  const struct spa_pod* params[1];
  params[0] = spa_format_audio_raw_build(&pod_builder, SPA_PARAM_EnumFormat,
                                         &info);

  // Connect capture stream to sink
  int res = pw_stream_connect(
      capture_stream_.stream,
      PW_DIRECTION_INPUT,
      PW_ID_ANY,
      static_cast<enum pw_stream_flags>(PW_STREAM_FLAG_AUTOCONNECT |
                                        PW_STREAM_FLAG_MAP_BUFFERS),
      params, 1);

  if (res < 0) {
    RTC_LOG(LS_ERROR) << "`SysAudioSource`: `pw_stream_connect` failed: "
                      << spa_strerror(res);
    spa_hook_remove(&capture_stream_.listener);
    pw_stream_destroy(capture_stream_.stream);
    capture_stream_.stream = nullptr;
    return;
  }

  for (const auto& [node_id, node] : target_nodes_) {
    LinkTargetNodeToSink(node_id);
  }
}

void SysAudioSource::LinkPortToSink(uint32_t output_node_id,
                                    uint32_t output_port_id,
                                    const std::string& port_channel) {
  uint32_t input_port_id = 0;
  if (!sink_input_ports_.empty()) {
    if (kRecordingChannels == 1) {
      input_port_id = sink_input_ports_[0].id;
    } else {
      for (const auto& p : sink_input_ports_) {
        if (p.channel == port_channel) {
          input_port_id = p.id;
          break;
        }
      }
      if (input_port_id == 0) {
        input_port_id = sink_input_ports_[0].id;
      }
    }
  }
  if (input_port_id == 0) {
    return;
  }

  struct pw_properties* link_props =
      pw_properties_new(PW_KEY_OBJECT_LINGER, "false", nullptr);
  if (!link_props) {
    return;
  }
  pw_properties_setf(link_props, PW_KEY_LINK_OUTPUT_NODE, "%u", output_node_id);
  pw_properties_setf(link_props, PW_KEY_LINK_OUTPUT_PORT, "%u", output_port_id);
  pw_properties_setf(link_props, PW_KEY_LINK_INPUT_NODE, "%u", sink_id_);
  pw_properties_setf(link_props, PW_KEY_LINK_INPUT_PORT, "%u", input_port_id);

  struct pw_proxy* link_proxy = reinterpret_cast<struct pw_proxy*>(
      pw_core_create_object(pw_core_, "link-factory", PW_TYPE_INTERFACE_Link,
                            PW_VERSION_LINK, &link_props->dict, 0));

  pw_properties_free(link_props);
  if (link_proxy) {
    link_proxies_by_node_[output_node_id].push_back(link_proxy);
  } else {
    RTC_LOG(LS_ERROR)
        << "SysAudioSource: pw_core_create_object(link-factory) failed";
  }
}

void SysAudioSource::LinkTargetNodeToSink(uint32_t node_id) {
  auto it = target_nodes_.find(node_id);
  if (it == target_nodes_.end()) {
    return;
  }
  const TargetNode& node = it->second;
  for (const auto& port : node.output_ports) {
    LinkPortToSink(node_id, port.id, port.channel);
  }
}

void SysAudioSource::OnSinkProxyBound(void* data, uint32_t global_id) {
  auto* self = static_cast<SysAudioSource*>(data);

  self->sink_id_ = global_id;
}

void SysAudioSource::OnSinkProxyDestroy(void* data) {
  auto* self = static_cast<SysAudioSource*>(data);

  spa_hook_remove(&self->sink_proxy_listener_);
  self->sink_proxy_ = nullptr;
  self->sink_id_ = SPA_ID_INVALID;
  self->sink_serial_.clear();
  self->sink_input_ports_.clear();
}

void SysAudioSource::OnCaptureStreamStateChanged(void* data,
                                                 pw_stream_state /*old_state*/,
                                                 pw_stream_state new_state,
                                                 const char* error) {
  auto* cs = static_cast<CaptureStream*>(data);

  RTC_LOG(LS_INFO) << "`SysAudioSource`: capture stream state -> "
                      << pw_stream_state_as_string(new_state);
  if (new_state == PW_STREAM_STATE_ERROR && error) {
    RTC_LOG(LS_ERROR) << "`SysAudioSource`: capture stream error: " << error;
  }
}

void SysAudioSource::OnCaptureStreamParamChanged(void* data,
                                                uint32_t id,
                                                const spa_pod* param) {
  auto* cs = static_cast<CaptureStream*>(data);

  if (id != SPA_PARAM_Format || !param) {
    return;
  }
  struct spa_audio_info info;
  spa_zero(info);
  if (spa_format_parse(param, &info.media_type, &info.media_subtype) < 0) {
    return;
  }
  if (info.media_type != SPA_MEDIA_TYPE_audio ||
      info.media_subtype != SPA_MEDIA_SUBTYPE_raw) {
    return;
  }
  if (spa_format_audio_raw_parse(param, &info.info.raw) < 0) {
    return;
  }
  cs->format = info.info.raw;
  cs->format_valid = true;
}

void SysAudioSource::OnCaptureStreamProcess(void* data) {
  auto* cs = static_cast<CaptureStream*>(data);
  SysAudioSource* self = cs->parent;

  struct pw_buffer* pw_buf = pw_stream_dequeue_buffer(cs->stream);
  if (!pw_buf) {
    return;
  }

  if (!cs->format_valid) {
    pw_stream_queue_buffer(cs->stream, pw_buf);
    return;
  }

  AudioFifo* fifo = &self->capture_fifo_;
  if (fifo->size == 0) {
    pw_stream_queue_buffer(cs->stream, pw_buf);
    return;
  }

  struct spa_buffer* spa_buf = pw_buf->buffer;
  for (uint32_t i = 0; i < spa_buf->n_datas; ++i) {
    const struct spa_data& d = spa_buf->datas[i];
    if (!d.data || !d.chunk || d.chunk->size == 0) {
      continue;
    }
    const uint8_t* src =
        static_cast<const uint8_t*>(d.data) + d.chunk->offset;
    uint32_t n_bytes = d.chunk->size;

    uint32_t write_index = 0;
    int32_t fill =
        spa_ringbuffer_get_write_index(&fifo->ring, &write_index);
    uint32_t available_write = (fill < 0)
                                   ? fifo->size
                                   : (fifo->size - static_cast<uint32_t>(fill));

    if (available_write < n_bytes) {
      uint32_t read_index = 0;
      spa_ringbuffer_get_read_index(&fifo->ring, &read_index);
      uint32_t drop = n_bytes - available_write;
      spa_ringbuffer_read_update(
          &fifo->ring,
          static_cast<int32_t>(read_index + drop));
      available_write = n_bytes;
    }

    if (available_write >= n_bytes) {
      spa_ringbuffer_write_data(
          &fifo->ring,
          fifo->buffer.data(), fifo->size,
          write_index % fifo->size,
          src, n_bytes);
      spa_ringbuffer_write_update(&fifo->ring,
                                  static_cast<int32_t>(write_index + n_bytes));
    }
  }

  pw_stream_queue_buffer(cs->stream, pw_buf);
}

void SysAudioSource::OnRegistryGlobal(void* data,
                                      uint32_t id,
                                      uint32_t permissions,
                                      const char* type,
                                      uint32_t version,
                                      const struct spa_dict* props) {
  auto* self = static_cast<SysAudioSource*>(data);

  if (!props || !type) {
    return;
  }

  if (std::string_view(type) == PW_TYPE_INTERFACE_Client) {
    struct pw_properties* p = pw_properties_new_dict(props);
    if (p) {
      int32_t client_pid = 0;
      if (pw_properties_fetch_int32(p, PW_KEY_SEC_PID, &client_pid) == 0 &&
          client_pid == getpid()) {
        self->our_client_ids_.insert(id);
      }
      pw_properties_free(p);
    }
    return;
  }

  if (std::string_view(type) == PW_TYPE_INTERFACE_Port) {
    const char* nid = spa_dict_lookup(props, PW_KEY_NODE_ID);
    const char* dir = spa_dict_lookup(props, PW_KEY_PORT_DIRECTION);
    const char* chn = spa_dict_lookup(props, PW_KEY_AUDIO_CHANNEL);

    if (!nid || !dir || !chn) {
      return;
    }

    uint32_t node_id = std::strtoul(nid, nullptr, 10);
    if (std::string_view(dir) == "in" && node_id == self->sink_id_) {
      self->sink_input_ports_.push_back({std::string(chn), id});
      self->OnSinkReady();
    } else if (std::string_view(dir) == "out") {
      auto it = self->target_nodes_.find(node_id);
      if (it != self->target_nodes_.end()) {
        it->second.output_ports.push_back({std::string(chn), id});
        self->LinkPortToSink(node_id, id, chn);
      }
    }

    return;
  }

  if (std::string_view(type) == PW_TYPE_INTERFACE_Node) {
    const char* serial_str = spa_dict_lookup(props, PW_KEY_OBJECT_SERIAL);
    if (self->sink_id_ != SPA_ID_INVALID &&
        id == self->sink_id_ && serial_str) {
      self->sink_serial_ = serial_str;
      self->OnSinkReady();
    }

    const char* media_class = spa_dict_lookup(props, PW_KEY_MEDIA_CLASS);
    if (!media_class ||
        std::string_view(media_class) != "Stream/Output/Audio") {
      return;
    }

    const char* client_id_str = spa_dict_lookup(props, PW_KEY_CLIENT_ID);
    if (client_id_str) {
      uint32_t client_id = std::strtoul(client_id_str, nullptr, 10);
      if (self->our_client_ids_.contains(client_id)) {
        return;
      }
    }

    self->target_nodes_[id].id = id;
    if (!self->sink_serial_.empty() &&
        self->sink_input_ports_.size() ==
            static_cast<size_t>(kRecordingChannels)) {
      self->LinkTargetNodeToSink(id);
    }
  }
}

void SysAudioSource::OnRegistryGlobalRemove(void* data, uint32_t id) {
  auto* self = static_cast<SysAudioSource*>(data);

  self->our_client_ids_.erase(id);

  auto it = self->link_proxies_by_node_.find(id);
  if (it != self->link_proxies_by_node_.end()) {
    for (struct pw_proxy* link : it->second) {
      if (link) {
        pw_proxy_destroy(link);
      }
    }
    self->link_proxies_by_node_.erase(it);
  }

  self->target_nodes_.erase(id);
}

#endif  // WEBRTC_LINUX
