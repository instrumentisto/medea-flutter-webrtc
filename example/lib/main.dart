import 'dart:core';

import 'package:flutter/material.dart';
import 'package:medea_flutter_webrtc/medea_flutter_webrtc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'src/create_peer_connection.dart';
import 'src/get_display_media.dart';
import 'src/get_sources.dart';
import 'src/get_user_media.dart';
import 'src/loopback.dart';
import 'src/on_device_change.dart';
import 'src/video_codec_info.dart';
import 'src/route_item.dart';

void main() async {
  await initFfiBridge();
  await enableFakeMedia();

  // runApp(const MyApp());

  var caps = DeviceConstraints();
  caps.audio.mandatory = AudioConstraints();
  caps.video.mandatory = DeviceVideoConstraints();
  caps.video.mandatory!.width = 640;
  caps.video.mandatory!.height = 480;
  caps.video.mandatory!.fps = 30;

  var tracks = await getUserMedia(caps);

  var videoTrack = tracks.firstWhere(
    (track) => track.kind() == MediaKind.video,
  );
  var audioTrack = tracks.firstWhere(
    (track) => track.kind() == MediaKind.audio,
  );

  var pc1 = await PeerConnection.create(IceTransportType.all, []);
  var pc2 = await PeerConnection.create(IceTransportType.all, []);

  pc1.onIceCandidate((candidate) async {
    if (!pc2.closed) {
      await pc2.addIceCandidate(candidate);
    }
  });

  pc2.onIceCandidate((candidate) async {
    if (!pc1.closed) {
      await pc1.addIceCandidate(candidate);
    }
  });
  var tVideo = await pc1.addTransceiver(
    MediaKind.video,
    RtpTransceiverInit(TransceiverDirection.sendRecv),
  );
  var tAudio = await pc1.addTransceiver(
    MediaKind.audio,
    RtpTransceiverInit(TransceiverDirection.sendRecv),
  );

  tVideo.sender.replaceTrack(videoTrack);
  tAudio.sender.replaceTrack(audioTrack);

  var offer = await pc1.createOffer();
  await pc1.setLocalDescription(offer);
  await pc2.setRemoteDescription(offer);

  var answer = await pc2.createAnswer();
  await pc2.setLocalDescription(answer);
  await pc1.setRemoteDescription(answer);

  var n = 5;
  var hasOutboundAudio = false;
  var hasOutboundVideo = false;
  var hasOutboundTransport = false;
  for (int i = 0; i < n; i++) {
    var senderStats = await pc1.getStats();

    hasOutboundTransport = senderStats.any((s) => s.type is RtcTransportStats);
    hasOutboundAudio = senderStats.any(
      (s) =>
          (s.type is RtcOutboundRtpStreamStats &&
          (s.type as RtcOutboundRtpStreamStats).mediaType
              is RtcOutboundRtpStreamStatsAudio),
    );
    hasOutboundVideo = senderStats.any(
      (s) =>
          (s.type is RtcOutboundRtpStreamStats &&
          (s.type as RtcOutboundRtpStreamStats).mediaType
              is RtcOutboundRtpStreamStatsVideo),
    );

    if (hasOutboundTransport && hasOutboundAudio && hasOutboundVideo) {
      break;
    }
    await Future.delayed(Duration(milliseconds: 500));
  }
  expect(hasOutboundTransport, isTrue);
  expect(hasOutboundAudio, isTrue);
  expect(hasOutboundVideo, isTrue);

  n = 5;
  var hasInboundAudio = false;
  var hasInboundVideo = false;
  var hasInboundTransport = false;
  for (int i = 0; i < n; i++) {
    var receiverStats = await pc2.getStats();

    hasInboundTransport = receiverStats.any((s) => s.type is RtcTransportStats);
    hasInboundAudio = receiverStats.any(
      (s) =>
          (s.type is RtcInboundRtpStreamStats &&
          (s.type as RtcInboundRtpStreamStats).mediaType
              is RtcInboundRtpStreamAudio),
    );
    hasInboundVideo = receiverStats.any(
      (s) =>
          (s.type is RtcInboundRtpStreamStats &&
          (s.type as RtcInboundRtpStreamStats).mediaType
              is RtcInboundRtpStreamVideo),
    );

    if (hasInboundAudio && hasInboundVideo && hasInboundTransport) {
      break;
    }
    await Future.delayed(Duration(milliseconds: 500));
  }

  expect(hasInboundTransport, isTrue);
  expect(hasInboundAudio, isTrue);
  expect(hasInboundVideo, isTrue);

  await pc1.close();
  await pc2.close();
  await tVideo.dispose();
  await tAudio.dispose();
  await videoTrack.stop();
  await audioTrack.stop();
  await videoTrack.dispose();
  await audioTrack.dispose();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late List<RouteItem> items;

  @override
  void initState() {
    super.initState();
    _initItems();
  }

  ListBody _buildRow(BuildContext context, RouteItem item) {
    return ListBody(
      children: <Widget>[
        ListTile(
          title: Text(item.title),
          onTap: () => item.push!(context),
          trailing: const Icon(Icons.arrow_right),
        ),
        const Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Flutter-WebRTC example')),
        body: ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.all(0.0),
          itemCount: items.length,
          itemBuilder: (context, i) {
            return _buildRow(context, items[i]);
          },
        ),
      ),
      debugShowCheckedModeBanner: false,
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
              builder: (BuildContext context) => const GetUserMediaSample(),
            ),
          );
        },
      ),
      RouteItem(
        title: 'GetDisplayMedia',
        push: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const GetDisplayMediaSample(),
            ),
          );
        },
      ),
      RouteItem(
        title: 'LoopBack Sample',
        push: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const Loopback(),
            ),
          );
        },
      ),
      RouteItem(
        title: 'getSources',
        push: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const GetSourcesSample(),
            ),
          );
        },
      ),
      RouteItem(
        title: 'Basic RtcPeerConnection',
        push: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const PeerConnectionSample(),
            ),
          );
        },
      ),
      RouteItem(
        title: 'onDeviceChange notifier',
        push: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) =>
                  const OnDeviceChangeNotifierSample(),
            ),
          );
        },
      ),
      RouteItem(
        title: 'Video Codec Info',
        push: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const VideoCodecInfoSample(),
            ),
          );
        },
      ),
    ];
  }
}
