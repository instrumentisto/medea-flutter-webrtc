import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_webrtc/src/interface/media_stream_track.dart';
import 'package:flutter_webrtc/src/native/media_stream_track_impl.dart';

import '../interface/mediadevices.dart';
import 'utils.dart';

class MediaDeviceNative extends MediaDevices {
  @override
  Future<List<MediaStreamTrack>> getUserMedia(
      Map<String, dynamic> mediaConstraints) async {
    try {
      final response = await WebRTC.invokeMethod(
        'getUserMedia',
        <String, dynamic>{'constraints': mediaConstraints},
      );
      if (response == null) {
        throw Exception('getUserMedia return null, something wrong');
      }

      var tracks = List<dynamic>.empty(growable: true);
      tracks.addAll(response['audioTracks']);
      tracks.addAll(response['videoTracks']);
      return tracks.map((t) => MediaStreamTrackNative.fromMap(t)).toList();
    } on PlatformException catch (e) {
      throw 'Unable to getUserMedia: ${e.message}';
    }
  }

  @override
  Future<List<MediaStreamTrack>> getDisplayMedia(
      Map<String, dynamic> mediaConstraints) async {
    throw UnsupportedError(
        'getDisplayMedia is not supported on Android platform');
  }

  @override
  Future<List<dynamic>> getSources() async {
    try {
      final response = await WebRTC.invokeMethod(
        'getSources',
        <String, dynamic>{},
      );

      List<dynamic> sources = response['sources'];

      return sources;
    } on PlatformException catch (e) {
      throw 'Unable to getSources: ${e.message}';
    }
  }

  @override
  Future<List<MediaDeviceInfo>> enumerateDevices() async {
    var _source = await getSources();
    return _source
        .map(
          (e) => MediaDeviceInfo(
              deviceId: e['deviceId'],
              groupId: e['groupId'],
              kind: e['kind']!,
              label: e['label']),
        )
        .toList();
  }
}
