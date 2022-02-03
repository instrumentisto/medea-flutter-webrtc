#pragma once

#include "flutter/encodable_value.h"
#include "flutter/method_call.h"
#include "flutter/texture_registrar.h"
#include "flutter_webrtc_native.h"
#include "video_renderer.h"

#include "wrapper.h"

using namespace flutter;
using namespace rust::cxxbridge1;

namespace flutter_webrtc_plugin {

class FlutterWebRTCPlugin : public flutter::Plugin {
 public:
  virtual flutter::BinaryMessenger* messenger() = 0;

  virtual flutter::TextureRegistrar* textures() = 0;
};

class FlutterWebRTC : public FlutterVideoRendererManager {
 public:
  FlutterWebRTC(FlutterWebRTCPlugin* plugin);
  virtual ~FlutterWebRTC();

  void HandleMethodCall(
      const flutter::MethodCall<EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<EncodableValue>> result);

  Box<Webrtc> webrtc = Init();

 private:
  // Number of the media devices at certain moment.
  size_t media_device_count_;

  // A named channel for communicating with the Flutter application using
  // asynchronous event streams.
  std::unique_ptr<EventChannel<EncodableValue>> event_channel_;
  // Event callback. Events to be sent to Flutter application
  // act as clients of this interface for sending events.
  std::unique_ptr<EventSink<EncodableValue>> event_sink_;
};

}  // namespace flutter_webrtc_plugin
