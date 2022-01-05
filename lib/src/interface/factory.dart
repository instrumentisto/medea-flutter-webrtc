import 'package:flutter_webrtc/src/interface/rtc_audio_renderer.dart';

import 'navigator.dart';
import 'rtc_peerconnection.dart';
import 'rtc_video_renderer.dart';

abstract class RTCFactory {
  Future<RTCPeerConnection> createPeerConnection(
      Map<String, dynamic> configuration,
      [Map<String, dynamic> constraints]);

  Navigator get navigator;

  VideoRenderer videoRenderer();

  AudioRenderer audioRenderer();
}
