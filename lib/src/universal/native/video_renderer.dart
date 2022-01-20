import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_webrtc/src/api/utils/channel_name_generator.dart';

import '../media_stream_track.dart';
import '../video_renderer.dart';

const videoRendererFactoryMethodChannel = MethodChannel('$CHANNEL_TAG/VideoRendererFactory');

class NativeVideoRenderer extends VideoRenderer {
  NativeVideoRenderer();
  int? _textureId;
  MediaStreamTrack? _srcObject;
  StreamSubscription<dynamic>? _eventSubscription;
  late MethodChannel _methodChannel;

  @override
  Future<void> initialize() async {
    final response = await videoRendererFactoryMethodChannel.invokeMethod('create');
    _textureId = response['channelId'];
    _eventSubscription = EventChannel('$CHANNEL_TAG/VideoRendererEvent/$_textureId')
        .receiveBroadcastStream()
        .listen(eventListener, onError: errorListener);
    _methodChannel = MethodChannel('$CHANNEL_TAG/VideoRenderer/$_textureId');
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
    // TODO(evdokimovs): Dispose VideoRenderer on native side.
    // await WebRTC.invokeMethod(
    //   'videoRendererDispose',
    //   <String, dynamic>{'textureId': _textureId},
    // );

    return super.dispose();
  }

  void eventListener(dynamic event) {
    final Map<dynamic, dynamic> map = event;
    switch (map['event']) {
      case 'didTextureChangeRotation':
        value =
            value.copyWith(rotation: map['rotation'], renderVideo: renderVideo);
        onResize?.call();
        break;
      case 'didTextureChangeVideoSize':
        value = value.copyWith(
            width: 0.0 + map['width'],
            height: 0.0 + map['height'],
            renderVideo: renderVideo);
        onResize?.call();
        break;
      case 'didFirstFrameRendered':
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
