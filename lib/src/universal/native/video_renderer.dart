import 'dart:async';

import 'package:flutter/services.dart';

import '/src/api/utils/channel_name_generator.dart';
import '/src/model/media_stream_track_state.dart';
import '/src/universal/media_stream_track.dart';
import '/src/universal/video_renderer.dart';

/// Cretes new [NativeVideoRenderer].
VideoRenderer createPlatformSpecificVideoRenderer() {
  return NativeVideoRenderer();
}

/// [MethodChannel] for factory used for the messaging with a native side.
const videoRendererFactoryMethodChannel =
    MethodChannel('$channelTag/VideoRendererFactory');

/// [VideoRenderer] implementation for the native.
class NativeVideoRenderer extends VideoRenderer {
  NativeVideoRenderer();

  /// Unique ID for the texture on which video will be rendered.
  int? _textureId;

  /// Unique ID of the channel for the native side `VideoRenderer`.
  late int _channelId;

  /// Currently rendering [MediaStreamTrack].
  MediaStreamTrack? _srcObject;

  /// Subscription to the events of this [NativeVideoRenderer].
  StreamSubscription<dynamic>? _eventSubscription;

  /// [MethodChannel] for the [NativeVideoRenderer] used for the messaging
  /// with a native side.
  late MethodChannel _methodChannel;

  @override
  Future<void> initialize() async {
    final response =
        await videoRendererFactoryMethodChannel.invokeMethod('create');
    _textureId = response['textureId'];
    _channelId = response['channelId'];
    _eventSubscription =
        EventChannel('$channelTag/VideoRendererEvent/$_channelId')
            .receiveBroadcastStream()
            .listen(eventListener, onError: errorListener);
    _methodChannel = MethodChannel('$channelTag/VideoRenderer/$_channelId');
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
    if (track?.kind() != MediaKind.video) {
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

  /// Listener for the [NativeVideoRenderer] events received from the native
  /// side.
  void eventListener(dynamic event) {
    final dynamic map = event;
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

  /// Listener for the errors of the native event channel.
  void errorListener(Object obj) {
    if (obj is Exception) {
      throw obj;
    }
  }

  @override
  bool get renderVideo => srcObject != null;
}
