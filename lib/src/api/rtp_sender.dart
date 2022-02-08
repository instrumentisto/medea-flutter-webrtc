import 'package:flutter/services.dart';

import 'package:flutter_webrtc/src/api/utils/channel_name_generator.dart';
import 'package:flutter_webrtc/src/universal/media_stream_track.dart';

class RtpSender {
  /// Creates [RtpSender] based on the [Map] received from the native side.
  RtpSender.fromMap(dynamic map) {
    _methodChannel =
        MethodChannel(channelNameWithId('RtpSender', map['channelId']));
  }

  /// Current [MediaStreamTrack] of this [RtpSender].
  MediaStreamTrack? _track;

  /// [MethodChannel] used for the messaging with a native side.
  late MethodChannel _methodChannel;

  /// Getter for the [MediaStreamTrack] currently owned by this [RtpSender].
  MediaStreamTrack? get track => _track;

  /// Sets [MediaStreamTrack] for this [RtpSender].
  Future<void> setTrack(MediaStreamTrack? t) async {
    _track = t;
    await _methodChannel.invokeMethod('setTrack', {'trackId': t?.id()});
  }
}
