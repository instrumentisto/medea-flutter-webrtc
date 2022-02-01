#pragma once

#include <mutex>
#include <optional>

#include "flutter/event_channel.h"
#include "flutter/event_stream_handler_functions.h"
#include "flutter/plugin_registrar.h"
#include "flutter/method_result.h"
#include "flutter/texture_registrar.h"
#include "flutter/encodable_value.h"
#include "flutter_webrtc_native.h"

using namespace flutter;

namespace flutter_webrtc_plugin {

// Responsible for rendering `VideoFrame`s on the Flutter texture.
class TextureVideoRenderer {
 public:

  // Creates a new `TextureVideoRenderer`.
  TextureVideoRenderer(TextureRegistrar* registrar, BinaryMessenger* messenger);

  // Constructs and returns a `FlutterDesktopPixelBuffer` from the current
  // `VideoFrame`.
  virtual FlutterDesktopPixelBuffer* CopyPixelBuffer(size_t width,
                                                     size_t height);

  // Called when a new `VideoFrame` is produced by the underlying source.
  virtual void OnFrame(VideoFrame frame);

  // Resets `TextureVideoRenderer` to the initial state.
  virtual void ResetRenderer();

  // Returns an ID of the Flutter texture associated with this renderer.
  int64_t texture_id() { return texture_id_; }

 private:
  // Struct which describes `VideoFrame`'s dimensions.
  struct FrameSize {
    size_t width;
    size_t height;
  };

  // `FrameSize` of the last processed `VideoFrame`.
  FrameSize last_frame_size_ = {0, 0};

  // Indicates if at least one `VideoFrame` has been rendered.
  bool first_frame_rendered = false;

  // An object keeping track of external textures.
  TextureRegistrar* registrar_;

  // A named channel for communicating with the Flutter application using
  // asynchronous event streams.
  std::unique_ptr<EventChannel<EncodableValue>> event_channel_;

  // Event callback. Events to be sent to Flutter application act as clients of
  // this interface for sending events.
  std::unique_ptr<EventSink<EncodableValue>> event_sink_;

  // `Id` of Flutter `texture`.
  int64_t texture_id_ = -1;

  // ID of the Flutter texture associated with this renderer.
  std::optional<VideoFrame> frame_;

  // An actual Flutter texture that the incoming frames are rendered on.
  std::unique_ptr<flutter::TextureVariant> texture_;

  // Pointer to the `FlutterDesktopPixelBuffer` that are passed to the Flutter
  // texture.
  std::unique_ptr<FlutterDesktopPixelBuffer> pixel_buffer_;

  // Raw image buffer.
  std::unique_ptr<uint8_t> argb_buffer_;

  // Protects the `frame_`, `pixel_buffer_` and `argb_buffer_` fields that are
  // accessed from multiple threads.
  std::mutex mutex_;

  // Rotation of the current `VideoFrame`.
  int32_t rotation_ = 0;
};

// Stores and manages all `TextureVideoRenderer`s.
class FlutterVideoRendererManager {
 public:
  FlutterVideoRendererManager(TextureRegistrar* registrar,
                              BinaryMessenger* messenger);

  // Creates a new `FlutterVideoRendererManager`.
  void CreateVideoRendererTexture(
      std::unique_ptr<MethodResult<EncodableValue>> result);

  // Changes a media source of a specific `TextureVideoRenderer`.
  void SetMediaStream(const flutter::MethodCall<EncodableValue>& method_call,
                      rust::Box<Webrtc>& webrtc,
                      std::unique_ptr<MethodResult<EncodableValue>> result);

  // Disposes the specific `TextureVideoRenderer`.
  void VideoRendererDispose(
      const flutter::MethodCall<EncodableValue>& method_call,
      rust::Box<Webrtc>& webrtc,
      std::unique_ptr<MethodResult<EncodableValue>> result);

 private:
  // An object keeping track of external textures.
  TextureRegistrar* registrar_;

  // Channel to the Dart side renderers.
  BinaryMessenger* messenger_;

  // The map that contains all `TextureVideoRenderer`s.
  std::map<int64_t, std::shared_ptr<TextureVideoRenderer>> renderers_;
};

// `OnFrameCallbackInterface` that forwards all incoming `VideoFrame`s to the
// `TextureVideoRenderer`.
class FrameHandler : public OnFrameCallbackInterface {
 public:

  // Creates a new `FrameHandler`.
  FrameHandler(std::shared_ptr<TextureVideoRenderer> renderer);

  // `OnFrameCallbackInterface` implementation
  void OnFrame(VideoFrame frame);

 private:
  // `TextureVideoRenderer` that the `VideoFrame`s will be passed to.
  std::shared_ptr<TextureVideoRenderer> renderer_;
};

}  // namespace flutter_webrtc_plugin
