import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class Test extends StatefulWidget {
  static String tag = 'Test';

  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  String text = 'Press the button to start test local stream.';
  bool on = false;
  late MediaStream? localStream;

  @override
  void initState() {
    super.initState();
  }

  void _upStream() async {
    final mediaConstraints = <String, dynamic>{
      'audio': true,
      'video': {
        'mandatory': {
          'minWidth':
              '640', // Provide your own width, height and frame rate here
          'minHeight': '480',
          'minFrameRate': '30',
        },
        'facingMode': 'user',
        'optional': [],
        'device_id':
            '\\\\?\\usb#vid_5986&pid_211b&mi_00#6&1485db48&0&0000#{65e8773d-8f56-11d0-a3b9-00a0c9223196}\\global',
      }
    };

    var stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    var test = stream.id;
    setState(() {
      text = 'Stream id: $test. Click again to stop local stream.';
      on = true;
      localStream = stream;
    });
  }

  void _dropStream() async {
    await localStream?.dispose();

    setState(() {
      text = 'Press the button to start test local stream.';
      on = false;
      localStream = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('test'),
      ),
      body: Center(child: Text(text)),
      floatingActionButton: FloatingActionButton(
        onPressed: !on ? _upStream : _dropStream,
        child: Icon(!on ? Icons.stream : Icons.cancel_outlined),
      ),
    );
  }
}
