import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class TestSample extends StatefulWidget {
  static String tag = 'test_sample';

  const TestSample({Key? key}) : super(key: key);

  @override
  _TestSampleState createState() => _TestSampleState();
}

class _TestSampleState extends State<TestSample> {
  String text = 'Press call button';

  @override
  void initState() {
    super.initState();
  }

  void _test() async {
    var asd = await api.asd();

    if (asd.err != null) {
      print(asd.err!.index);
    }

    setState(() {
      text = asd.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('test'),
      ),
      body: Center(child: Text(text)),
      floatingActionButton: FloatingActionButton(
        onPressed: _test,
        child: const Icon(Icons.phone),
      ),
    );
  }
}
