import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_webrtc/src/model/constraints.dart';
import 'package:flutter_webrtc/src/model/ice.dart';
import 'package:flutter_webrtc/src/model/peer.dart';
import 'package:flutter_webrtc/src/model/track.dart';
import 'package:flutter_webrtc/src/model/transceiver.dart';

class PeerConnectionSample extends StatefulWidget {
  static String tag = 'peer_connection_sample';

  @override
  _PeerConnectionSampleState createState() => _PeerConnectionSampleState();
}

class _PeerConnectionSampleState extends State<PeerConnectionSample> {
  String text = 'Press call button to test create PeerConnection';
  MediaStreamTrack? _track;
  @override
  void initState() {
    super.initState();
  }

  final Map<String, dynamic> defaultSdpConstraints = {
    'mandatory': {},
    'optional': [],
  };

  void _create_peer() async {
    try {
      final caps = DeviceConstraints();
      caps.video.mandatory = DeviceVideoConstraints();
      caps.video.mandatory!.width = 640;
      caps.video.mandatory!.height = 480;
      caps.video.mandatory!.fps = 30;
      caps.video.mandatory!.facingMode = FacingMode.user;

      _track = (await getUserMedia(caps))[0];

      var server =
          IceServer(['stun:stun.l.google.com:19302'], 'username', 'password');
      var pc1 = await PeerConnection.create(IceTransportType.all, [server]);
      var pc2 = await PeerConnection.create(IceTransportType.all, [server]);

      final icecb = (IceConnectionState state) {
        print(state.toString());
      };

      final pccb = (PeerConnectionState state) {
        print(state.toString());
      };

      pc1.onIceConnectionStateChange(icecb);
      pc2.onIceConnectionStateChange(icecb);

      pc1.onConnectionStateChange(pccb);
      pc2.onConnectionStateChange(pccb);

      pc1.onIceCandidateError((p0) {
        print(p0.errorText);
      });
      pc2.onIceCandidateError((p0) {
        print(p0.errorText);
      });

      var trans = await pc1.addTransceiver(
          MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));

      await trans.sender.replaceTrack(_track!);

      var offer = await pc1.createOffer();
      await pc1.setLocalDescription(offer);
      await pc2.setRemoteDescription(offer);

      var answer = await pc2.createAnswer();
      await pc2.setLocalDescription(answer);
      await pc1.setRemoteDescription(answer);

      pc1.onIceCandidate((IceCandidate candidate) async {
        print(candidate.candidate.toString());
        await pc2.addIceCandidate(candidate);
      });

      pc2.onIceCandidate((IceCandidate candidate) async {
        print(candidate.candidate.toString());
        await pc1.addIceCandidate(candidate);
      });

      setState(() {
        text = 'test is success';
      });
    } catch (e) {
      setState(() {
        text = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PeerConnection'),
      ),
      body: Center(child: Text(text)),
      floatingActionButton: FloatingActionButton(
        onPressed: _create_peer,
        child: Icon(Icons.phone),
      ),
    );
  }
}
