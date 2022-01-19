import 'package:flutter/services.dart';
import 'package:flutter_webrtc/src/api/media_stream_track.dart';

class RtpSender {
  RtpSender(String channelId) {
    _methodChannel = MethodChannel(channelId);
  }

  MediaStreamTrack? track;

  late MethodChannel _methodChannel;

  MediaStreamTrack? getTrack() {
    return track;
  }

  Future<void> setTrack(MediaStreamTrack? t) async {
    track = t;
    await _methodChannel.invokeMethod('setTrack', {'trackId': t?.id()});
  }
}
