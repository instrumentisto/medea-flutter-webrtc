import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../flutter_webrtc.dart';

class Helper {
  static Future<List<MediaDeviceInfo>> enumerateDevices(String type) async {
    var devices = await navigator.mediaDevices.enumerateDevices();
    return devices.where((d) => d.kind == type).toList();
  }

  /// Return the available cameras
  ///
  /// Note: Make sure to call this gettet after
  /// navigator.mediaDevices.getUserMedia(), otherwise the devices will not be
  /// listed.
  static Future<List<MediaDeviceInfo>> get cameras =>
      enumerateDevices('videoinput');

  /// Return the available audiooutputs
  ///
  /// Note: Make sure to call this gettet after
  /// navigator.mediaDevices.getUserMedia(), otherwise the devices will not be
  /// listed.
  static Future<List<MediaDeviceInfo>> get audiooutputs =>
      enumerateDevices('audiooutput');

  static Future<void> setVolume(double volume, MediaStreamTrack track) async {
    if (track.kind == 'audio') {
      if (kIsWeb) {
        final constraints = track.getConstraints();
        constraints['volume'] = volume;
        await track.applyConstraints(constraints);
      } else {
        await WebRTC.invokeMethod(
          'setVolume',
          <String, dynamic>{'trackId': track.id, 'volume': volume},
        );
      }
    }

    return Future.value();
  }

  static void setMicrophoneMute(bool mute, MediaStreamTrack track) async {
    if (track.kind != 'audio') {
      throw 'The is not an audio track => $track';
    }

    if (!kIsWeb) {
      try {
        await WebRTC.invokeMethod(
          'setMicrophoneMute',
          <String, dynamic>{'trackId': track.id, 'mute': mute},
        );
      } on PlatformException catch (e) {
        throw 'Unable to MediaStreamTrack::setMicrophoneMute: ${e.message}';
      }
    }
    track.enabled = !mute;
  }
}
