import 'dart:convert';
import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CreateSample extends StatefulWidget {
  static String tag = 'peer_connection_sample';

  @override
  _CreateSampleState createState() => _CreateSampleState();
}

class _CreateSampleState extends State<CreateSample> {
  String text = '42';

  @override
  void initState() {
    super.initState();
  }

  var configuration = <String, dynamic>{
    'iceServers': [
      {'url': 'stun:stun.l.google.com:19302'},
    ]
  };

  final loopbackConstraints = <String, dynamic>{
    'mandatory': {},
    'optional': [
      {'DtlsSrtpKeyAgreement': true},
    ],
  };

  final Map<String, dynamic> defaultSdpConstraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': true,
    },
    'optional': [true, false, true],
  };


  void _create_sample() async {
    try {
    final response =
          await WebRTC.invokeMethod('createOffer', <String, dynamic>{
        'peerConnectionId': '1',
        'constraints': defaultSdpConstraints
    });

    while (true){
    final response2 =
          await WebRTC.invokeMethod('setLocalDescription', <String, dynamic>{
        'peerConnectionId': '1',
        'description' : {
        'sdp': response['sdp'],
        'type': response['type']}
    });
    }



    setState(() {
      text = 'Good';
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
        title: Text('CreateSample'),
      ),
      body: Center(child: Text(text)),
      floatingActionButton: FloatingActionButton(
        onPressed: _create_sample,
        child: Icon(Icons.phone),
      ),
    );
  }
}
