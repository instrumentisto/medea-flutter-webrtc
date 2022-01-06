#include "flutter_video_renderer.h"
#include "flutter_webrtc_native.h"
#include "wrapper.h"

// #include <chrono>
// #include <ctime>

// using std::chrono::duration_cast;
// using std::chrono::milliseconds;
// using std::chrono::seconds;
// using std::chrono::system_clock;

namespace flutter_webrtc_plugin {

typedef void (*myfunc)(Frame*);

extern "C" void foo(rust::cxxbridge1::Box<Webrtc>&,
                    int64_t,
                    rust::String,
                    myfunc);

FlutterVideoRenderer::FlutterVideoRenderer(TextureRegistrar* registrar,
                                           BinaryMessenger* messenger)
    : registrar_(registrar) {
  texture_ =
      std::make_unique<flutter::TextureVariant>(flutter::PixelBufferTexture(
          [this](size_t width,
                 size_t height) -> const FlutterDesktopPixelBuffer* {
            return this->CopyPixelBuffer(width, height);
          }));

  texture_id_ = registrar_->RegisterTexture(texture_.get());

  std::string event_channel =
      "FlutterWebRTC/Texture" + std::to_string(texture_id_);
  event_channel_.reset(new EventChannel<EncodableValue>(
      messenger, event_channel, &StandardMethodCodec::GetInstance()));

  auto handler = std::make_unique<StreamHandlerFunctions<EncodableValue>>(
      [&](const flutter::EncodableValue* arguments,
          std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events)
          -> std::unique_ptr<StreamHandlerError<flutter::EncodableValue>> {
        event_sink_ = std::move(events);
        return nullptr;
      },
      [&](const flutter::EncodableValue* arguments)
          -> std::unique_ptr<StreamHandlerError<flutter::EncodableValue>> {
        event_sink_ = nullptr;
        return nullptr;
      });

  event_channel_->SetStreamHandler(std::move(handler));
}

const FlutterDesktopPixelBuffer* FlutterVideoRenderer::CopyPixelBuffer(
    size_t width,
    size_t height) const {
  mutex_.lock();

  if (pixel_buffer_.get() && frame_) {
    if (pixel_buffer_->width != frame_->width() ||
        pixel_buffer_->height != frame_->height()) {
      size_t buffer_size = frame_->buffer_size();
      rgb_buffer_.reset(new uint8_t[buffer_size]);
      pixel_buffer_->width = frame_->width();
      pixel_buffer_->height = frame_->height();
    }

    frame_->buffer(rgb_buffer_.get());

    pixel_buffer_->buffer = rgb_buffer_.get();

    mutex_.unlock();
    return pixel_buffer_.get();
  }
  mutex_.unlock();
  return nullptr;
}

void FlutterVideoRenderer::OnFrame(Frame* frame) {
  if (!first_frame_rendered) {
    if (event_sink_) {
      EncodableMap params;
      params[EncodableValue("event")] = "didFirstFrameRendered";
      params[EncodableValue("id")] = EncodableValue(texture_id_);
      event_sink_->Success(EncodableValue(params));
    }
    pixel_buffer_.reset(new FlutterDesktopPixelBuffer());
    pixel_buffer_->width = 0;
    pixel_buffer_->height = 0;
    first_frame_rendered = true;
  }
  if (rotation_ != frame->rotation()) {
    if (event_sink_) {
      EncodableMap params;
      params[EncodableValue("event")] = "didTextureChangeRotation";
      params[EncodableValue("id")] = EncodableValue(texture_id_);
      params[EncodableValue("rotation")] =
          EncodableValue((int32_t)frame->rotation());
      event_sink_->Success(EncodableValue(params));
    }
    rotation_ = frame->rotation();
  }
  if (last_frame_size_.width != frame->width() ||
      last_frame_size_.height != frame->height()) {
    if (event_sink_) {
      EncodableMap params;
      params[EncodableValue("event")] = "didTextureChangeVideoSize";
      params[EncodableValue("id")] = EncodableValue(texture_id_);
      params[EncodableValue("width")] = EncodableValue((int32_t)frame->width());
      params[EncodableValue("height")] =
          EncodableValue((int32_t)frame->height());
      event_sink_->Success(EncodableValue(params));
    }
    last_frame_size_ = {(size_t)frame->width(), (size_t)frame->height()};
  }
  mutex_.lock();
  if (frame_ != nullptr) {
    delete_frame(frame_);
  }
  frame_ = frame;
  mutex_.unlock();

  registrar_->MarkTextureFrameAvailable(texture_id_);
}

void FlutterVideoRenderer::ResetRenderer() {
  mutex_.lock();
  if (frame_ != nullptr) {
    delete_frame(frame_);
  }
  mutex_.unlock();
  frame_ = nullptr;
  last_frame_size_ = {0, 0};
  first_frame_rendered = false;
}

// void FlutterVideoRenderer::SetVideoTrack(scoped_refptr<RTCVideoTrack>
// track)
// {
//   if (track_ != track) {
//     if (track_)
//       track_->RemoveRenderer(this);
//     track_ = track;
//     last_frame_size_ = {0, 0};
//     first_frame_rendered = false;
//     if (track_)
//       track_->AddRenderer(this);
//   }
// }

// bool FlutterVideoRenderer::CheckMediaStream(std::string mediaId) {
//   if (0 == mediaId.size() || 0 == media_stream_id.size()) {
//     return false;
//   }
//   return mediaId == media_stream_id;
// }

// bool FlutterVideoRenderer::CheckVideoTrack(std::string mediaId) {
//   if (0 == mediaId.size() || !track_) {
//     return false;
//   }
//   return mediaId == track_->id().std_string();
// }

FlutterVideoRendererManager::FlutterVideoRendererManager(
    FlutterWebRTCBase* base)
    : base_(base) {}

void FlutterVideoRendererManager::CreateVideoRendererTexture(
    std::unique_ptr<MethodResult<EncodableValue>> result) {
  std::unique_ptr<FlutterVideoRenderer> texture(
      new FlutterVideoRenderer(base_->textures_, base_->messenger_));
  int64_t texture_id = texture->texture_id();
  renderers_[texture_id] = std::move(texture);
  EncodableMap params;
  params[EncodableValue("textureId")] = EncodableValue(texture_id);

  result->Success(EncodableValue(params));
}

void FlutterVideoRendererManager::SetMediaStream(
    rust::cxxbridge1::Box<Webrtc>& webrtc,
    int64_t texture_id,
    const std::string& stream_id) {
  // scoped_refptr<RTCMediaStream> stream =
  // base_->MediaStreamForId(stream_id);
  auto it = renderers_.find(texture_id);
  if (it != renderers_.end()) {
    if (stream_id != "") {
      auto cb = std::bind(&FlutterVideoRenderer::OnFrame,
                          renderers_[texture_id].get(), std::placeholders::_1);
      myfunc wrapped_cb = Wrapper<0, void(Frame*)>::wrap(cb);
      foo(webrtc, texture_id, rust::String(stream_id), wrapped_cb);
    } else {
      dispose_renderer(webrtc, texture_id);
      it->second.get()->ResetRenderer();
    }

    // FlutterVideoRenderer* renderer = it->second.get();
    // if (stream.get()) {
    //   auto video_tracks = stream->video_tracks();
    //   if (video_tracks.size() > 0) {
    //     renderer->SetVideoTrack(video_tracks[0]);
    //     renderer->media_stream_id = stream_id;
    //   }
    // } else {
    // renderer->SetVideoTrack(nullptr);
    // }
  }
}

void FlutterVideoRendererManager::VideoRendererDispose(
    rust::cxxbridge1::Box<Webrtc>& webrtc,
    int64_t texture_id,
    std::unique_ptr<MethodResult<EncodableValue>> result) {
  auto it = renderers_.find(texture_id);
  if (it != renderers_.end()) {
    base_->textures_->UnregisterTexture(texture_id);
    renderers_.erase(it);
    result->Success();
    return;
  }
  result->Error("VideoRendererDisposeFailed",
                "VideoRendererDispose() texture not found!");
}

}  // namespace flutter_webrtc_plugin
