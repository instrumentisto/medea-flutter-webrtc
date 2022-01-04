import 'dart:async';
import 'dart:html' as html;

import 'package:flutter_webrtc/flutter_webrtc.dart';

class MediaStreamTrackWeb extends MediaStreamTrack {
  MediaStreamTrackWeb(this.jsTrack) {
    jsTrack.onEnded.listen((event) => onEnded?.call());
    jsTrack.onMute.listen((event) => onMute?.call());
    jsTrack.onUnmute.listen((event) => onUnMute?.call());
  }

  final html.MediaStreamTrack jsTrack;

  @override
  String? get id => jsTrack.id;

  @override
  String? get kind => jsTrack.kind;

  @override
  String? get label => jsTrack.label;

  @override
  bool get enabled => jsTrack.enabled ?? false;

  @override
  bool? get muted => jsTrack.muted;

  @override
  set enabled(bool? b) {
    jsTrack.enabled = b;
  }

  @override
  Map<String, dynamic> getConstraints() {
    return jsTrack.getConstraints() as Map<String, dynamic>;
  }

  @override
  Map<String, dynamic> getSettings() {
    return jsTrack.getSettings() as Map<String, dynamic>;
  }

  @override
  Future<MediaStreamTrackReadyState> readyState() async {
    return typeStringToMediaStreamTrackState[jsTrack.readyState!]!;
  }

  @override
  Future<void> dispose() async {
    return stop();
  }

  @override
  Future<void> stop() async {
    jsTrack.stop();
  }
}
