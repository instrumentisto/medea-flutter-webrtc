import 'dart:async';
import 'dart:html' as html;

import '/src/model/media_stream_track_state.dart';
import '../media_stream_track.dart';

class WebMediaStreamTrack extends MediaStreamTrack {
  WebMediaStreamTrack(this.jsTrack);

  final html.MediaStreamTrack jsTrack;

  // TODO(#31): Fix deviceId functional for Web
  @override
  String deviceId() {
    return jsTrack.id!;
  }

  @override
  String id() {
    return jsTrack.id!;
  }

  @override
  bool isEnabled() {
    return jsTrack.enabled ?? false;
  }

  @override
  MediaKind kind() {
    var jsKind = jsTrack.kind;
    if (jsKind == 'audio') {
      return MediaKind.audio;
    } else {
      return MediaKind.video;
    }
  }

  @override
  Future<void> setEnabled(bool enabled) async {
    jsTrack.enabled = enabled;
  }

  @override
  Future<void> stop() async {
    jsTrack.stop();
  }

  @override
  Future<void> dispose() async {}

  @override
  Future<MediaStreamTrack> clone() async {
    return WebMediaStreamTrack(jsTrack.clone());
  }
}
