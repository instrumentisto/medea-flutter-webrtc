import 'package:flutter/services.dart';

import '/src/api/utils/channel_name_generator.dart';
import '/src/universal/media_stream_track.dart';

class RtpSender {
  /// Creates [RtpSender] based on the [Map] received from the native side.
  RtpSender.fromMap(Map<String, dynamic> map) {
    _methodChannel =
        MethodChannel(channelNameWithId('RtpSender', map['channelId']));
  }

  /// Current [MediaStreamTrack] of this [RtpSender].
  MediaStreamTrack? _track;

  /// [MethodChannel] used for the messaging with a native side.
  late MethodChannel _methodChannel;

  /// Getter for the [MediaStreamTrack] currently owned by this [RtpSender].
  MediaStreamTrack? get track => _track;

  /// Replaces [MediaStreamTrack] of this [RtpSender].
  Future<void> replaceTrack(MediaStreamTrack? t) async {
    _track = t;
    await _methodChannel.invokeMethod('replaceTrack', {'trackId': t?.id()});
  }
}
