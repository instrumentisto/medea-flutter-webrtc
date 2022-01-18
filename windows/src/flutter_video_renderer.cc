#include "flutter_video_renderer.h"
#include "flutter_webrtc_native.h"
#include "wrapper.h"

namespace flutter_webrtc_plugin {

typedef void (*frame_handler)(Frame*);

// Rust FFI function that registers `VideoRenderer` in Rust and set the callback
// on `libWebRTC`'s `Frame` handling.
extern "C" void register_renderer(rust::cxxbridge1::Box<Webrtc>&,
                                  int64_t,
                                  uint64_t,
                                  frame_handler);

// `VideoRendere` costructor. Creates a new `texture` and `EventChannel`,
// register them.
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

// Copies `PixelBuffer` from `libWebRTC` `Frame` to Dart's buffer.
const FlutterDesktopPixelBuffer* FlutterVideoRenderer::CopyPixelBuffer(
    size_t width,
    size_t height) const {
  mutex_.lock();

  if (pixel_buffer_.get() && frame_.has_value()) {
    Frame* frame = frame_.value();
    if (pixel_buffer_->width != frame->width() ||
        pixel_buffer_->height != frame->height()) {
      size_t buffer_size = frame->buffer_size();
      rgb_buffer_.reset(new uint8_t[buffer_size]);
      pixel_buffer_->width = frame->width();
      pixel_buffer_->height = frame->height();
    }

    frame->buffer(rgb_buffer_.get());

    pixel_buffer_->buffer = rgb_buffer_.get();

    mutex_.unlock();
    return pixel_buffer_.get();
  }
  mutex_.unlock();
  return nullptr;
}

// `Frame` handler. Sends events to Dart when receives the `Frame`.
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
  if (frame_.has_value()) {
    delete_frame(frame_.value());
  }
  frame_ = std::optional(frame);
  mutex_.unlock();
  registrar_->MarkTextureFrameAvailable(texture_id_);
}

// Set `Renderer`'s default state.
void FlutterVideoRenderer::ResetRenderer() {
  mutex_.lock();
  if (frame_.has_value()) {
    delete_frame(frame_.value());
  }
  mutex_.unlock();
  frame_ = std::nullopt;
  last_frame_size_ = {0, 0};
  first_frame_rendered = false;
}

FlutterVideoRendererManager::FlutterVideoRendererManager(
    FlutterWebRTCBase* base)
    : base_(base) {}

// Creates a new `VideoRenderer`.
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

// Sets a new `source` to the cerntain `VideoRenderer`.
void FlutterVideoRendererManager::SetMediaStream(
    const flutter::MethodCall<EncodableValue>& method_call,
    rust::cxxbridge1::Box<Webrtc>& webrtc,
    std::unique_ptr<MethodResult<EncodableValue>> result) {
  if (!method_call.arguments()) {
    result->Error("Bad Arguments", "Null constraints arguments received");
    return;
  }
  const EncodableMap params = GetValue<EncodableMap>(*method_call.arguments());
  const std::string stream_id = findString(params, "streamId");
  int64_t texture_id = findLongInt(params, "textureId");

  auto it = renderers_.find(texture_id);
  if (it != renderers_.end()) {
    if (stream_id != "") {
      auto cb = std::bind(&FlutterVideoRenderer::OnFrame,
                          renderers_[texture_id].get(), std::placeholders::_1);
      frame_handler wrapped_cb = Wrapper<0, void(Frame*)>::wrap(cb);
      register_renderer(webrtc, texture_id, (uint64_t)std::stoi(stream_id),
                        wrapped_cb);
    } else {
      webrtc->dispose_renderer(texture_id);
      it->second.get()->ResetRenderer();
    }
  }

  result->Success();
}

// Disposes the `VideoRenderer`.
void FlutterVideoRendererManager::VideoRendererDispose(
    const flutter::MethodCall<EncodableValue>& method_call,
    rust::cxxbridge1::Box<Webrtc>& webrtc,
    std::unique_ptr<MethodResult<EncodableValue>> result) {
  if (!method_call.arguments()) {
    result->Error("Bad Arguments", "Null constraints arguments received");
    return;
  }
  const EncodableMap params = GetValue<EncodableMap>(*method_call.arguments());
  int64_t texture_id = findLongInt(params, "textureId");

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
