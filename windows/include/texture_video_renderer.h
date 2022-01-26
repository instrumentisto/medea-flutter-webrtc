#pragma once

#include <mutex>
#include <optional>

#include "flutter_webrtc_base.h"
#include "flutter_webrtc_native.h"
#include "api.h"

namespace flutter_webrtc_plugin {

using namespace flutter;

// Provides managing of the `VideoRenderer`s.
class FlutterVideoRendererManager {
 public:
  FlutterVideoRendererManager(FlutterWebRTCBase* base);

  // Creates a new `VideoRenderer`.
  void CreateVideoRendererTexture(
      std::unique_ptr<MethodResult<EncodableValue>> result);

  // Sets a new `source` to the cerntain `VideoRenderer`.
  void SetMediaStream(const flutter::MethodCall<EncodableValue>& method_call,
                      rust::Box<Webrtc>& webrtc,
                      std::unique_ptr<MethodResult<EncodableValue>> result);

  // Disposes the `VideoRenderer`.
  void VideoRendererDispose(
      const flutter::MethodCall<EncodableValue>& method_call,
      rust::Box<Webrtc>& webrtc,
      std::unique_ptr<MethodResult<EncodableValue>> result);

 private:
  FlutterWebRTCBase* base_;
  // The map that contains `VideoRenderer`s.
  std::map<int64_t, std::unique_ptr<TextureVideoRenderer>> renderers_;
};


// Class with the methods related to `VideoRenderer`.
class TextureVideoRenderer {
 public:
  TextureVideoRenderer(TextureRegistrar* registrar, BinaryMessenger* messenger);

  // Copies `PixelBuffer` from `libWebRTC` `Frame` to Dart's buffer.
  virtual const FlutterDesktopPixelBuffer* CopyPixelBuffer(size_t width,
                                                           size_t height) const;

  // Set `Renderer`'s default state.
  void ResetRenderer();

  // `Id` of related Dart `texture`.
  int64_t texture_id() { return texture_id_; }

 private:

  // Struct which describes `Frame`'s sizes.
  struct FrameSize {
    size_t width;
    size_t height;
  };

  // Size of the last received `Frame`.
  FrameSize last_frame_size_ = {0, 0};

  // Indicates if at least one `Frame` has been rendered.
  bool first_frame_rendered = false;

  // An object keeping track of external textures.
  TextureRegistrar* registrar_ = nullptr;

  // A named channel for communicating with the Flutter application using
  // asynchronous event streams.
  std::unique_ptr<EventChannel<EncodableValue>> event_channel_;

  // Event callback. Events to be sent to Flutter application
  // act as clients of this interface for sending events.
  std::unique_ptr<EventSink<EncodableValue>> event_sink_;

  // `Id` of Flutter `texture`.
  int64_t texture_id_ = -1;

  // `Frame` from `libWebRTC`.
  std::optional<Frame*> frame_ = std::nullopt;

  // A `pixel buffer` Flutter `texture`.
  std::unique_ptr<flutter::TextureVariant> texture_;

  // An image buffer `texture` object.
  std::shared_ptr<FlutterDesktopPixelBuffer> pixel_buffer_;

  // An image buffer.
  mutable std::shared_ptr<uint8_t> rgb_buffer_;

  // A synchronization primitive that can be used to protect shared data
  // from being simultaneously accessed by multiple threads.
  mutable std::mutex mutex_;

  // `Frame`'s rotation.
  VideoRotation rotation_ = VideoRotation::kVideoRotation_0;
};

class FrameRenderer: OnFrameHandler {
 public:
  void OnFrame() override;
 private:
  void *context;
};

}  // namespace flutter_webrtc_plugin
