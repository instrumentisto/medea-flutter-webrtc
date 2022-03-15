#include <Windows.h>
#include <sstream>
#include <string>

#include <flutter/standard_message_codec.h>
#include <flutter/standard_method_codec.h>
// #include "flutter-webrtc-native/include/api.h"
#include "flutter_webrtc.h"
#include "flutter_webrtc/flutter_web_r_t_c_plugin.h"
// #include "media_stream.h"
#include "parsing.h"
// #include "peer_connection.h"

namespace flutter_webrtc_plugin {

// // `OnDeviceChangeCallback` implementation forwarding the event to the Dart
// // side via `EventSink`.
// class DeviceChangeHandler : public OnDeviceChangeCallback {
//  public:
//   DeviceChangeHandler(flutter::BinaryMessenger* binary_messenger) {
//     event_channel_.reset(new EventChannel<EncodableValue>(
//         binary_messenger, "FlutterWebRTC/OnDeviceChange",
//         &StandardMethodCodec::GetInstance()));

//     auto handler = std::make_unique<StreamHandlerFunctions<EncodableValue>>(
//         // `on_listen` callback.
//         [&](const flutter::EncodableValue* arguments,
//             std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&&
//                 events)
//             -> std::unique_ptr<StreamHandlerError<flutter::EncodableValue>> {
//           event_sink_ = std::move(events);
//           return nullptr;
//         },
//         // `on_cancel` callback.
//         [&](const flutter::EncodableValue* arguments)
//             -> std::unique_ptr<StreamHandlerError<flutter::EncodableValue>> {
//           event_sink_ = nullptr;
//           return nullptr;
//         });

//     event_channel_->SetStreamHandler(std::move(handler));
//   }

//   // `OnDeviceChangeCallback` implementation.
//   void OnDeviceChange() { event_sink_->Success(); }

//  private:
//   // Named channel for communicating with the Flutter application using
//   // asynchronous event streams.
//   std::unique_ptr<EventChannel<EncodableValue>> event_channel_;

//   // Event callback. Events to be sent to Flutter application act as clients
//   of
//   // this interface for sending events.
//   std::unique_ptr<EventSink<EncodableValue>> event_sink_;
// };

FlutterWebRTC::FlutterWebRTC(FlutterWebRTCPlugin* plugin) {
  messenger_ = plugin->messenger();
}

FlutterWebRTC::~FlutterWebRTC() {}

void FlutterWebRTC::HandleMethodCall(
    const flutter::MethodCall<EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
  const std::string& method = method_call.method_name();

  if (method.compare("test") == 0) {
    result->Success();
  } else {
    result->NotImplemented();
  }
}

}  // namespace flutter_webrtc_plugin
