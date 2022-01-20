import 'dart:async';

import 'package:flutter/services.dart';

import '../interface/media_stream.dart';
import '../interface/mediadevices.dart';
import 'media_stream_impl.dart';
import 'utils.dart';

class MediaDeviceNative extends MediaDevices {
  /// A subscription on events from a [Stream].
  StreamSubscription<dynamic>? _eventSubscription;

  /// Initiates subscription on the 'FlutterWebRTC/OnMediaChangeNotifier'
  /// channel. Listens to if a media device has been added to or removed from
  /// the system.
  void initSubscription() {
    _eventSubscription = EventChannel('FlutterWebRTC/OnMediaChangeNotifier')
        .receiveBroadcastStream()
        .listen(eventListener, onError: errorListener);
  }

  /// Event receiving success handler.
  void eventListener(dynamic event) {
    final Map<dynamic, dynamic> map = event;
    switch (map['event']) {
      case 'mediaDeviceChanged':
        if (onDeviceChange != null) {
          onDeviceChange!();
        }
        break;
    }
  }

  /// Event receiving error handler.
  void errorListener(Object obj) {
    if (obj is Exception) {
      throw obj;
    }
  }

  @override
  Future<MediaStream> getUserMedia(
      Map<String, dynamic> mediaConstraints) async {
    try {
      final response = await WebRTC.invokeMethod(
        'getUserMedia',
        <String, dynamic>{'constraints': mediaConstraints},
      );
      if (response == null) {
        throw Exception('getUserMedia return null, something wrong');
      }

      String streamId = response['streamId'];
      var stream = MediaStreamNative(streamId, 'local');
      stream.setMediaTracks(
          response['audioTracks'] ?? [], response['videoTracks'] ?? []);
      return stream;
    } on PlatformException catch (e) {
      throw 'Unable to getUserMedia: ${e.message}';
    }
  }

  @override
  Future<MediaStream> getDisplayMedia(
      Map<String, dynamic> mediaConstraints) async {
    try {
      final response = await WebRTC.invokeMethod(
        'getDisplayMedia',
        <String, dynamic>{'constraints': mediaConstraints},
      );
      if (response == null) {
        throw Exception('getDisplayMedia return null, something wrong');
      }
      String streamId = response['streamId'];
      var stream = MediaStreamNative(streamId, 'local');
      stream.setMediaTracks(response['audioTracks'], response['videoTracks']);
      return stream;
    } on PlatformException catch (e) {
      throw 'Unable to getDisplayMedia: ${e.message}';
    }
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
              kind: e['kind'],
              label: e['label']),
        )
        .toList();
  }
}
