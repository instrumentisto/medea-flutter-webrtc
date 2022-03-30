// ignore_for_file: avoid_print
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class Loopback extends StatefulWidget {
  static String tag = 'get_usermedia_sample';

  const Loopback({Key? key}) : super(key: key);

  @override
  _LoopbackState createState() => _LoopbackState();
}

class _LoopbackState extends State<Loopback> {
  List<MediaStreamTrack>? _tracks;

  PeerConnection? _pc1;
  PeerConnection? _pc2;

  final _localRenderer = createVideoRenderer();
  final _remoteRenderer = createVideoRenderer();
  bool _inCalling = false;

  List<MediaDeviceInfo>? _mediaDevicesList;

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

  // Platform messages are asynchronous, so we initialize in an async method.
  void _makeCall() async {
    var caps = DeviceConstraints();
    caps.audio.mandatory = AudioConstraints();
    caps.video.mandatory = DeviceVideoConstraints();
    caps.video.mandatory!.width = 640;
    caps.video.mandatory!.height = 480;
    caps.video.mandatory!.fps = 30;

    try {
      _mediaDevicesList = await enumerateDevices();
      _tracks = await getUserMedia(caps);
      _localRenderer.srcObject =
          _tracks!.firstWhere((track) => track.kind() == MediaKind.video);

      var server =
          IceServer(['stun:stun.l.google.com:19302'], 'username', 'password');
      _pc1 = await PeerConnection.create(IceTransportType.all, [server]);
      _pc2 = await PeerConnection.create(IceTransportType.all, [server]);

      _pc1?.onIceCandidateError((p0) {
        print(p0.errorText);
      });
      _pc2?.onIceCandidateError((p0) {
        print(p0.errorText);
      });

      _pc2?.onTrack((track, trans) {
        if (track.kind() == MediaKind.video) {
          _remoteRenderer.srcObject = track;
        }
      });

      var trans = await _pc1?.addTransceiver(
          MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));

      var offer = await _pc1?.createOffer();
      await _pc1?.setLocalDescription(offer!);
      await _pc2?.setRemoteDescription(offer!);

      var answer = await _pc2?.createAnswer();
      await _pc2?.setLocalDescription(answer!);
      await _pc1?.setRemoteDescription(answer!);

      _pc1?.onIceCandidate((IceCandidate candidate) async {
        print(candidate.candidate.toString());
        await _pc2?.addIceCandidate(candidate);
      });

      _pc2?.onIceCandidate((IceCandidate candidate) async {
        print(candidate.candidate.toString());
        await _pc1?.addIceCandidate(candidate);
      });

      await trans?.sender.replaceTrack(
          _tracks!.firstWhere((track) => track.kind() == MediaKind.video));
    } catch (e) {
      print(e.toString());
    }
    if (!mounted) return;

    setState(() {
      _inCalling = true;
    });
  }

  void _hangUp() async {
    try {
      _localRenderer.srcObject = null;
      _remoteRenderer.srcObject = null;

      for (var track in _tracks!) {
        await track.dispose();
      }

      await _pc1?.close();
      await _pc2?.close();

      setState(() {
        _inCalling = false;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GetUserMedia API Test'),
        actions: _inCalling
            ? <Widget>[
                PopupMenuButton<String>(
                  onSelected: _selectAudioOutput,
                  itemBuilder: (BuildContext context) {
                    if (_mediaDevicesList != null) {
                      return _mediaDevicesList!
                          .where((device) =>
                              device.kind == MediaDeviceKind.audiooutput)
                          .map((device) {
                        return PopupMenuItem<String>(
                          value: device.deviceId,
                          child: Text(device.label),
                        );
                      }).toList();
                    }
                    return [];
                  },
                ),
              ]
            : null,
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Center(
              child: Row(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                width: MediaQuery.of(context).size.width / 2,
                height: MediaQuery.of(context).size.height,
                decoration: const BoxDecoration(color: Colors.black54),
                child: VideoView(_localRenderer, mirror: true),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                width: MediaQuery.of(context).size.width / 2,
                height: MediaQuery.of(context).size.height,
                decoration: const BoxDecoration(color: Colors.black54),
                child: VideoView(_remoteRenderer, mirror: true),
              ),
            ],
          ));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _inCalling ? _hangUp : _makeCall,
        tooltip: _inCalling ? 'Hangup' : 'Call',
        child: Icon(_inCalling ? Icons.call_end : Icons.phone),
      ),
    );
  }

  void _selectAudioOutput(String deviceId) {
    setOutputAudioId(deviceId);
  }
}
