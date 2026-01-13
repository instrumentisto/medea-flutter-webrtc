import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter_test/flutter_test.dart';
import 'package:medea_flutter_webrtc/medea_flutter_webrtc.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    print("setUpAll 000");
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      print("setUpAll 111");
      await initFfiBridge();
      print("setUpAll 222");
      await enableFakeMedia();
      print("setUpAll 333");
    }
  });

  setUp(() async {
    print("setUp 000");
  });

  tearDownAll(() async {
    print("tearDownAll 000");
  });

  tearDown(() async {
    print("tearDown 000");
  });

  print("fml 000");
  testWidgets('Set send direction', (WidgetTester tester) async {
    print("fml 111");
    var pc = await PeerConnection.create(IceTransportType.all, []);
    // ignore: prefer_function_declarations_over_variables
    var testEnableRecv = (beforeDirection, afterDirection) async {
      var transceiver = await pc.addTransceiver(
        MediaKind.video,
        RtpTransceiverInit(beforeDirection),
      );
      await transceiver.setSend(true);
      expect(await transceiver.getDirection(), afterDirection);

      await transceiver.dispose();
    };
    print("fml 222");
    // ignore: prefer_function_declarations_over_variables
    var testDisableRecv = (beforeDirection, afterDirection) async {
      var transceiver = await pc.addTransceiver(
        MediaKind.video,
        RtpTransceiverInit(beforeDirection),
      );
      await transceiver.setSend(false);
      expect(await transceiver.getDirection(), afterDirection);

      await transceiver.dispose();
    };
    print("fml 333");
    var testEnable = [
      [TransceiverDirection.inactive, TransceiverDirection.sendOnly],
      [TransceiverDirection.sendOnly, TransceiverDirection.sendOnly],
      [TransceiverDirection.recvOnly, TransceiverDirection.sendRecv],
      [TransceiverDirection.sendRecv, TransceiverDirection.sendRecv],
    ];
    print("fml 444");
    var testDisable = [
      [TransceiverDirection.inactive, TransceiverDirection.inactive],
      [TransceiverDirection.sendOnly, TransceiverDirection.inactive],
      [TransceiverDirection.recvOnly, TransceiverDirection.recvOnly],
      [TransceiverDirection.sendRecv, TransceiverDirection.recvOnly],
    ];
    print("fml 555");
    for (
      var value = testEnable.removeAt(0);
      testEnable.isNotEmpty;
      value = testEnable.removeAt(0)
    ) {
      await testEnableRecv(value[0], value[1]);
    }
    print("fml 666");
    for (
      var value = testDisable.removeAt(0);
      testDisable.isNotEmpty;
      value = testDisable.removeAt(0)
    ) {
      await testDisableRecv(value[0], value[1]);
    }
    print("fml 777");
    await pc.close();

    print("fml 888");
  });
  print("fml 999");
}
