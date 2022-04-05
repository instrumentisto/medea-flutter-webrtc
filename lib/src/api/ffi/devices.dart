import 'dart:async';

import '/src/api/devices.dart';
import '/src/model/constraints.dart';
import '/src/model/device.dart';
import '/src/platform/native/media_stream_track.dart';
import 'bridge.g.dart' as ffi;
import 'peer.dart';

/// Default video width when capturing user's camera.
const defaultUserMediaWidth = 480;

/// Default video height when capturing user's camera.
const defaultUserMediaHeight = 640;

/// Default video width when capturing user's display.
const defaultDisplayMediaWidth = 1280;

/// Default video height when capturing user's display.
const defaultDisplayMediaHeight = 720;

/// Default video framerate.
const defaultFrameRate = 30;

/// Singleton for listening device change.
class _DeviceHandler {
  /// Instance of a [DeviceHandler] singleton.
  static final _DeviceHandler _instance = _DeviceHandler._internal();

  /// A callback that is called whenever a media device such as a camera,
  /// microphone, or speaker is connected to or removed from the system.
  OnDeviceChangeCallback? _handler;

  /// Returns [DeviceHandler] singleton instance.
  factory _DeviceHandler() {
    return _instance;
  }

  /// Creates a new [DeviceHandler].
  _DeviceHandler._internal() {
    _listen();
  }

  /// Subscribes to the platform [Stream] that emits device change events.
  void _listen() async {
    api.setOnDeviceChanged().listen(
      (event) {
        if (_handler != null) {
          _handler!();
        }
      },
    );
  }

  /// Sets the [OnDeviceChangeCallback] callback.
  void setHandler(OnDeviceChangeCallback? handler) {
    _handler = handler;
  }
}

/// Returns list of [MediaDeviceInfo]s for the currently available devices.
Future<List<MediaDeviceInfo>> enumerateDevices() async {
  return (await api.enumerateDevices()).map((i) => MediaDeviceInfo(i)).toList();
}

/// Returns list of local audio and video [NativeMediaStreamTrack]s based on
/// the provided [DeviceConstraints].
Future<List<NativeMediaStreamTrack>> getUserMedia(
    DeviceConstraints constraints) async {
  var audioConstraints = constraints.audio.mandatory != null
      ? ffi.AudioConstraints(deviceId: constraints.audio.mandatory?.deviceId)
      : null;

  var videoConstraints = constraints.video.mandatory != null
      ? ffi.VideoConstraints(
          deviceId: constraints.video.mandatory?.deviceId,
          height: constraints.video.mandatory?.height ?? defaultUserMediaHeight,
          width: constraints.video.mandatory?.width ?? defaultUserMediaWidth,
          frameRate: constraints.video.mandatory?.fps ?? defaultFrameRate,
          isDisplay: false)
      : null;

  var tracks = await api.getMedia(
      constraints: ffi.MediaStreamConstraints(
          audio: audioConstraints, video: videoConstraints));

  return tracks.map((e) => NativeMediaStreamTrack.from(e)).toList();
}

/// Returns list of local display [NativeMediaStreamTrack]s based on the
/// provided [DisplayConstraints].
Future<List<NativeMediaStreamTrack>> getDisplayMedia(
    DisplayConstraints constraints) async {
  var audioConstraints = constraints.audio.mandatory != null
      ? ffi.AudioConstraints(deviceId: constraints.audio.mandatory?.deviceId)
      : null;

  var videoConstraints = constraints.video.mandatory != null
      ? ffi.VideoConstraints(
          deviceId: constraints.video.mandatory?.deviceId,
          height:
              constraints.video.mandatory?.height ?? defaultDisplayMediaHeight,
          width: constraints.video.mandatory?.width ?? defaultDisplayMediaWidth,
          frameRate: constraints.video.mandatory?.fps ?? defaultFrameRate,
          isDisplay: true)
      : null;

  var tracks = await api.getMedia(
      constraints: ffi.MediaStreamConstraints(
          audio: audioConstraints, video: videoConstraints));

  return tracks.map((e) => NativeMediaStreamTrack.from(e)).toList();
}

/// Switches the current output audio device to the provided [deviceId].
///
/// List of output audio devices may be obtained via [enumerateDevices].
Future<void> setOutputAudioId(String deviceId) async {
  await api.setAudioPlayoutDevice(deviceId: deviceId);
}

/// Sets the provided [`OnDeviceChangeCallback`] as the callback to be called
/// whenever a set of available media devices changes.
void onDeviceChange(OnDeviceChangeCallback? cb) {
  _DeviceHandler().setHandler(cb);
}
