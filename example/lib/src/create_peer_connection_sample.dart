import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'dart:async';

import 'package:flutter/services.dart';

/*class EventChannelTutorial {
  static const EventChannel _randomNumberChannel = const EventChannel('test');
  static Stream<String> get getRandomNumberStream {
    return _randomNumberChannel.receiveBroadcastStream().cast();
  }
}*/

class PeerConnectionSample extends StatefulWidget {
  static String tag = 'peer_connection_sample';

  @override
  _PeerConnectionSampleState createState() => _PeerConnectionSampleState();
}

class _PeerConnectionSampleState extends State<PeerConnectionSample> {
  String text = 'Press call button to enumerate devices';

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

  void eventListener(dynamic event) {
    print(event.toString());
  }

  void errorListener(Object obj) {
    print('badd\n');
    if (obj is Exception) throw obj;
  }

  void _create_peer() async {
    try {

      final createPeerConnection1 = await WebRTC.invokeMethod(
        'createPeerConnection', null
      );
      String pc1_id = createPeerConnection1['peerConnectionId'];
      StreamSubscription<dynamic> _eventSubscription = EventChannel('test')
        .receiveBroadcastStream()
        .listen(eventListener, onError: errorListener);

      final createOffer1 =
            await WebRTC.invokeMethod('createOffer', <String, dynamic>{
          'peerConnectionId': pc1_id,
          'constraints': defaultSdpConstraints
      });

      final setLocalDescription1 =
            await WebRTC.invokeMethod('setLocalDescription', <String, dynamic>{
          'peerConnectionId': pc1_id,
          'description' : {
          'sdp': createOffer1['sdp'],
          'type': createOffer1['type']}
      });

      final createPeerConnection2 = await WebRTC.invokeMethod(
        'createPeerConnection', null
      );
      String pc2_id = createPeerConnection2['peerConnectionId'];

      final setRemoteDescription2 =
            await WebRTC.invokeMethod('setRemoteDescription', <String, dynamic>{
          'peerConnectionId': pc2_id,
          'description' : {
          'sdp': createOffer1['sdp'],
          'type': 'offer'}
      });

      final createAnswer2 =
            await WebRTC.invokeMethod('createAnswer', <String, dynamic>{
          'peerConnectionId': pc2_id,
          'constraints': defaultSdpConstraints
      });

      final setLocalDescription2 =
            await WebRTC.invokeMethod('setLocalDescription', <String, dynamic>{
          'peerConnectionId': pc2_id,
          'description' : {
          'sdp': createAnswer2['sdp'],
          'type': createAnswer2['type']}
      });

      final setRemoteDescription1 =
            await WebRTC.invokeMethod('setRemoteDescription', <String, dynamic>{
          'peerConnectionId': pc1_id,
          'description' : {
          'sdp': createAnswer2['sdp'],
          'type': createAnswer2['type']}
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
