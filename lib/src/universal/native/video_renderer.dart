import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_webrtc/src/api/utils/channel_name_generator.dart';
import 'package:flutter_webrtc/src/model/media_kind.dart';

import '../media_stream_track.dart';
import '../video_renderer.dart';

const videoRendererFactoryMethodChannel = MethodChannel('$CHANNEL_TAG/VideoRendererFactory');

class NativeVideoRenderer extends VideoRenderer {
  NativeVideoRenderer();
  int? _textureId;
  late int _channelId;
  MediaStreamTrack? _srcObject;
  StreamSubscription<dynamic>? _eventSubscription;
  late MethodChannel _methodChannel;

  @override
  Future<void> initialize() async {
    final response = await videoRendererFactoryMethodChannel.invokeMethod('create');
    _textureId = response['textureId'];
    _channelId = response['channelId'];
    _eventSubscription = EventChannel('$CHANNEL_TAG/VideoRendererEvent/$_channelId')
        .receiveBroadcastStream()
        .listen(eventListener, onError: errorListener);
    _methodChannel = MethodChannel('$CHANNEL_TAG/VideoRenderer/$_channelId');
  }

  @override
  int get videoWidth => value.width.toInt();

  @override
  int get videoHeight => value.height.toInt();

  @override
  int? get textureId => _textureId;

  @override
  MediaStreamTrack? get srcObject => _srcObject;

  @override
  set mirror(bool mirror) {
    // No-op. Mirroring is done through [RTCViewView].
  }

  @override
  set srcObject(MediaStreamTrack? track) {
    if (textureId == null) {
      throw 'Renderer should be initialize before setting src';
    }
    if (track?.kind() != MediaKind.Video) {
      throw 'VideoRenderer do not supports MediaStreamTrack with video kind!';
    }

    _srcObject = track;
    _methodChannel.invokeMethod('setSrcObject', {
      'trackId': track?.id(),
    }).then((_) {
      value = (track == null)
          ? RTCVideoValue.empty
          : value.copyWith(renderVideo: renderVideo);
    });
  }

  @override
  Future<void> dispose() async {
    await _eventSubscription?.cancel();
    await _methodChannel.invokeMethod('dispose');

    await super.dispose();
  }

  void eventListener(dynamic event) {
    final Map<dynamic, dynamic> map = event;
    switch (map['event']) {
      case 'onTextureChangeRotation':
        value =
            value.copyWith(rotation: map['rotation'], renderVideo: renderVideo);
        onResize?.call();
        break;
      case 'onTextureChangeVideoSize':
        value = value.copyWith(
            width: 0.0 + map['width'],
            height: 0.0 + map['height'],
            renderVideo: renderVideo);
        onResize?.call();
        break;
      case 'onFirstFrameRendered':
        value = value.copyWith(renderVideo: renderVideo);
        break;
    }
  }

  void errorListener(Object obj) {
    if (obj is Exception) {
      throw obj;
    }
  }

  @override
  bool get renderVideo => srcObject != null;
}
