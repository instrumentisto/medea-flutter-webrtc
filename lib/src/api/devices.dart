import 'dart:async';

import 'package:flutter/services.dart';

import '/src/model/constraints.dart';
import '/src/model/device.dart';
import '/src/platform/native/media_stream_track.dart';
import 'bridge.g.dart' as ffi;
import 'channel.dart';
import 'peer.dart';

/// Default `video frame` width when capturing user's camera.
const defaultUserMediaWidth = 480;

/// Default `video frame` height when capturing user's camera.
const defaultUserMediaHeight = 640;

/// Default `video frame` width when capturing user's display.
const defaultDisplayMediaWidth = 1280;

/// Default `video frame` height when capturing user's display.
const defaultDisplayMediaHeight = 720;

/// Default `fps` for any `video frame`.
const defaultFrameRate = 30;

/// Shortcut for the `on_device_change` callback.
typedef OnDeviceChangeCallback = void Function();

/// Singleton for listening device change.
class DeviceHandler {
  /// The initialized instanse of this singleton.
  static final DeviceHandler _instance = DeviceHandler._internal();

  /// A callback is used for handling device change.
  OnDeviceChangeCallback? _handler;

  factory DeviceHandler() {
    return _instance;
  }

  DeviceHandler._internal() {
    _listen();
  }

  /// This method initializes listening to [Stream] or [EventChannel] depending
  /// on [isDesktop].
  void _listen() async {
    if (isDesktop) {
      api.setOnDeviceChanged().listen(
        (event) {
          if (_handler != null) {
            _handler!();
          }
        },
      );
    } else {
      eventChannel('MediaDevicesEvent', 0)
          .receiveBroadcastStream()
          .listen((event) {
        final dynamic e = event;
        switch (e['event']) {
          case 'onDeviceChange':
            if (_handler != null) {
              _handler!();
            }
            break;
        }
      });
    }
  }

  /// Subscribes to the `devicechange` event of the `MediaDevices`.
  void setHandler(OnDeviceChangeCallback? handler) {
    _handler = handler;
  }
}

/// [Exception] thrown if the specified constraints resulted in no candidate
/// devices which met the criteria requested. The error is an object of type
/// [OverconstrainedException], and has a constraint property whose string value
/// is the name of a constraint which was impossible to meet.
class OverconstrainedException implements Exception {
  /// Constructs a new [OverconstrainedException].
  OverconstrainedException();

  @override
  String toString() {
    return 'OverconstrainedException';
  }
}

/// [MethodChannel] used for the messaging with a native side.
final _mediaDevicesMethodChannel = methodChannel('MediaDevices', 0);

/// Returns list of [MediaDeviceInfo]s for the currently available devices.
Future<List<MediaDeviceInfo>> enumerateDevices() async {
  if (isDesktop) {
    return await _enumerateDevicesFFI();
  } else {
    return await _enumerateDevicesChannel();
  }
}

/// Channel implementation of [enumerateDevices].
Future<List<MediaDeviceInfo>> _enumerateDevicesChannel() async {
  return (await _mediaDevicesMethodChannel.invokeMethod('enumerateDevices'))
      .map((i) => MediaDeviceInfo.fromMap(i))
      .toList();
}

/// FFI implementation of [enumerateDevices].
Future<List<MediaDeviceInfo>> _enumerateDevicesFFI() async {
  return (await api.enumerateDevices())
      .map((e) => MediaDeviceInfo.fromFFI(e))
      .toList();
}

/// Returns list of local audio and video [NativeMediaStreamTrack]s based on
/// the provided [DeviceConstraints].
Future<List<NativeMediaStreamTrack>> getUserMedia(
    DeviceConstraints constraints) async {
  if (isDesktop) {
    return _getUserMediaFFI(constraints);
  } else {
    return _getUserMediaChannel(constraints);
  }
}

/// Channel implementation of [getUserMedia].
Future<List<NativeMediaStreamTrack>> _getUserMediaChannel(
    DeviceConstraints constraints) async {
  try {
    List<dynamic> res = await _mediaDevicesMethodChannel
        .invokeMethod('getUserMedia', {'constraints': constraints.toMap()});
    return res.map((t) => NativeMediaStreamTrack.from(t)).toList();
  } on PlatformException catch (e) {
    if (e.code == 'OverconstrainedError') {
      throw OverconstrainedException();
    } else {
      rethrow;
    }
  }
}

/// FFI implementation of [getUserMedia].
Future<List<NativeMediaStreamTrack>> _getUserMediaFFI(
    DeviceConstraints constraints) async {
  var audioConstraints = constraints.audio.mandatory != null
      ? ffi.AudioConstraints(
          deviceId: constraints.audio.mandatory?.deviceId ?? '')
      : null;

  var videoConstraints = constraints.video.mandatory != null
      ? ffi.VideoConstraints(
          deviceId: constraints.video.mandatory?.deviceId ?? '',
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
  if (isDesktop) {
    return _getDisplayMediaFFI(constraints);
  } else {
    return _getDisplayMediaChannel(constraints);
  }
}

/// Channel implementation of [getDisplayMedia].
Future<List<NativeMediaStreamTrack>> _getDisplayMediaChannel(
    DisplayConstraints constraints) async {
  List<dynamic> res = await _mediaDevicesMethodChannel
      .invokeMethod('getDisplayMedia', {'constraints': constraints.toMap()});
  return res.map((t) => NativeMediaStreamTrack.from(t)).toList();
}

/// FFI implementation of [getDisplayMedia].
Future<List<NativeMediaStreamTrack>> _getDisplayMediaFFI(
    DisplayConstraints constraints) async {
  var audioConstraints = constraints.audio.mandatory != null
      ? ffi.AudioConstraints(
          deviceId: constraints.audio.mandatory?.deviceId ?? '')
      : null;

  var videoConstraints = constraints.video.mandatory != null
      ? ffi.VideoConstraints(
          deviceId: constraints.video.mandatory?.deviceId ?? '',
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
  if (isDesktop) {
    _setOutputAudioIdFFI(deviceId);
  } else {
    _setOutputAudioIdChannel(deviceId);
  }
}

/// Channel implementation of [setOutputAudioId].
Future<void> _setOutputAudioIdChannel(String deviceId) async {
  await _mediaDevicesMethodChannel
      .invokeMethod('setOutputAudioId', {'deviceId': deviceId});
}

/// FFI implementation of [setOutputAudioId].
Future<void> _setOutputAudioIdFFI(String deviceId) async {
  await api.setAudioPlayoutDevice(deviceId: deviceId);
}
