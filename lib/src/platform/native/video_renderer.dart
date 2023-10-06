import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

import 'package:flutter/services.dart';

import '../../api/bridge.g.dart' show TextureEvent;
import '../../api/peer.dart';
import '/src/api/channel.dart';
import '/src/model/track.dart';
import '/src/platform/track.dart';
import '/src/platform/video_renderer.dart';

/// Creates a new [NativeVideoRenderer].
VideoRenderer createPlatformSpecificVideoRenderer() {
  if (isDesktop) {
    return _NativeVideoRendererFFI();
  } else {
    return _NativeVideoRendererChannel();
  }
}

/// [MethodChannel] for factory used for the messaging with the native side.
final _rendererFactoryChannel = methodChannel('VideoRendererFactory', 0);

/// [VideoRenderer] implementation for the native platform.
abstract class NativeVideoRenderer extends VideoRenderer {
  /// Unique ID for the texture on which video will be rendered.
  int? _textureId;

  /// Unique ID of the channel for the native side `VideoRenderer`.
  late int _channelId;

  /// Currently rendering [MediaStreamTrack].
  MediaStreamTrack? _srcObject;

  /// Subscription to the events of this [NativeVideoRenderer].
  StreamSubscription<dynamic>? _eventChan;

  /// Subscription to the events of this [NativeVideoRenderer].
  ReceivePort? _eventPort;

  /// [MethodChannel] for the [NativeVideoRenderer] used for the messaging with
  /// the native side.
  late MethodChannel _chan;

  @override
  int get videoRotatedWidth {
    if (isDesktop) {
      return value.width.toInt();
    }
    return value.rotation % 180 == 0
        ? value.width.toInt()
        : value.height.toInt();
  }

  @override
  int get videoRotatedHeight {
    if (isDesktop) {
      return value.height.toInt();
    }
    return value.rotation % 180 == 0
        ? value.height.toInt()
        : value.width.toInt();
  }

  @override
  int get videoWidth => value.width.toInt();

  @override
  int get videoHeight => value.height.toInt();

  @override
  int get quarterTurnsRotation => value.quarterTurnsRotation;

  @override
  int? get textureId => _textureId;

  @override
  MediaStreamTrack? get srcObject => _srcObject;

  @override
  set mirror(bool mirror) {
    // No-op. Mirroring is done through [VideoView].
  }

  /// Listener for the [NativeVideoRenderer] events received from the native
  /// side.
  void eventListener(dynamic event) {
    final dynamic values = event;
    TextureEvent? textureEvent;
    if (values[0] != null) {
      textureEvent =
          TextureEvent.values.firstWhere((e) => e.index == values[0]);
    }
    switch (textureEvent ?? values['event']) {
      case TextureEvent.onTextureChange || 'onTextureChange':
        var rotation = values[2] ?? values['rotation'];
        var width = 0.0 + (values[3] ?? values['width']);
        var height = 0.0 + (values[4] ?? values['height']);

        var newWidth = rotation % 180 == 0 ? width : height;
        var newHeight = rotation % 180 == 0 ? height : width;

        width = newWidth;
        height = newHeight;

        value = value.copyWith(
          rotation: rotation,
          width: width,
          height: height,
          renderVideo: renderVideo,
        );

        onResize?.call();
        break;
      case TextureEvent.onFirstFrameRendered || 'onFirstFrameRendered':
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

/// [MethodChannel]-based implementation of a [NativeVideoRenderer].
class _NativeVideoRendererChannel extends NativeVideoRenderer {
  @override
  Future<void> initialize() async {
    final response = await _rendererFactoryChannel.invokeMethod('create');
    _textureId = response['textureId'];
    _channelId = response['channelId'];
    _eventChan = eventChannel('VideoRendererEvent', _channelId)
        .receiveBroadcastStream()
        .listen(eventListener, onError: errorListener);
    _chan = methodChannel('VideoRenderer', _channelId);
  }

  @override
  Future<void> setSrcObject(MediaStreamTrack? track) async {
    if (textureId == null) {
      throw 'Renderer should be initialize before setting src';
    }
    if (track != null && track.kind() != MediaKind.video) {
      throw 'VideoRenderer do not supports MediaStreamTrack with audio kind!';
    }
    _srcObject = track;

    await _chan.invokeMethod('setSrcObject', {
      'trackId': track?.id(),
    });

    value = (track == null)
        ? RTCVideoValue.empty
        : value.copyWith(renderVideo: renderVideo);
  }

  @override
  Future<void> dispose() async {
    _eventPort?.close();
    await _eventChan?.cancel();
    await _chan.invokeMethod('dispose');
    await super.dispose();
  }
}

/// FFI-based implementation of a [NativeVideoRenderer].
class _NativeVideoRendererFFI extends NativeVideoRenderer {
  @override
  Future<void> initialize() async {
    _eventPort = ReceivePort()..listen(eventListener);

    final response = await _rendererFactoryChannel.invokeMethod('create', {
      'port': _eventPort!.sendPort.nativePort,
      'dart_api': NativeApi.initializeApiDLData.address
    });
    _textureId = response['textureId'];
    _chan = methodChannel('VideoRendererFactory', 0);

    int? channelId = response['channelId'];
    if (channelId != null) {
      _eventChan = eventChannel('VideoRendererEvent', _channelId)
          .receiveBroadcastStream()
          .listen(eventListener, onError: errorListener);
    }

    _channelId = channelId ?? 0;
  }

  @override
  Future<void> setSrcObject(MediaStreamTrack? track) async {
    if (textureId == null) {
      throw 'Renderer should be initialize before setting src';
    }
    if (track != null && track.kind() != MediaKind.video) {
      throw 'VideoRenderer do not supports MediaStreamTrack with audio kind!';
    }

    _srcObject = track;
    var sinkId = textureId ?? 0;
    if (track == null) {
      api!.disposeVideoSink(sinkId: sinkId);
      value = RTCVideoValue.empty;
    } else {
      var handler =
          await _chan.invokeMethod('createFrameHandler', <String, dynamic>{
        'textureId': textureId,
      });

      var trackId = track.id();
      await api!
          .createVideoSink(
              sinkId: sinkId,
              trackId: trackId,
              callbackPtr: handler['handler_ptr'],
              port: _eventPort!.sendPort.nativePort,
              textureId: textureId ?? 0,
              touchDartApi: '')
          .then((_) => {value = value.copyWith(renderVideo: renderVideo)});
    }
  }

  @override
  Future<void> dispose() async {
    _eventPort?.close();
    await _eventChan?.cancel();
    await setSrcObject(null);
    await _chan.invokeMethod('dispose', {'textureId': textureId});
    await super.dispose();
  }
}
