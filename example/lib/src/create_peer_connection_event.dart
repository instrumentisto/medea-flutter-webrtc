import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'dart:async';

import 'package:flutter/services.dart';


class PeerConnectionSampleEvent extends StatefulWidget {
  static String tag = 'peer_connection_track_event';

  @override
  _PeerConnectionSampleEvent createState() => _PeerConnectionSampleEvent();
}

class _PeerConnectionSampleEvent extends State<PeerConnectionSampleEvent> {
  String text = 'Press call button to test create PeerConnection';

  @override
  void initState() {
    super.initState();
  }

  final Map<String, dynamic> defaultSdpConstraints = {
    'mandatory': {},
    'optional': [],
  };

  void eventListener(dynamic event) {
    print(event.toString());
  }

  void errorListener(Object obj) {
    if (obj is Exception) throw obj;
  }

  void _create_peer() async {
    try {
      var pc1 = await createPeerConnection({});
      var init = RTCRtpTransceiverInit();
      init.direction = TransceiverDirection.SendRecv;

      var trans = await pc1.addTransceiver(
        kind: RTCRtpMediaType.RTCRtpMediaTypeVideo, init: init);

      // var pc2 = await createPeerConnection({});

      // var offer = await pc1.createOffer();
      // await pc1.setLocalDescription(offer);
      // await pc2.setRemoteDescription(offer);

      // var answer = await pc2.createAnswer({});
      // await pc2.setLocalDescription(answer);
      // await pc1.setRemoteDescription(answer);

      setState(() {
        text = 'test is success';
      });

    } catch (e) {
      print(e.toString());
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
