import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NotifierTest extends StatefulWidget {
  const NotifierTest({Key? key}) : super(key: key);
  static String tag = 'NotifierTest';

  @override
  _NotifierTestState createState() => _NotifierTestState();
}

class _NotifierTestState extends State<NotifierTest> {
  int count = 0;
  String text = 'Notifications here.';
  StreamSubscription<dynamic>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _eventSubscription = EventChannel('FlutterWebRTC/Notifier')
        .receiveBroadcastStream()
        .listen(eventListener, onError: errorListener);
  }

  @override
  Future<void> dispose() async {
    await _eventSubscription?.cancel();

    return super.dispose();
  }

  void eventListener(dynamic event) {
    final Map<dynamic, dynamic> map = event;
    switch (map['event']) {
      case 'test':
        setState(() {
          text = 'opa test $count';
          count++;
        });
        break;
    }
  }

  void errorListener(Object obj) {
    if (obj is Exception) {
      throw obj;
    }
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
