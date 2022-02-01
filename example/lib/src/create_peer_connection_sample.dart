import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class PeerConnectionSample extends StatefulWidget {
  static String tag = 'peer_connection_sample';

  @override
  _PeerConnectionSampleState createState() => _PeerConnectionSampleState();
}

class _PeerConnectionSampleState extends State<PeerConnectionSample> {
  String text = 'Press call button to test create PeerConnection';

  @override
  void initState() {
    super.initState();
  }

  final Map<String, dynamic> defaultSdpConstraints = {
    'mandatory': {
      'OfferToReceiveAudio': false,
      'OfferToReceiveVideo': false,
    },
    'optional': [true, false, true],
  };

  void _create_peer() async {
    try {
      final createPeerConnection1 =
          await WebRTC.invokeMethod('createPeerConnection', null);
      String pc1_id = createPeerConnection1['peerConnectionId'];
      final createPeerConnection2 =
          await WebRTC.invokeMethod('createPeerConnection', null);
      String pc2_id = createPeerConnection2['peerConnectionId'];

      await WebRTC.invokeMethod('addTransceiver', <String, dynamic>{
        'peerConnectionId': pc1_id,
        'mediaType': 'video',
        'transceiverInit': <String, dynamic>{'direction': 'kSendRecv'},
      });

      final createOffer1 = await WebRTC.invokeMethod(
          'createOffer', <String, dynamic>{
        'peerConnectionId': pc1_id,
        'constraints': defaultSdpConstraints
      });

      final setLocalDescription1 =
          await WebRTC.invokeMethod('setLocalDescription', <String, dynamic>{
        'peerConnectionId': pc1_id,
        'description': {
          'sdp': createOffer1['sdp'],
          'type': createOffer1['type'],
        }
      });

      // await WebRTC.invokeMethod('lol', <String, dynamic>{
      //   'peerConnectionId': pc1_id,
      // });

      final setRemoteDescription2 =
          await WebRTC.invokeMethod('setRemoteDescription', <String, dynamic>{
        'peerConnectionId': pc2_id,
        'description': {'sdp': createOffer1['sdp'], 'type': 'offer'}
      });

      final createAnswer2 = await WebRTC.invokeMethod(
          'createAnswer', <String, dynamic>{
        'peerConnectionId': pc2_id,
        'constraints': defaultSdpConstraints
      });

      final setLocalDescription2 =
          await WebRTC.invokeMethod('setLocalDescription', <String, dynamic>{
        'peerConnectionId': pc2_id,
        'description': {
          'sdp': createAnswer2['sdp'],
          'type': createAnswer2['type']
        }
      });

      final setRemoteDescription1 =
          await WebRTC.invokeMethod('setRemoteDescription', <String, dynamic>{
        'peerConnectionId': pc1_id,
        'description': {
          'sdp': createAnswer2['sdp'],
          'type': createAnswer2['type']
        }
      });

      await WebRTC.invokeMethod('getTransceivers', <String, dynamic>{
        'peerConnectionId': pc1_id,
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
