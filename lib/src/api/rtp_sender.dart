import 'package:flutter/services.dart';
import 'package:flutter_webrtc/src/api/utils/channel_name_generator.dart';
import 'package:flutter_webrtc/src/universal/media_stream_track.dart';

class RtpSender {
  RtpSender(int channelId) {
    _methodChannel = MethodChannel(channelNameWithId('RtpSender', channelId));
  }

  MediaStreamTrack? _track;

  late MethodChannel _methodChannel;

  MediaStreamTrack? get track => _track;

  Future<void> setTrack(MediaStreamTrack? t) async {
    _track = t;
    await _methodChannel.invokeMethod('setTrack', {'trackId': t?.id()});
  }
}
