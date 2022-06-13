import 'dart:core';

import 'package:flutter/material.dart';
import 'package:medea_jason_webrtc/medea_jason_webrtc.dart';

class GetSourcesSample extends StatefulWidget {
  static String tag = 'get_sources_sample';

  const GetSourcesSample({Key? key}) : super(key: key);

  @override
  _GetSourcesSampleState createState() => _GetSourcesSampleState();
}

class _GetSourcesSampleState extends State<GetSourcesSample> {
  String text = 'Press call button to enumerate devices';

  @override
  void initState() {
    super.initState();
  }

  void _getSources() async {
    var mediaDeviceInfos = await enumerateDevices();
    setState(() {
      var devicesInfo = '';
      for (var device in mediaDeviceInfos) {
        devicesInfo = devicesInfo +
            'Kind: ${device.kind}\nName: ${device.label}\nId: ${device.deviceId}\n\n';
      }
      text = devicesInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('getSources'),
      ),
      body: Center(child: Text(text)),
      floatingActionButton: FloatingActionButton(
        onPressed: _getSources,
        child: const Icon(Icons.phone),
      ),
    );
  }
}
