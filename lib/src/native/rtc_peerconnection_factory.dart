import 'dart:async';

import '../interface/navigator.dart';
import '../interface/rtc_peerconnection.dart';
import '../interface/rtc_video_renderer.dart';
import '../interface/rtc_audio_renderer.dart';
import 'factory_impl.dart';

Future<RTCPeerConnection> createPeerConnection(
    Map<String, dynamic> configuration,
    [Map<String, dynamic> constraints = const {}]) async {
  return RTCFactoryNative.instance
      .createPeerConnection(configuration, constraints);
}

VideoRenderer videoRenderer() {
  return RTCFactoryNative.instance.videoRenderer();
}

AudioRenderer audioRenderer() {
  return RTCFactoryNative.instance.audioRenderer();
}

Navigator get navigator => RTCFactoryNative.instance.navigator;
