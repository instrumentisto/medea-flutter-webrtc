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

    expect(trans.mid.isEmpty, equals(true));

    var response = await pc.createOffer();

    expect(response.sdp?.contains('m=video'), equals(true));
    expect(response.sdp?.contains('sendrecv'), equals(true));
  });

  testWidgets('Get transceivers', (WidgetTester tester) async {
    var pc = await createPeerConnection({});
    var init = RTCRtpTransceiverInit();
    init.direction = TransceiverDirection.SendRecv;
    await pc.addTransceiver(
        kind: RTCRtpMediaType.RTCRtpMediaTypeVideo, init: init);
    await pc.addTransceiver(
        kind: RTCRtpMediaType.RTCRtpMediaTypeAudio, init: init);
    var sess = await pc.createOffer();
    await pc.setLocalDescription(sess);

    var response = await pc.getTransceivers();

    expect(response.length, equals(2));
    expect(response[0].mid.isEmpty, equals(false));
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
      // `TransceiverDirection.Stopped` can't be set, but read.
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

    expect(mid.isEmpty, equals(true));

    var sess = await pc.createOffer();
    await pc.setLocalDescription(sess);

    mid = await trans.getMid();

    expect(mid.isEmpty, equals(false));
  });
}
