#include "texture_video_renderer.h"
#include "flutter_webrtc_native.h"
#include "parsing.h"

namespace flutter_webrtc_plugin {

FlutterVideoRendererManager::FlutterVideoRendererManager(
    TextureRegistrar* registrar,
    BinaryMessenger* messenger): registrar_(registrar), messenger_(messenger) {}

// Creates a new `VideoRenderer`.
void FlutterVideoRendererManager::CreateVideoRendererTexture(
    std::unique_ptr<MethodResult<EncodableValue>> result) {
  std::shared_ptr<TextureVideoRenderer> texture(
      new TextureVideoRenderer(registrar_, messenger_));

  int64_t texture_id = texture->texture_id();
  renderers_[texture_id] = std::move(texture);
  EncodableMap params;
  params[EncodableValue("textureId")] = EncodableValue(texture_id);

  result->Success(EncodableValue(params));
}

// Sets a new `source` to the certain `VideoRenderer`.
void FlutterVideoRendererManager::SetMediaStream(
    const flutter::MethodCall<EncodableValue>& method_call,
    rust::Box<Webrtc>& webrtc,
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
      webrtc->CreateVideoSink(
          texture_id, (uint64_t)std::stoi(stream_id),
          std::make_unique<TextureVideoRendererShim>(it->second));
    } else {
      webrtc->DisposeVideoSink(texture_id);
      it->second.get()->ResetRenderer();
    }
  }

  result->Success();
}

// Disposes the `VideoRenderer`.
void FlutterVideoRendererManager::VideoRendererDispose(
    const flutter::MethodCall<EncodableValue>& method_call,
    rust::Box<Webrtc>& webrtc,
    std::unique_ptr<MethodResult<EncodableValue>> result) {
  if (!method_call.arguments()) {
    result->Error("Bad Arguments", "Null constraints arguments received");
    return;
  }
  const EncodableMap params = GetValue<EncodableMap>(*method_call.arguments());
  int64_t texture_id = findLongInt(params, "textureId");

  auto it = renderers_.find(texture_id);
  if (it != renderers_.end()) {
    registrar_->UnregisterTexture(texture_id);
    renderers_.erase(it);
    result->Success();
    return;
  }
  result->Error("VideoRendererDisposeFailed",
                "VideoRendererDispose() texture not found!");
}

// `TextureVideoRenderer` costructor. Creates a new `texture` and
// `EventChannel`, register them.
TextureVideoRenderer::TextureVideoRenderer(TextureRegistrar* registrar,
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
const FlutterDesktopPixelBuffer* TextureVideoRenderer::CopyPixelBuffer(
    size_t width,
    size_t height) const {
  mutex_.lock();

  if (pixel_buffer_.get() && frame_) {
    if (pixel_buffer_->width != frame_->width ||
        pixel_buffer_->height != frame_->height) {
      size_t buffer_size = frame_->buffer_size;
      rgb_buffer_.reset(new uint8_t[buffer_size]);
      pixel_buffer_->width = frame_->width;
      pixel_buffer_->height = frame_->height;
    }

    frame_->GetABGRBytes(rgb_buffer_.get());

    pixel_buffer_->buffer = rgb_buffer_.get();

    mutex_.unlock();
    return pixel_buffer_.get();
  }
  mutex_.unlock();
  return nullptr;
}

// `Frame` handler. Sends events to Dart when receives the `Frame`.
void TextureVideoRenderer::OnFrame(VideoFrame frame) {
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
  if (rotation_ != frame.rotation) {
    if (event_sink_) {
      EncodableMap params;
      params[EncodableValue("event")] = "didTextureChangeRotation";
      params[EncodableValue("id")] = EncodableValue(texture_id_);
      params[EncodableValue("rotation")] =
          EncodableValue((int32_t)frame.rotation);
      event_sink_->Success(EncodableValue(params));
    }
    rotation_ = frame.rotation;
  }
  if (last_frame_size_.width != frame.width ||
      last_frame_size_.height != frame.height) {
    if (event_sink_) {
      EncodableMap params;
      params[EncodableValue("event")] = "didTextureChangeVideoSize";
      params[EncodableValue("id")] = EncodableValue(texture_id_);
      params[EncodableValue("width")] = EncodableValue((int32_t)frame.width);
      params[EncodableValue("height")] =
          EncodableValue((int32_t)frame.height);
      event_sink_->Success(EncodableValue(params));
    }
    last_frame_size_ = {frame.width, frame.height};
  }
  mutex_.lock();
  frame_.emplace(std::move(frame));
  mutex_.unlock();
  registrar_->MarkTextureFrameAvailable(texture_id_);
}

// Set `Renderer`'s default state.
void TextureVideoRenderer::ResetRenderer() {
  mutex_.lock();
  frame_.reset();
  mutex_.unlock();
  frame_ = std::nullopt;
  last_frame_size_ = {0, 0};
  first_frame_rendered = false;
}

// A `TextureVideoRendererShim` constructor. Sets income `TextureVideoRenderer`.
TextureVideoRendererShim::TextureVideoRendererShim(
    std::shared_ptr<TextureVideoRenderer> ctx) {
  ctx_ = std::move(ctx);
}

// Calls `TextureVideoRenderer->OnFrame`.
void TextureVideoRendererShim::OnFrame(VideoFrame frame) {
  ctx_->OnFrame(std::move(frame));
}

}  // namespace flutter_webrtc_plugin
