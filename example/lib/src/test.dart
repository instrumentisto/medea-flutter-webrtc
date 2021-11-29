import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class Test extends StatefulWidget {
  static String tag = 'Test';

  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  String text = 'Press call button to test';

  @override
  void initState() {
    super.initState();
  }

  void _getSources() async {
    var test = await WebRTC.invokeMethod(
      'test',
    );
    setState(() {
      text = test;
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
        onPressed: _getSources,
        child: Icon(Icons.phone),
      ),
    );
  }
}
