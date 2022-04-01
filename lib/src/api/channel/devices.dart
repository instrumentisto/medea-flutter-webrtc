import 'dart:async';

import 'package:flutter/services.dart';

import '/src/model/constraints.dart';
import '/src/model/device.dart';
import '/src/platform/native/media_stream_track.dart';
import 'channel.dart';

/// Shortcut for the `on_device_change` callback.
typedef OnDeviceChangeCallback = void Function();

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

  /// Sets the [OnDeviceChangeCallback] callback.
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
  return (await _mediaDevicesMethodChannel.invokeMethod('enumerateDevices'))
      .map((i) => MediaDeviceInfo(i))
      .toList();
}

/// [MethodChannel]-based implementation of a [getUserMedia] function.
Future<List<NativeMediaStreamTrack>> getUserMedia(
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

/// [MethodChannel]-based implementation of a [getDisplayMedia] function.
Future<List<NativeMediaStreamTrack>> getDisplayMedia(
    DisplayConstraints constraints) async {
  List<dynamic> res = await _mediaDevicesMethodChannel
      .invokeMethod('getDisplayMedia', {'constraints': constraints.toMap()});
  return res.map((t) => NativeMediaStreamTrack.from(t)).toList();
}

/// Switches the current output audio device to the provided [deviceId].
///
/// List of output audio devices may be obtained via [enumerateDevices].
Future<void> setOutputAudioId(String deviceId) async {
  await _mediaDevicesMethodChannel
      .invokeMethod('setOutputAudioId', {'deviceId': deviceId});
}

void onDeviceChange(OnDeviceChangeCallback? cb) {
  _DeviceHandler().setHandler(cb);
}
