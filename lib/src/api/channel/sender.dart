import 'package:flutter/services.dart';

import '/src/platform/track.dart';
import 'channel.dart';

/// [RTCSender][1] implementation.
///
/// [1]: https://w3.org/TR/webrtc#dom-rtcrtpsender
class RtpSender {
  /// Creates an [RtpSender] basing on the [Map] received from the native side.
  RtpSender.fromMap(dynamic map) {
    _chan = methodChannel('RtpSender', map['channelId']);
  }

  /// Current [MediaStreamTrack] of this [RtpSender].
  MediaStreamTrack? _track;

  /// Getter for the [MediaStreamTrack] currently owned by this [RtpSender].
  MediaStreamTrack? get track => _track;

  /// Replaces [MediaStreamTrack] of this [RtpSender].
  Future<void> replaceTrack(MediaStreamTrack? t) async {
    _track = t;
    await _chan.invokeMethod('replaceTrack', {'trackId': t?.id()});
  }

  /// [MethodChannel] used for the messaging with the native side.
  late MethodChannel _chan;
}
