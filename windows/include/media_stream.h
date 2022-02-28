#pragma once

#include "flutter_webrtc.h"

using namespace rust::cxxbridge1;
using namespace flutter;

#define DEFAULT_WIDTH 640
#define DEFAULT_HEIGHT 480
#define DEFAULT_FPS 30

namespace flutter_webrtc_plugin {

// Calls Rust `EnumerateDevices()` and converts the received Rust vector of
// `MediaDeviceInfo` info for Dart.
void EnumerateDevice(rust::Box<Webrtc>& webrtc,
                     std::unique_ptr<MethodResult<EncodableValue>> result);

// Parses the received constraints from Dart and passes them to Rust
// `GetMedia()`, then converts the backed `MediaStream` info for Dart.
void GetMedia(Box<Webrtc>& webrtc,
              const flutter::MethodCall<EncodableValue>& method_call,
              std::unique_ptr<flutter::MethodResult<EncodableValue>> result,
              bool is_display = false);

// Changes the `enabled` property of the specified media track.
void SetTrackEnabled(
    Box<Webrtc>& webrtc,
    const flutter::MethodCall<EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result);

// Disposes some media stream calling Rust `DisposeStream`.
void DisposeStream(
    Box<Webrtc>& webrtc,
    const flutter::MethodCall<EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result);

// Parses video constraints received from Dart to Rust `VideoConstraints`.
VideoConstraints ParseVideoConstraints(const EncodableValue video_arg);

// Parses audio constraints received from Dart to Rust `AudioConstraints`.
AudioConstraints ParseAudioConstraints(const EncodableValue audio_arg);

// Converts Rust `VideoConstraints` or `AudioConstraints` to `EncodableList`
// for passing to Dart according to `TrackKind`.
EncodableList GetParams(TrackKind type, MediaStream& user_media);

// TODO: not real reason to declare this in header (e.g. CreateSdpCallback)
// Handler for changing media devices in system.
class DeviceChangeHandler : public OnDeviceChangeCallback {
 public:
  DeviceChangeHandler(flutter::BinaryMessenger* binary_messenger);

  // `OnDeviceChangeCallback` implementation.
  void OnDeviceChange();

 private:
  // A named channel for communicating with the Flutter application using
  // asynchronous event streams.
  std::unique_ptr<EventChannel<EncodableValue>> event_channel_;

  // Event callback. Events to be sent to Flutter application
  // act as clients of this interface for sending events.
  std::unique_ptr<EventSink<EncodableValue>> event_sink_;
};

}  // namespace flutter_webrtc_plugin
