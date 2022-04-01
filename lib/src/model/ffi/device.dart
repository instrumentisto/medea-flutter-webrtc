import '/src/api/ffi/bridge.g.dart' as ffi;
import '/src/model/device.dart';

/// Information about some media device.
class MediaDeviceInfo {
  /// Creates a [MediaDeviceInfo] basing on the [ffi.MediaDeviceInfo] received
  /// from the native side.
  MediaDeviceInfo(ffi.MediaDeviceInfo info) {
    deviceId = info.deviceId;
    label = info.label;
    kind = MediaDeviceKind.values[info.kind.index];
  }

  /// Identifier of the represented device.
  late String deviceId;

  /// Human-readable device description (for example, "External USB Webcam").
  late String label;

  /// Media kind of the device (for example, `audioinput` for microphone).
  late MediaDeviceKind kind;
}
