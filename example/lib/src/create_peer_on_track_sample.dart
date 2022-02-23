import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'dart:async';

class PeerOnTrackSample extends StatefulWidget {
  static String tag = 'peer_connection_sample';

  @override
  _PeerOnTrackSample createState() => _PeerOnTrackSample();
}

class _PeerOnTrackSample extends State<PeerOnTrackSample> {
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

      await pc1.addTransceiver(
        kind: RTCRtpMediaType.RTCRtpMediaTypeVideo, init: init);
      var pc2 = await createPeerConnection({});
      var complete = Future.delayed(const Duration(seconds: 5)).then((value) => 'Fail onTrack');
      var complete_ended = Future.delayed(const Duration(seconds: 5)).then((value) => 'Fail onEnded');
      pc2.onTrack = (RTCTrackEvent e) => {
        e.track?.onEnded = () => complete_ended = Future.value('Success'),
        complete = Future.value('Success'),
      };
      await pc2.setRemoteDescription(await pc1.createOffer({}));
      await complete;
      await (await pc2.transceivers)[0].stop();
      var result = await complete_ended;


      setState(() {
        if (result == 'Success') {
          text = 'test is success';
        } else {
          text = result;
        }

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




