#ifndef SYS_AUDIO_CAPTURE_LINUX_CAPTURE_H
#define SYS_AUDIO_CAPTURE_LINUX_CAPTURE_H

#include <sys/types.h>
#include <mutex>
#include <string>
#include <thread>
#include <unordered_map>
#include <unordered_set>
#include <vector>

#include <pipewire/pipewire.h>
#include <spa/param/audio/format-utils.h>
#include <spa/utils/ringbuffer.h>

#include "libwebrtc-sys/include/audio_recorder.h"

// System audio capture for Linux using the PipeWire API.
class SysAudioSource final : public AudioRecorder {
 public:
  SysAudioSource();
  ~SysAudioSource() override;

  bool ProcessRecordedPart(bool firstInCycle) override;
  void StopCapture() override;
  bool StartCapture() override;
  webrtc::scoped_refptr<bridge::LocalAudioSource> GetSource() override;

  // pw_stream_events (single capture stream reading from virtual sink)
  static void OnCaptureStreamStateChanged(void* data,
                                          pw_stream_state old_state,
                                          pw_stream_state new_state,
                                          const char* error);
  static void OnCaptureStreamParamChanged(void* data,
                                          uint32_t id,
                                          const spa_pod* param);
  static void OnCaptureStreamProcess(void* data);

  // pw_proxy_events (virtual sink that mixes all nodes that are being captured)
  static void OnSinkProxyBound(void* data, uint32_t global_id);
  static void OnSinkProxyDestroy(void* data);

  // pw_registry_events (adds/removes app nodes)
  static void OnRegistryGlobal(void* data,
                               uint32_t id,
                               uint32_t permissions,
                               const char* type,
                               uint32_t version,
                               const struct spa_dict* props);
  static void OnRegistryGlobalRemove(void* data, uint32_t id);

 private:
  // PipeWire capture stream that reads from the virtual sink.
  struct CaptureStream {
    struct pw_stream* stream = nullptr;
    struct spa_hook listener{};
    SysAudioSource* parent = nullptr;
    struct spa_audio_info_raw format{};
    bool format_valid = false;
  };

  // Output port of a `TargetNode` node.
  struct TargetPort {
    std::string channel;
    uint32_t id = SPA_ID_INVALID;
  };

  // `Stream/Output/Audio` node linked to the virtual sink.
  struct TargetNode {
    uint32_t id = SPA_ID_INVALID;
    std::vector<TargetPort> output_ports;
  };

  // Input port of the virtual sink (channel name, global port id).
  struct SinkInputPort {
    std::string channel;
    uint32_t id = SPA_ID_INVALID;
  };

  // Lock-free single-producer (RT capture from `CaptureStream`) with
  // single-consumer (`ProcessRecordedPart`) fifo.
  struct AudioFifo {
    struct spa_ringbuffer ring;
    std::vector<uint8_t> buffer;
    uint32_t size = 0;
  } capture_fifo_;

  // Creates the null-audio-sink node that mixes captured streams.
  void CreateVirtualSink();

  // Links all output ports of a target node to the sink.
  void LinkTargetNodeToSink(uint32_t node_id);

  // Creates one link from an app output port to a sink input port.
  void LinkPortToSink(uint32_t output_node_id,
                      uint32_t output_port_id,
                      const std::string& port_channel);

  // Creates and connects the capture stream when sink is bound and has ports.
  void OnSinkReady();

  std::recursive_mutex mutex_;
  bool recording_ = false;

  // Pre-allocated buffer for one recorded part.
  std::vector<int16_t> part_buffer_;

  webrtc::scoped_refptr<bridge::LocalAudioSource> source_;

  pw_main_loop* pw_loop_ = nullptr;
  pw_context* pw_ctx_ = nullptr;
  pw_core* pw_core_ = nullptr;
  pw_registry* pw_registry_ = nullptr;
  spa_hook registry_listener_{};
  std::thread pw_thread_;

  // Virtual sink that does the mixing.
  struct pw_proxy* sink_proxy_ = nullptr;
  spa_hook sink_proxy_listener_{};
  uint32_t sink_id_ = SPA_ID_INVALID;
  std::string sink_serial_;
  std::vector<SinkInputPort> sink_input_ports_;

  // Links from app output ports to sink input ports grouped by output node ID.
  std::unordered_map<uint32_t, std::vector<struct pw_proxy*>> link_proxies_by_node_;

  // `Stream/Output/Audio` nodes that are being captured.
  std::unordered_map<uint32_t, TargetNode> target_nodes_;

  // Single capture stream reading from the virtual sink.
  CaptureStream capture_stream_;

  // Our own PipeWire client IDs.
  std::unordered_set<uint32_t> our_client_ids_;
};

#endif  // SYS_AUDIO_CAPTURE_LINUX_CAPTURE_H
