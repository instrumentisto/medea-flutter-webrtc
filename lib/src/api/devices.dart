import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';

import 'package:medea_flutter_webrtc/medea_flutter_webrtc.dart';
import '/src/platform/native/media_stream_track.dart';
import 'bridge/api/media.dart' as ffi;
import 'bridge/api/media/constraints.dart' as ffi;
import 'bridge/api/media/constraints/audio.dart' as ffi;
import 'bridge/api/media/constraints/video.dart' as ffi;
import 'bridge/api/media_stream_track.dart' as ffi;
import 'bridge/api/media_stream_track/audio_processing_config.dart' as ffi;
import 'channel.dart';

/// Default video width when capturing user's camera.
const defaultUserMediaWidth = 640;

/// Default video height when capturing user's camera.
const defaultUserMediaHeight = 480;

/// Default video width when capturing user's display.
const defaultDisplayMediaWidth = 1280;

/// Default video height when capturing user's display.
const defaultDisplayMediaHeight = 720;

/// Default video framerate.
const defaultFrameRate = 30;

/// Shortcut for the `on_device_change` callback.
typedef OnDeviceChangeCallback = void Function();

/// Singleton for listening device change.
class _DeviceHandler {
  /// Instance of a [_DeviceHandler] singleton.
  static final _DeviceHandler _instance = _DeviceHandler._internal();

  /// Callback, called whenever a media device such as a camera, microphone, or
  /// speaker is connected to or removed from the system.
  OnDeviceChangeCallback? _handler;

  /// Returns [_DeviceHandler] singleton instance.
  factory _DeviceHandler() {
    return _instance;
  }

  /// Creates a new [_DeviceHandler].
  _DeviceHandler._internal() {
    _listen();
  }

