import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_webrtc/src/model/constraints.dart';

class RendererSample extends StatefulWidget {
  const RendererSample({Key? key}) : super(key: key);

  @override
  _RendererSampleState createState() => _RendererSampleState();
}

class _RendererSampleState extends State<RendererSample> {
  MediaStreamTrack? _track;
  final _renderer = createVideoRenderer();
  bool _isRendering = false;
  bool _isEnabled = true;

  @override
  void initState() {
    super.initState();
    initRenderer();
  }

  @override
  void deactivate() {
    super.deactivate();
    if (_isRendering) {
      _stop();
    }
    _renderer.dispose();
  }

  void initRenderer() async {
    await _renderer.initialize();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  void _start() async {
    final caps = DeviceConstraints();
    caps.video.mandatory = DeviceVideoConstraints();
    caps.video.mandatory!.width = 640;
    caps.video.mandatory!.height = 480;
    caps.video.mandatory!.fps = 30;
    caps.video.mandatory!.facingMode = FacingMode.user;

    try {
      _track = (await getUserMedia(caps))[0];
      _renderer.srcObject = _track;
    } catch (e) {
      print(e.toString());
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _isRendering = true;
    });
  }

  void _stop() async {
    try {
      await _track?.dispose();
      _renderer.srcObject = null;
      setState(() {
        _isRendering = false;
      });
      _isEnabled = false;
    } catch (e) {
      print(e.toString());
    }
  }

  void _toggleVideoEnabled() async {
    try {
      await _track?.setEnabled(_isEnabled);
      setState(() {
        _isEnabled = !_isEnabled;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Renderer'),
        actions: _isRendering
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
              child: VideoView(_renderer, mirror: true),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isRendering ? _stop : _start,
        tooltip: _isRendering ? 'Stop' : 'Start',
        child: Icon(_isRendering ? Icons.call_end : Icons.phone),
      ),
    );
  }
}
