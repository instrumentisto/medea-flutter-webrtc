import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_webrtc_example/src/get_user_media_sample.dart';


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

      final mediaConstraints = <String, dynamic>{
        'audio': false,
        'video': {
          'mandatory': {},
        }
      };
      
      var stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);

      var track = stream.getTracks()[1];
      await trans.sender.replaceTrack(track);
      var pc2 = await createPeerConnection({});
      var complete = Future.delayed(const Duration(seconds: 5)).then((value) => 'Fail');
      pc2.onTrack = (RTCTrackEvent e) => {complete = Future.value('Success')};

      await pc2.setRemoteDescription(await pc1.createOffer({}));
      var result = await complete;

      setState(() {
        if (result == 'Success') {
          text = 'test is success';
        } else {
          text = 'Fail. timeout';
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