  /// Subscribes to the platform [Stream] emitting device change events.
  void _listen() async {
    if (isDesktop) {
      ffi.setOnDeviceChanged().listen((event) {
        if (_handler != null) {
          _handler!();
        }
      });
    } else {
      eventChannel('MediaDevicesEvent', 0).receiveBroadcastStream().listen((
        event,
      ) {
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

  /// Sets the [OnDeviceChangeCallback] callback.
  void setHandler(OnDeviceChangeCallback? handler) {
    _handler = handler;
  }
}

/// Represents the `cause` of the [GetMediaException].
enum GetMediaExceptionKind {
  /// If the [getUserMedia] or [getDisplayMedia] request failed on getting
  /// `audio`.
  audio,

  /// If the [getUserMedia] or [getDisplayMedia] request failed on getting
  /// `video`.
  video,
}

/// [Exception] thrown if there is an `error` while calling [getUserMedia] or
/// [getDisplayMedia].
class GetMediaException implements Exception {
  /// Constructs a new [GetMediaException].
  GetMediaException(this._kind, this._message);

  /// [GetMediaExceptionKind] of this [GetMediaException].
  final GetMediaExceptionKind _kind;

  /// The `message` of this [GetMediaException].
  final String? _message;

  @override
  String toString() {
    return _message ?? '';
  }

  /// Returns the [GetMediaExceptionKind] of this [GetMediaException]
  GetMediaExceptionKind kind() {
    return _kind;
  }
}

/// [MethodChannel] used for the messaging with a native side.
final _mediaDevicesMethodChannel = methodChannel('MediaDevices', 0);

/// Returns list of [MediaDeviceInfo]s for the currently available devices.
Future<List<MediaDeviceInfo>> enumerateDevices() async {
  if (isDesktop) {
    return (await ffi.enumerateDevices())
        .map((e) => MediaDeviceInfo.fromFFI(e))
        .toList();
  } else {
    final List<dynamic>? devices = await _mediaDevicesMethodChannel
        .invokeMethod('enumerateDevices');
    return devices!.map((i) => MediaDeviceInfo.fromMap(i)).toList();
  }
}

/// Returns list of [MediaDisplayInfo]s for the currently available displays.
Future<List<MediaDisplayInfo>> enumerateDisplays() async {
  if (isDesktop) {
    return (await ffi.enumerateDisplays())
        .map((e) => MediaDisplayInfo.fromFFI(e))
        .toList();
  } else {
    return List<MediaDisplayInfo>.empty();
  }
}

/// Returns list of local audio and video [NativeMediaStreamTrack]s based on the
/// provided [DeviceConstraints].
Future<List<NativeMediaStreamTrack>> getUserMedia(
  DeviceConstraints constraints,
) async {
  if (isDesktop) {
    return _getUserMediaFFI(constraints);
  } else {
    return _getUserMediaChannel(constraints);
  }
}

/// Returns list of local display [NativeMediaStreamTrack]s based on the
/// provided [DisplayConstraints].
Future<List<NativeMediaStreamTrack>> getDisplayMedia(
  DisplayConstraints constraints,
) async {
  if (isDesktop) {
    return _getDisplayMediaFFI(constraints);
  } else {
    return _getDisplayMediaChannel(constraints);
  }
}

/// Switches the current output audio device to the provided [deviceId].
///
/// List of output audio devices may be obtained via [enumerateDevices].
Future<void> setOutputAudioId(String deviceId) async {
  if (isDesktop) {
    await ffi.setAudioPlayoutDevice(deviceId: deviceId);
  } else {
    await _mediaDevicesMethodChannel.invokeMethod('setOutputAudioId', {
      'deviceId': deviceId,
    });
  }
}

/// Indicates whether the microphone is available to set volume.
Future<bool> microphoneVolumeIsAvailable() async {
  if (isDesktop) {
    return await ffi.microphoneVolumeIsAvailable();
  } else {
    // TODO: Implement for Channel-based implementation.
    return false;
  }
}

/// Sets the microphone system volume according to the specified [level] in
/// percents.
Future<void> setMicrophoneVolume(int level) async {
  await ffi.setMicrophoneVolume(level: level);
}

/// Returns the current level of the microphone volume in percents.
Future<int> microphoneVolume() async {
  return await ffi.microphoneVolume();
}

/// [MethodChannel]-based implementation of a [getUserMedia] function.
Future<List<NativeMediaStreamTrack>> _getUserMediaChannel(
  DeviceConstraints constraints,
) async {
  try {
    List<dynamic>? res = await _mediaDevicesMethodChannel.invokeMethod(
      'getUserMedia',
      {'constraints': constraints.toMap()},
    );
    List<Future<NativeMediaStreamTrack>> tracks = res!
        .map((t) => NativeMediaStreamTrack.from(t))
        .toList();
    return await Future.wait(tracks);
  } on PlatformException catch (e) {
    if (e.code == 'GetUserMediaAudioException') {
      throw GetMediaException(GetMediaExceptionKind.audio, e.message);
    } else if (e.code == 'GetUserMediaVideoException') {
      throw GetMediaException(GetMediaExceptionKind.video, e.message);
    } else {
      rethrow;
    }
  }
}

/// FFI-based implementation of a [getUserMedia] function.
Future<List<NativeMediaStreamTrack>> _getUserMediaFFI(
  DeviceConstraints constraints,
) async {
  int? nsLevel =
      constraints.audio.mandatory?.noiseSuppressionLevel?.index ??
      constraints.audio.optional?.noiseSuppressionLevel?.index;
  var audioConstraints =
      constraints.audio.mandatory != null || constraints.audio.optional != null
      ? ffi.AudioConstraints(
          deviceId: constraints.audio.mandatory?.deviceId,
          processing: ffi.AudioProcessingConstraints(
            autoGainControl:
                constraints.audio.mandatory?.autoGainControl ??
                constraints.audio.optional?.autoGainControl,
            highPassFilter:
                constraints.audio.mandatory?.highPassFilter ??
                constraints.audio.optional?.highPassFilter,
            echoCancellation:
                constraints.audio.mandatory?.echoCancellation ??
                constraints.audio.optional?.echoCancellation,
            noiseSuppression:
                constraints.audio.mandatory?.noiseSuppression ??
                constraints.audio.optional?.noiseSuppression,
            noiseSuppressionLevel: nsLevel != null
                ? ffi.NoiseSuppressionLevel.values[nsLevel]
                : null,
          ),
        )
      : null;

  var videoConstraints =
      constraints.video.mandatory != null || constraints.video.optional != null
      ? ffi.VideoConstraints(
          deviceId:
              constraints.video.mandatory?.deviceId ??
              constraints.video.optional?.deviceId,
          height:
              constraints.video.mandatory?.height ??
              constraints.video.optional?.height ??
              defaultUserMediaHeight,
          width:
              constraints.video.mandatory?.width ??
              constraints.video.optional?.width ??
              defaultUserMediaWidth,
          frameRate:
              constraints.video.mandatory?.fps ??
              constraints.video.optional?.fps ??
              defaultFrameRate,
          isDisplay: false,
        )
      : null;

  var result = await ffi.getMedia(
    constraints: ffi.MediaStreamConstraints(
      audio: audioConstraints,
      video: videoConstraints,
    ),
  );

  if (result is ffi.GetMediaResult_Ok) {
    List<Future<NativeMediaStreamTrack>> tracks = result.field0
        .map((e) => NativeMediaStreamTrack.from(e))
        .toList();
    return await Future.wait(tracks);
  } else {
    if ((result as ffi.GetMediaResult_Err).field0 is ffi.GetMediaError_Video) {
      throw GetMediaException(
        GetMediaExceptionKind.video,
        result.field0.field0,
      );
    } else {
      throw GetMediaException(
        GetMediaExceptionKind.audio,
        result.field0.field0,
      );
    }
  }
}

/// [MethodChannel]-based implementation of a [getDisplayMedia] function.
Future<List<NativeMediaStreamTrack>> _getDisplayMediaChannel(
  DisplayConstraints constraints,
) async {
  List<dynamic>? res = await _mediaDevicesMethodChannel.invokeMethod(
    'getDisplayMedia',
    {'constraints': constraints.toMap()},
  );
  List<Future<NativeMediaStreamTrack>> tracks = res!
      .map((t) => NativeMediaStreamTrack.from(t))
      .toList();
  return await Future.wait(tracks);
}

/// FFI-based implementation of a [getDisplayMedia] function.
Future<List<NativeMediaStreamTrack>> _getDisplayMediaFFI(
  DisplayConstraints constraints,
) async {
  var audioConstraints =
      constraints.audio.mandatory != null || constraints.audio.optional != null
      ? ffi.AudioConstraints(
          deviceId: constraints.audio.mandatory?.deviceId,
          processing: ffi.AudioProcessingConstraints(),
        )
      : null;

  var videoConstraints =
      constraints.video.mandatory != null || constraints.video.optional != null
      ? ffi.VideoConstraints(
          deviceId: constraints.video.mandatory?.deviceId,
          height:
              constraints.video.mandatory?.height ??
              constraints.video.optional?.height ??
              defaultDisplayMediaHeight,
          width:
              constraints.video.mandatory?.width ??
              constraints.video.optional?.width ??
              defaultDisplayMediaWidth,
          frameRate:
              constraints.video.mandatory?.fps ??
              constraints.video.optional?.fps ??
              defaultFrameRate,
          isDisplay: true,
        )
      : null;

  var result = await ffi.getMedia(
    constraints: ffi.MediaStreamConstraints(
      audio: audioConstraints,
      video: videoConstraints,
    ),
  );

  if (result is ffi.GetMediaResult_Ok) {
    List<Future<NativeMediaStreamTrack>> tracks = result.field0
        .map((e) => NativeMediaStreamTrack.from(e))
        .toList();
    return await Future.wait(tracks);
  } else {
    if ((result as ffi.GetMediaResult_Err) is ffi.GetMediaError_Video) {
      throw GetMediaException(
        GetMediaExceptionKind.video,
        result.field0.field0,
      );
    } else {
      throw GetMediaException(
        GetMediaExceptionKind.audio,
        result.field0.field0,
      );
    }
  }
}

/// Sets the provided [`OnDeviceChangeCallback`] as the callback to be called
/// whenever a set of available media devices changes.
void onDeviceChange(OnDeviceChangeCallback? cb) {
  _DeviceHandler().setHandler(cb);
}

/// Configures media acquisition to use fake devices instead of actual camera
/// and microphone.
///
/// This must be called before any other function to work properly.
Future<void> enableFakeMedia() async {
  await ffi.enableFakeMedia();
}

/// Foreground call service configuration.
class ForegroundServiceConfig {
  ForegroundServiceConfig({
    this.enabled = true,
    this.notificationOngoing = true,
    this.notificationTitle = 'Ongoing call',
    this.notificationText = 'Ongoing call',
    this.notificationIcon = 'assets/icons/app_icon.png',
  });

  /// Indicator whether the foreground service is enabled.
  bool enabled;

  /// [ongoing] property of a notification.
  ///
  /// [ongoing]: https://tinyurl.com/ntfctn-doc#FLAG_ONGOING_EVENT
  bool notificationOngoing;

  /// [contentTitle] property of a notification.
  ///
  /// [contentTitle]: https://tinyurl.com/ntfctn-doc#EXTRA_TITLE
  String notificationTitle;

  /// [contentText] property of a notification.
  ///
  /// [contentText]: https://tinyurl.com/ntfctn-doc#EXTRA_TEXT
  String notificationText;

  /// [icon] property of a notification.
  ///
  /// This should be a full path to a bundled bitmap file. For the assets
  /// configured in `pubspec.yaml` like this:
  /// ```yaml
  /// assets:
  ///   - assets/icons/app_icon.png
  /// ```
  /// The full path would be `assets/icons/app_icon.png`.
  ///
  /// [ic_menu_call] will be used as a fallback if construction an icon from the
  /// provided path fails.
  ///
  /// [icon]: https://tinyurl.com/ntfctn-doc#icon
  /// [ic_menu_call]: https://tinyurl.com/andrawable#ic_menu_call
  String notificationIcon;

  /// Converts this model to the [Map] that can be transmitted via
  /// [MethodChannel].
  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'notificationOngoing': notificationOngoing,
      'notificationTitle': notificationTitle,
      'notificationText': notificationText,
      'notificationIcon': notificationIcon,
    };
  }
}

/// Configures a foreground service and its notification on Android.
///
/// Foreground service is required for audio/video recording/playback to work
/// when application is in the background.
///
/// Application will start foreground service whenever there is at least one
/// active peer connection and stop when there are none anymore. This can also
/// be controlled via [ForegroundServiceConfig.enabled] option. Foreground
/// service can be stopped while running and restarted again by changing this
/// parameter.
///
/// Foreground service notification parameters can be updated using this method
/// at any moment. I.e., the title and the text could be changed while the
/// notification is displayed and they would be updated immediately.
Future<void> setupForegroundService(ForegroundServiceConfig config) async {
  if (Platform.isAndroid) {
    await _mediaDevicesMethodChannel.invokeMethod('setupForegroundService', {
      'config': config.toMap(),
    });
  }
}
