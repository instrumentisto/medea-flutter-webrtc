import 'dart:core';

import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'src/renderer.dart';
import 'src/create_peer_connection_sample.dart';
import 'src/get_display_media_sample.dart';
import 'src/get_sources_sample.dart';
import 'src/get_user_media_sample.dart'
    if (dart.library.html) 'src/get_user_media_sample_web.dart';
import 'src/loopback_sample.dart';
import 'src/renderer.dart';
import 'src/on_device_change.dart';
import 'src/route_item.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late List<RouteItem> items;

  @override
  void initState() {
    super.initState();
    _initItems();
  }

  ListBody _buildRow(context, item) {
    return ListBody(children: <Widget>[
      ListTile(
        title: Text(item.title),
        onTap: () => item.push(context),
        trailing: Icon(Icons.arrow_right),
      ),
      Divider()
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text('Flutter-WebRTC example'),
          ),
          body: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(0.0),
              itemCount: items.length,
              itemBuilder: (context, i) {
                return _buildRow(context, items[i]);
              })),
    );
  }

  void _initItems() {
    items = <RouteItem>[
      RouteItem(
          title: 'GetUserMedia',
          push: (BuildContext context) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => GetUserMediaSample()));
          }),
      RouteItem(
          title: 'GetDisplayMedia',
          push: (BuildContext context) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) =>
                        GetDisplayMediaSample()));
          }),
      RouteItem(
          title: 'LoopBack Sample',
          push: (BuildContext context) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => LoopBackSample()));
          }),
      RouteItem(
          title: 'getSources',
          push: (BuildContext context) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => GetSourcesSample()));
          }),
      RouteItem(
          title: 'Basic RtcPeerConnection',
          push: (BuildContext context) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => PeerConnectionSample()));
          }),
      RouteItem(
          title: 'Renderer sample',
          push: (BuildContext context) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => RendererSample()));
          }),
      RouteItem(
          title: 'onDeviceChange notifier',
          push: (BuildContext context) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) =>
                        OnDeviceChangeNotifierSample()));
          }),
    ];
  }
}