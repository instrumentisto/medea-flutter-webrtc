import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class RendererTest extends StatefulWidget {
  const RendererTest({Key? key}) : super(key: key);

  @override
  _RendererTestState createState() => _RendererTestState();
}

class _RendererTestState extends State<RendererTest> {
  MediaStream? _localStream;
  final _localRenderer = RTCVideoRenderer();
  bool _inCalling = false;
  bool _isEnabled = true;

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
  }

  void initRenderers() async {
    await _localRenderer.initialize();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  void _makeCall() async {
    final mediaConstraints = <String, dynamic>{
      'audio': false,
      'video': {
        'mandatory': {
          'minWidth':
              '640', // Provide your own width, height and frame rate here
          'minHeight': '480',
          'minFrameRate': '30',
        },
        'facingMode': 'user',
        'optional': [],
      }
    };

    try {
      var stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _localStream = stream;
      _localRenderer.srcObject = _localStream;
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
      await _localStream?.dispose();
      _localRenderer.srcObject = null;
      setState(() {
        _inCalling = false;
      });
      if (!_isEnabled) {
        _toggleVideoEnabled();
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void _toggleVideoEnabled() async {
    try {
      setState(() {
        _isEnabled = !_isEnabled;
      });
      _localStream?.getVideoTracks()[0].enabled = _isEnabled;
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Renderer'),
        actions: _inCalling
            ? [
                IconButton(
                  icon: Icon(_isEnabled ? Icons.cancel : Icons.camera_sharp),
                  onPressed: _toggleVideoEnabled,
                ),
              ]
            : null,
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Center(
            child: Container(
              margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(color: Colors.black54),
              child: RTCVideoView(_localRenderer, mirror: true),
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

  void _selectAudioOutput(String deviceId) {
    _localRenderer.audioOutput = deviceId;
  }
}
