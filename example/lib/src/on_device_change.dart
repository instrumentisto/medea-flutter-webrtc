import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class NotifierTest extends StatefulWidget {
  const NotifierTest({Key? key}) : super(key: key);

  @override
  _NotifierTestState createState() => _NotifierTestState();
}

class _NotifierTestState extends State<NotifierTest> {
  int count = 0;
  String text = '';
  MediaDevices? mediaDevices;

  @override
  void initState() {
    super.initState();

    mediaDevices = navigator.mediaDevices;
    mediaDevices?.onDeviceChange = () => {
          setState(() {
            text = 'Count of events fired: $count.';
            count++;
          })
        };
  }

  @override
  void dispose() {
    mediaDevices?.onDeviceChange = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifier'),
      ),
      body: Center(child: Text(text)),
    );
  }
}
