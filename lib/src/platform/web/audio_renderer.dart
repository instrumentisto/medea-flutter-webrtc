import 'dart:html' as html;

import '/src/model/track.dart';
import '/src/platform/audio_renderer.dart';
import '/src/platform/track.dart';
import '/src/platform/web/media_stream_track.dart';

// ignore_for_file: avoid_web_libraries_in_flutter

AudioRenderer createPlatformSpecificAudioRenderer() {
  return AudioRendererWeb();
}

class AudioRendererWeb extends AudioRenderer {
  AudioRendererWeb() : _id = _textureCounter++;

  static const _elementIdForAudioManager = 'html_webrtc_audio_manager_list';

  html.AudioElement? _element;

  WebMediaStreamTrack? _src;

  final int _id;

  String get _elementId => 'audio-renderer-$_id';

  static int _textureCounter = 1;

  MediaStreamTrack? _srcObject;

  @override
  Future<void> dispose() async {
    await _src?.dispose();
    _src = null;
    _element?.srcObject = null;
    final audioManager = html.document.getElementById(_elementIdForAudioManager)
        as html.DivElement?;
    if (audioManager != null && !audioManager.hasChildNodes()) {
      audioManager.remove();
    }
  }

  @override
  MediaStreamTrack? get srcObject => _srcObject;

  @override
  set srcObject(MediaStreamTrack? srcObject) {
    if (_srcObject == null) {
      _element?.srcObject = null;
      _srcObject = null;
      return;
    }
    if (srcObject!.kind() != MediaKind.audio) {
      throw Exception(
          "MediaStreamTracks with video kind isn't supported in AudioRenderer");
    }

    _srcObject = srcObject as WebMediaStreamTrack;

    var stream = html.MediaStream();
    stream.addTrack(srcObject.jsTrack);

    if (_element == null) {
      _element = html.AudioElement()
        ..id = _elementId
        ..autoplay = true;
      _ensureAudioManagerDiv().append(_element!);
    }
    _element!.srcObject = stream;
  }

  html.DivElement _ensureAudioManagerDiv() {
    var div = html.document.getElementById(_elementIdForAudioManager);
    if (null != div) return div as html.DivElement;

    div = html.DivElement()
      ..id = _elementIdForAudioManager
      ..style.display = 'none';
    html.document.body?.append(div);
    return div as html.DivElement;
  }

  @override
  Future<void> initialize() => Future.value();
}
