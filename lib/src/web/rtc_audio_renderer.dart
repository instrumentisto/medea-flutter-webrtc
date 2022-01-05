import 'dart:html' as html;

import 'package:flutter_webrtc/src/interface/media_stream_track.dart';
import 'package:flutter_webrtc/src/interface/rtc_audio_renderer.dart';
import 'package:flutter_webrtc/src/web/media_stream_track_impl.dart';
import 'package:js/js_util.dart' as jsutil;

class AudioRendererWeb extends AudioRenderer {
  AudioRendererWeb() : _id = _textureCounter++;

  static const _elementIdForAudioManager = 'html_webrtc_audio_manager_list';

  html.AudioElement? _element;

  MediaStreamTrackWeb? _src;

  bool _muted = false;

  final int _id;

  String get _elementId => 'audio-renderer-$_id';

  static int _textureCounter = 1;

  MediaStreamTrack? _srcObject;

  @override
  Future<bool> audioOutput(String deviceId) async {
    try {
      final element = _element;
      if (null != element && jsutil.hasProperty(element, 'setSinkId')) {
        await jsutil.promiseToFuture<void>(
            jsutil.callMethod(element, 'setSinkId', [deviceId]));

        return true;
      }
    } catch (e) {
      print('Unable to setSinkId: ${e.toString()}');
    }
    return false;
  }

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
  set muted(bool mute) => _element?.muted = _muted = mute;

  @override
  MediaStreamTrack? get srcObject => _srcObject;

  @override
  set srcObject(MediaStreamTrack? srcObject) {
    if (_srcObject == null) {
      _element?.srcObject = null;
      _srcObject = null;
      return;
    }
    if (srcObject!.kind != 'audiooutput') {
      throw Exception("MediaStreamTracks with video kind isn't supported in AudioRenderer");
    }

    _srcObject = srcObject as MediaStreamTrackWeb;

    var stream = html.MediaStream();
    stream.addTrack(srcObject.jsTrack);

    if (_element == null) {
      _element = html.AudioElement()
        ..id = _elementId
        ..muted = _muted
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
}