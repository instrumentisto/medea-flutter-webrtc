import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Add transceiver', (WidgetTester tester) async {
    var pc = await createPeerConnection({});
    var init = RTCRtpTransceiverInit();
    init.direction = TransceiverDirection.SendRecv;

    var trans = await pc.addTransceiver(
        kind: RTCRtpMediaType.RTCRtpMediaTypeVideo, init: init);

    expect(trans.mid.isEmpty, isTrue);

    var response = await pc.createOffer();

    expect(response.sdp!.contains('m=video'), isTrue);
    expect(response.sdp!.contains('sendrecv'), isTrue);
  });

  testWidgets('Get transceivers', (WidgetTester tester) async {
    var pc = await createPeerConnection({});
    var init = RTCRtpTransceiverInit();
    init.direction = TransceiverDirection.SendRecv;

    await pc.addTransceiver(
        kind: RTCRtpMediaType.RTCRtpMediaTypeVideo, init: init);
    await pc.addTransceiver(
        kind: RTCRtpMediaType.RTCRtpMediaTypeAudio, init: init);

    var before = await pc.getTransceivers();

    expect(before[0].mid.isEmpty, isTrue);
    expect(before[1].mid.isEmpty, isTrue);

    var offer = await pc.createOffer();
    await pc.setLocalDescription(offer);

    var after = await pc.getTransceivers();

    expect(after[0].mid, equals('0'));
    expect(after[1].mid, equals('1'));
  });

  testWidgets('Get transceiver direction', (WidgetTester tester) async {
    var pc = await createPeerConnection({});
    var init = RTCRtpTransceiverInit();
    init.direction = TransceiverDirection.SendRecv;
    var trans = await pc.addTransceiver(
        kind: RTCRtpMediaType.RTCRtpMediaTypeVideo, init: init);

    var direction = await trans.getDirection();

    expect(direction, equals(TransceiverDirection.SendRecv));
  });

  testWidgets('Set transceiver direction', (WidgetTester tester) async {
    var pc = await createPeerConnection({});
    var init = RTCRtpTransceiverInit();
    init.direction = TransceiverDirection.SendRecv;
    var trans = await pc.addTransceiver(
        kind: RTCRtpMediaType.RTCRtpMediaTypeVideo, init: init);

    var direction = await trans.getDirection();

    expect(direction, equals(TransceiverDirection.SendRecv));

    for (var dir in TransceiverDirection.values) {
      if (dir == TransceiverDirection.Stopped) {
        continue;
      }

      await trans.setDirection(dir);

      direction = await trans.getDirection();

      expect(direction, equals(dir));
    }
  });

  testWidgets('Stop transceiver', (WidgetTester tester) async {
    var pc = await createPeerConnection({});
    var init = RTCRtpTransceiverInit();
    init.direction = TransceiverDirection.SendRecv;
    var trans = await pc.addTransceiver(
        kind: RTCRtpMediaType.RTCRtpMediaTypeVideo, init: init);

    var direction = await trans.getDirection();

    expect(direction, equals(TransceiverDirection.SendRecv));

    await trans.stop();

    direction = await trans.getDirection();

    expect(direction, equals(TransceiverDirection.Stopped));
  });

  testWidgets('Get transceiver mid', (WidgetTester tester) async {
    var pc = await createPeerConnection({});
    var init = RTCRtpTransceiverInit();
    init.direction = TransceiverDirection.SendRecv;
    var trans = await pc.addTransceiver(
        kind: RTCRtpMediaType.RTCRtpMediaTypeVideo, init: init);

    var mid = await trans.getMid();

    expect(mid.isEmpty, isTrue);

    var sess = await pc.createOffer();
    await pc.setLocalDescription(sess);

    mid = await trans.getMid();

    expect(mid, equals('0'));
  });

  testWidgets('Get transceiver mid', (WidgetTester tester) async {
    var pc = await createPeerConnection({});
    var init = RTCRtpTransceiverInit();
    init.direction = TransceiverDirection.SendRecv;
    var trans = await pc.addTransceiver(
        kind: RTCRtpMediaType.RTCRtpMediaTypeVideo, init: init);

    var mid = await trans.getMid();

    expect(mid.isEmpty, isTrue);

    var sess = await pc.createOffer();
    await pc.setLocalDescription(sess);

    mid = await trans.getMid();

    expect(mid, equals('0'));
  });

  testWidgets('Peer connection', (WidgetTester tester) async {
    var result = 'Success';

    try {
      var pc1 = await createPeerConnection({});
      var pc2 = await createPeerConnection({});

      var offer = await pc1.createOffer();
      await pc1.setLocalDescription(offer);
      await pc2.setRemoteDescription(offer);

      var answer = await pc2.createAnswer({});
      await pc2.setLocalDescription(answer);
      await pc1.setRemoteDescription(answer);
    } catch (e) {
      result = e.toString();
    }
    expect(result, equals('Success'));
  });

  testWidgets('Peer connection event on track', (WidgetTester tester) async {
    var pc1 = await createPeerConnection({});
    var init = RTCRtpTransceiverInit();
    init.direction = TransceiverDirection.SendRecv;

    await pc1.addTransceiver(
      kind: RTCRtpMediaType.RTCRtpMediaTypeVideo, init: init);
    var pc2 = await createPeerConnection({});
    var result;
    var timer = Future.delayed(Duration(seconds: 5));
    var t = Timer(Duration(seconds: 5), () => result = 'Fail');
    pc2.onTrack = (RTCTrackEvent e) => result = 'Success';
    await pc2.setRemoteDescription(await pc1.createOffer({}));
    await timer;
    expect(result, equals('Success'));
  });
}
