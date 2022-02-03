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
    print('bad\n');
    if (obj is Exception) throw obj;
  }

  // todo refact
  void _create_peer() async {
    try {

      final createPeerConnection1 =
          await WebRTC.invokeMethod('createPeerConnection', null);
      String pc1_id = createPeerConnection1['peerConnectionId'];

      var ch1 = EventChannel('PeerConnection/Event/channel/id/$pc1_id');
      var sub1 = await ch1
          .receiveBroadcastStream()
          .listen(eventListener, onError: errorListener);
      //await sub1.cancel();

      final createPeerConnection2 =
          await WebRTC.invokeMethod('createPeerConnection', null);
      String pc2_id = createPeerConnection2['peerConnectionId'];

      var ch2 = EventChannel('PeerConnection/Event/channel/id/$pc2_id');
      var sub2 = await ch2
          .receiveBroadcastStream()
          .listen(eventListener, onError: errorListener);

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
          'type': createOffer1['type']
        }
      });

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

      await sub1.cancel();

      final delete_pc2 = await WebRTC.invokeMethod(
          'deletePC', <String, dynamic>{'peerConnectionId': pc2_id});

      await sub2.cancel();

      final delete_pc1 = await WebRTC.invokeMethod(
          'deletePC', <String, dynamic>{'peerConnectionId': pc1_id});

      setState(() {
        text = 'test is success';
      });

      // memory leak test.
      for (var i =0; i<1000; ++i) {
        final createPeerConnection_leak =
          await WebRTC.invokeMethod('createPeerConnection', null);
        String pc_id = createPeerConnection_leak['peerConnectionId'];

        final delete_pc1 = await WebRTC.invokeMethod(
          'deletePC', <String, dynamic>{'peerConnectionId': pc_id});
      }

      setState(() {
        text = 'test leak is success';
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
