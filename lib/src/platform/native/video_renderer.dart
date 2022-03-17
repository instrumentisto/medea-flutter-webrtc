import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import '/src/api/channel.dart';
import '/src/model/track.dart';
import '/src/platform/track.dart';
import '/src/platform/video_renderer.dart';
import '../../api/utils.dart';


/// Creates a new [NativeVideoRenderer].
VideoRenderer createPlatformSpecificVideoRenderer() {
  return NativeVideoRenderer();
}

/// [MethodChannel] for factory used for the messaging with the native side.
final _rendererFactoryChannel = methodChannel('VideoRendererFactory', 0);

/// [VideoRenderer] implementation for the native platform.
class NativeVideoRenderer extends VideoRenderer {
  NativeVideoRenderer();

  /// Unique ID for the texture on which video will be rendered.
  int? _textureId;

  /// Unique ID of the channel for the native side `VideoRenderer`.
  late int _channelId;

  /// Currently rendering [MediaStreamTrack].
  MediaStreamTrack? _srcObject;

  /// Subscription to the events of this [NativeVideoRenderer].
  StreamSubscription<dynamic>? _eventChan;

  /// [MethodChannel] for the [NativeVideoRenderer] used for the messaging with
  /// the native side.
  late MethodChannel _chan;

  @override
  Future<void> initialize() async {
      final response = await _rendererFactoryChannel.invokeMethod('create');
      _textureId = response['textureId'];
      _channelId = response['channelId'];
      _eventChan = eventChannel('VideoRendererEvent', _channelId)
          .receiveBroadcastStream()
          .listen(eventListener, onError: errorListener);
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        // todo recheck
        _chan = methodChannel('VideoRendererFactory', 0);
      } else {
        _chan = methodChannel('VideoRenderer', _channelId);
      }
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

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      var sinkId = textureId ?? 0;
      if (track == null) {
        api
            .disposeVideoSink(sinkId: sinkId)
            .then((_) => {value = RTCVideoValue.empty});
      } else {
        _chan.invokeMethod('createCallback', <String, dynamic>{
          'textureId': textureId,
        }).then((result) {
          var trackId = int.parse(track.id());
          api
              .createVideoSink(
                  sinkId: sinkId,
                  trackId: trackId,
                  callbackPtr: result['handler_ptr'])
              .then((_) => {value = value.copyWith(renderVideo: renderVideo)});
        });
      }
    } else {
      _chan.invokeMethod('setSrcObject', {
        'trackId': track?.id(),
      }).then((_) {
        value = (track == null)
            ? RTCVideoValue.empty
            : value.copyWith(renderVideo: renderVideo);
      });
    }

  }

  @override
  Future<void> dispose() async {
    await _eventChan?.cancel();
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await _chan.invokeMethod('dispose', {'textureId': textureId});
    }
    else {
      await _chan.invokeMethod('dispose');
    }
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
