import 'package:flutter_webrtc/src/interface/enums.dart';

typedef StreamTrackCallback = Function();

abstract class MediaStreamTrack {
  MediaStreamTrack();

  /// Returns the unique identifier of the track
  String? get id;

  /// This may label audio and video sources (e.g., "Internal microphone" or
  /// "External USB Webcam").
  ///
  /// Returns the label of the object's corresponding source, if any.
  /// If the corresponding source has or had no label, returns an empty string.
  String? get label;

  /// Returns the string 'audio' if this object represents an audio track
  /// or 'video' if this object represents a video track.
  String? get kind;

  /// Callback for onmute event
  StreamTrackCallback? onMute;

  /// Callback for unmute event
  StreamTrackCallback? onUnMute;

  /// Callback foronended event
  StreamTrackCallback? onEnded;

  /// Returns the enable state of [MediaStreamTrack]
  bool get enabled;

  /// Set the enable state of [MediaStreamTrack]
  ///
  /// Note: After a [MediaStreamTrack] has ended, setting the enable state
  /// will not change the ended state.
  set enabled(bool b);

  /// Returns true if the track is muted, and false otherwise.
  bool? get muted;

  /// Returns a map containing the set of constraints most recently established
  /// for the track using a prior call to applyConstraints().
  ///
  /// These constraints indicate values and ranges of values that the Web site
  /// or application has specified are required or acceptable for the included
  /// constrainable properties.
  Map<String, dynamic> getConstraints() {
    throw UnimplementedError();
  }

  Future<void> stop();

  //
  // https://developer.mozilla.org/en-US/docs/Web/API/MediaStreamTrack/getSettings
  //
  Map<dynamic, dynamic> getSettings() => throw UnimplementedError();

  String? deviceId() => throw UnimplementedError();

  Future<MediaStreamTrackReadyState> readyState() {
    throw UnimplementedError();
  }

  @Deprecated('use stop() instead')
  Future<void> dispose();

  @override
  String toString() {
    return 'Track(id: $id, kind: $kind, label: $label, enabled: $enabled, muted: $muted)';
  }
}
