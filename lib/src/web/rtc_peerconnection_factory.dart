import 'dart:async';

import 'package:flutter_webrtc/src/interface/rtc_audio_renderer.dart';
import '../interface/navigator.dart';
import '../interface/rtc_peerconnection.dart';
import '../interface/rtc_video_renderer.dart';
import 'factory_impl.dart';

Future<RTCPeerConnection> createPeerConnection(
    Map<String, dynamic> configuration,
    [Map<String, dynamic>? constraints]) {
  return RTCFactoryWeb.instance
      .createPeerConnection(configuration, constraints);
}

VideoRenderer videoRenderer() {
  return RTCFactoryWeb.instance.videoRenderer();
}

AudioRenderer audioRenderer() {
  return RTCFactoryWeb.instance.audioRenderer();
}

Navigator get navigator => RTCFactoryWeb.instance.navigator;
