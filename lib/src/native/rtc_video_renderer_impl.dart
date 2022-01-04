import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_webrtc/src/interface/media_stream_track.dart';

import '../interface/rtc_video_renderer.dart';
import 'utils.dart';

class RTCVideoRendererNative extends VideoRenderer {
  RTCVideoRendererNative();
  int? _textureId;
  MediaStreamTrack? _srcObject;
  StreamSubscription<dynamic>? _eventSubscription;

  @override
  Future<void> initialize() async {
    final response = await WebRTC.invokeMethod('createVideoRenderer', {});
    _textureId = response['textureId'];
    _eventSubscription = EventChannel('FlutterWebRTC/Texture$textureId')
        .receiveBroadcastStream()
        .listen(eventListener, onError: errorListener);
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
    if (textureId == null) throw 'Renderer should be initialize before setting src';

    _srcObject = track;
    WebRTC.invokeMethod('videoRendererSetSrcObject', <String, dynamic>{
      'textureId': textureId,
      'trackId': track?.id ?? '',
    }).then((_) {
      value = (track == null)
          ? RTCVideoValue.empty
          : value.copyWith(renderVideo: renderVideo);
    });
  }

  @override
  Future<void> dispose() async {
    await _eventSubscription?.cancel();
    await WebRTC.invokeMethod(
      'videoRendererDispose',
      <String, dynamic>{'textureId': _textureId},
    );

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
