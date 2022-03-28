// TODO(alexlapa): make 2 peer and fix

import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_webrtc/src/model/peer.dart';
import 'package:flutter_webrtc/src/model/ice.dart';
import 'package:flutter_webrtc/src/model/track.dart';

class LoopBackSample extends StatefulWidget {
  static String tag = 'loopback_sample';

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<LoopBackSample> {
  List<MediaStreamTrack>? _tracks;
  PeerConnection? _peerConnection;
  final _localRenderer = createVideoRenderer();
  final _remoteRenderer = createVideoRenderer();
  final bool _inCalling = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    initRenderers();
  }

  @override
  void deactivate() {
    super.deactivate();
    if (_inCalling) {
      _hangUp();
    }
    _localRenderer.dispose();
    _remoteRenderer.dispose();
  }

  void initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  void _onSignalingState(SignalingState state) {
    print(state);
  }

  void _onIceGatheringState(IceGatheringState state) {
    print(state);
  }

  void _onIceConnectionState(IceConnectionState state) {
    print(state);
  }

  void _onPeerConnectionState(PeerConnectionState state) {
    print(state);
  }

  void _onCandidate(IceCandidate candidate) {
    print('onCandidate: ${candidate.candidate}');
    _peerConnection?.addIceCandidate(candidate);
  }

  // void _onTrack(NativeMediaStreamTrack track, RtpTransceiver transceiver) {
  //   if (track.kind() == MediaKind.video) {
  //     _remoteRenderer.srcObject = track;
  //   }
  // }

  // Platform messages are asynchronous, so we initialize in an async method.
  void _makeCall() async {
    // final mediaConstraints = <String, dynamic>{
    //   'audio': true,
    //   'video': {
    //     'mandatory': {
    //       'minWidth':
    //           '640', // Provide your own width, height and frame rate here
    //       'minHeight': '480',
    //       'minFrameRate': '30',
    //     },
    //     'facingMode': 'user',
    //     'optional': [],
    //   }
    // };
    //
    // if (_peerConnection != null) return;
    //
    // try {
    //   _peerConnection = await createPeerConnection(configuration, loopbackConstraints);
    //
    //   _peerConnection!.onSignalingStateChange(_onSignalingState);
    //   _peerConnection!.onIceGatheringStateChange(_onIceGatheringState);
    //   _peerConnection!.onIceConnectionStateChange(_onIceConnectionState);
    //   _peerConnection!.onConnectionStateChange(_onPeerConnectionState);
    //   _peerConnection!.onIceCandidate(_onCandidate);
    //
    //   _tracks = await getUserMedia(mediaConstraints);
    //   _localRenderer.srcObject = _tracks;
    //
    //   _peerConnection!.onTrack(_onTrack);
    //   _tracks!.getTracks().forEach((track) {
    //     _peerConnection!.addTrack(track, _tracks!);
    //   });
    //
    //   var description = await _peerConnection!.createOffer(offerSdpConstraints);
    //   var sdp = description.sdp;
    //   print('sdp = $sdp');
    //   await _peerConnection!.setLocalDescription(description);
    //   description.type = 'answer';
    //   await _peerConnection!.setRemoteDescription(description);
    // } catch (e) {
    //   print(e.toString());
    // }
    // if (!mounted) return;
    //
    // setState(() {
    //   _inCalling = true;
    // });
  }

  void _hangUp() async {
    // try {
    //   await _tracks?.dispose();
    //   await _peerConnection?.close();
    //   _peerConnection = null;
    //   _localRenderer.srcObject = null;
    //   _remoteRenderer.srcObject = null;
    // } catch (e) {
    //   print(e.toString());
    // }
    // setState(() {
    //   _inCalling = false;
    // });
    // _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var widgets = <Widget>[
      // Expanded(
      //   child: RTCVideoView(_localRenderer, mirror: true),
      // ),
      // Expanded(
      //   child: RTCVideoView(_remoteRenderer),
      // )
    ];
    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Center(
            child: Container(
              decoration: BoxDecoration(color: Colors.black54),
              child: orientation == Orientation.portrait
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: widgets)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: widgets),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _inCalling ? _hangUp : _makeCall,
        tooltip: _inCalling ? 'Hangup' : 'Call',
        child: Icon(_inCalling ? Icons.call_end : Icons.phone),
      ),
    );
  }
}
