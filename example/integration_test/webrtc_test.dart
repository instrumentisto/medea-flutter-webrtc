import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Add transceiver', (WidgetTester tester) async {
    var pc = await PeerConnection.create(IceTransportType.all, []);
    var trans = await pc.addTransceiver(
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));

    expect(trans.mid, isNull);

    var response = await pc.createOffer();

    expect(response.description.contains('m=video'), isTrue);
    expect(response.description.contains('sendrecv'), isTrue);
  });

  testWidgets('Get transceivers', (WidgetTester tester) async {
    var pc = await PeerConnection.create(IceTransportType.all, []);
    await pc.addTransceiver(
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));
    await pc.addTransceiver(
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));

    var before = await pc.getTransceivers();

    expect(before[0].mid, isNull);
    expect(before[1].mid, isNull);

    var offer = await pc.createOffer();
    await pc.setLocalDescription(offer);

    var after = await pc.getTransceivers();

    expect(after[0].mid, equals('0'));
    expect(after[1].mid, equals('1'));
    expect(before[0].mid, equals('0'));
    expect(before[1].mid, equals('1'));
  });

  testWidgets('Get transceiver direction', (WidgetTester tester) async {
    var pc = await PeerConnection.create(IceTransportType.all, []);
    var trans = await pc.addTransceiver(
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));

    var direction = await trans.getDirection();
    expect(direction, equals(TransceiverDirection.sendRecv));
  });

  testWidgets('Set transceiver direction', (WidgetTester tester) async {
    var pc = await PeerConnection.create(IceTransportType.all, []);
    var trans = await pc.addTransceiver(
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));

    var direction = await trans.getDirection();

    expect(direction, equals(TransceiverDirection.sendRecv));

    for (var dir in TransceiverDirection.values) {
      if (dir == TransceiverDirection.stopped) {
        continue;
      }

      await trans.setDirection(dir);

      direction = await trans.getDirection();

      expect(direction, equals(dir));
    }
  });

  testWidgets('Stop transceiver', (WidgetTester tester) async {
    var pc = await PeerConnection.create(IceTransportType.all, []);
    var trans = await pc.addTransceiver(
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));

    var direction = await trans.getDirection();

    expect(direction, equals(TransceiverDirection.sendRecv));

    await trans.stop();

    direction = await trans.getDirection();

    expect(direction, equals(TransceiverDirection.stopped));
  });

  testWidgets('Get transceiver mid', (WidgetTester tester) async {
    var pc = await PeerConnection.create(IceTransportType.all, []);
    var trans = await pc.addTransceiver(
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));

    expect(trans.mid, isNull);

    var sess = await pc.createOffer();
    await pc.setLocalDescription(sess);

    expect(trans.mid, equals('0'));
  });

  testWidgets('Add Ice Candidate', (WidgetTester tester) async {
    var pc1 = await PeerConnection.create(IceTransportType.all, []);
    var pc2 = await PeerConnection.create(IceTransportType.all, []);

    pc1.onIceCandidate((candidate) async {
      await pc2.addIceCandidate(candidate);
    });

    pc2.onIceCandidate((candidate) async {
      await pc1.addIceCandidate(candidate);
    });
    await pc1.addTransceiver(
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));

    var offer = await pc1.createOffer();
    await pc1.setLocalDescription(offer);
    await pc2.setRemoteDescription(offer);

    var answer = await pc2.createAnswer();
    await pc2.setLocalDescription(answer);
    await pc1.setRemoteDescription(answer);
  });

  testWidgets('Restart Ice', (WidgetTester tester) async {
    var pc1 = await PeerConnection.create(IceTransportType.all, []);
    var pc2 = await PeerConnection.create(IceTransportType.all, []);

    var tx = StreamController<int>();
    var rx = StreamIterator(tx.stream);

    var eventsCount = 0;
    pc1.onNegotiationNeeded(() {
      eventsCount++;
      tx.add(eventsCount);
    });

    await pc1.addTransceiver(
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));

    var offer = await pc1.createOffer();
    await pc1.setLocalDescription(offer);
    await pc2.setRemoteDescription(offer);

    var answer = await pc2.createAnswer();
    await pc2.setLocalDescription(answer);
    await pc1.setRemoteDescription(answer);

    pc1.onIceCandidate((candidate) async {
      await pc2.addIceCandidate(candidate);
    });

    pc2.onIceCandidate((candidate) async {
      await pc1.addIceCandidate(candidate);
    });

    expect(await rx.moveNext(), isTrue);
    expect(rx.current, equals(1));

    await pc1.restartIce();

    expect(await rx.moveNext(), isTrue);
    expect(rx.current, equals(2));
  });

  testWidgets('Ice state PeerConnection', (WidgetTester tester) async {
    var pc1 = await PeerConnection.create(IceTransportType.all, []);
    var pc2 = await PeerConnection.create(IceTransportType.all, []);

    var tx = StreamController<PeerConnectionState>();
    var rx = StreamIterator(tx.stream);

    pc1.onConnectionStateChange((state) {
      tx.add(state);
    });

    await pc1.addTransceiver(
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));

    var offer = await pc1.createOffer();
    await pc1.setLocalDescription(offer);
    await pc2.setRemoteDescription(offer);

    var answer = await pc2.createAnswer();
    await pc2.setLocalDescription(answer);
    await pc1.setRemoteDescription(answer);

    pc1.onIceCandidate((candidate) async {
      await pc2.addIceCandidate(candidate);
    });
    pc2.onIceCandidate((candidate) async {
      await pc1.addIceCandidate(candidate);
    });

    expect(await rx.moveNext(), isTrue);
    expect(rx.current, equals(PeerConnectionState.connecting));

    expect(await rx.moveNext(), isTrue);
    expect(rx.current, equals(PeerConnectionState.connected));

    await pc1.close();

    expect(await rx.moveNext(), isTrue);
    expect(rx.current, equals(PeerConnectionState.closed));
  });

  testWidgets('Peer connection event on track', (WidgetTester tester) async {
    var pc1 = await PeerConnection.create(IceTransportType.all, []);
    await pc1.addTransceiver(
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));

    var pc2 = await PeerConnection.create(IceTransportType.all, []);
    final completer = Completer<void>();
    pc2.onTrack((track, transceiver) {
      completer.complete();
    });
    await pc2.setRemoteDescription(await pc1.createOffer());
    await completer.future.timeout(const Duration(seconds: 1));
  });

  testWidgets('Track Onended', (WidgetTester tester) async {
    var pc1 = await PeerConnection.create(IceTransportType.all, []);
    await pc1.addTransceiver(
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));

    var pc2 = await PeerConnection.create(IceTransportType.all, []);
    final completer = Completer<void>();
    pc2.onTrack((track, transceiver) {
      track.onEnded(() {
        completer.complete();
      });
    });

    await pc2.setRemoteDescription(await pc1.createOffer());
    await (await pc2.getTransceivers())[0].stop();
    await completer.future.timeout(const Duration(seconds: 3));
  });

  testWidgets('e2e test', (WidgetTester tester) async {
    var caps = DeviceConstraints();
    caps.audio.mandatory = AudioConstraints();
    caps.video.mandatory = DeviceVideoConstraints();
    caps.video.mandatory!.width = 640;
    caps.video.mandatory!.height = 480;
    caps.video.mandatory!.fps = 30;

    var trackspc1 = await getUserMedia(caps);

    var server =
        IceServer(['stun:stun.l.google.com:19302'], 'username', 'password');
    var pc1 = await PeerConnection.create(IceTransportType.all, [server]);
    var pc2 = await PeerConnection.create(IceTransportType.all, [server]);

    var allFutures = List<Completer>.generate(4, (_) => Completer());
    pc1.onConnectionStateChange((state) {
      if (state == PeerConnectionState.connected) {
        allFutures[0].complete();
      }
    });

    pc2.onConnectionStateChange((state) {
      if (state == PeerConnectionState.connected) {
        allFutures[1].complete();
      }
    });

    pc2.onTrack((track, trans) async {
      if (track.kind() == MediaKind.video) {
        allFutures[2].complete();
      } else {
        allFutures[3].complete();
      }
    });

    var pc1vtrans = await pc1.addTransceiver(
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendOnly));

    var pc1atrans = await pc1.addTransceiver(
        MediaKind.audio, RtpTransceiverInit(TransceiverDirection.sendOnly));

    var offer = await pc1.createOffer();
    await pc1.setLocalDescription(offer);
    await pc2.setRemoteDescription(offer);

    var answer = await pc2.createAnswer();
    await pc2.setLocalDescription(answer);
    await pc1.setRemoteDescription(answer);

    pc1.onIceCandidate((IceCandidate candidate) async {
      await pc2.addIceCandidate(candidate);
    });

    pc2.onIceCandidate((IceCandidate candidate) async {
      await pc1.addIceCandidate(candidate);
    });

    await pc1vtrans.sender.replaceTrack(
        trackspc1.firstWhere((track) => track.kind() == MediaKind.video));

    await pc1atrans.sender.replaceTrack(
        trackspc1.firstWhere((track) => track.kind() == MediaKind.audio));

    await Future.wait(allFutures.map((e) => e.future))
        .timeout(const Duration(seconds: 5));
  });


  testWidgets('clone track', (WidgetTester tester) async {
    var caps = DeviceConstraints();
    caps.video.mandatory = DeviceVideoConstraints();
    caps.video.mandatory!.width = 640;
    caps.video.mandatory!.height = 480;
    caps.video.mandatory!.fps = 30;

    var pc1 = await PeerConnection.create(IceTransportType.all, []);
    var pc2 = await PeerConnection.create(IceTransportType.all, []);
    var onEndedComplete = Completer();
    pc2.onTrack((track, transceiver) {
      track.onEnded(() {
        onEndedComplete.complete();
      });
    });

    var vtrans1 = await pc1.addTransceiver(
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendOnly));
    var vtrans2 = await pc1.addTransceiver(
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendOnly));

    var tracks = await getUserMedia(caps);

    var videoTrack = tracks.firstWhere((track) => track.kind() == MediaKind.video);
    var cloneVideoTrack = await videoTrack.clone();
    await cloneVideoTrack.setEnabled(false);

    await vtrans1.sender.replaceTrack(videoTrack);
    await vtrans2.sender.replaceTrack(cloneVideoTrack);

    await pc2.setRemoteDescription(await pc1.createOffer());

    await (await pc2.getTransceivers())[0].stop();

    await onEndedComplete.future;
    expect(videoTrack.id(), isNot(equals(cloneVideoTrack.id())));
    expect(videoTrack.isEnabled(), isNot(equals(cloneVideoTrack.isEnabled())));
  });

  testWidgets('Media stream constraints', (WidgetTester tester) async {
    var capsVideoDeviceOnly = DeviceConstraints();
    capsVideoDeviceOnly.video.mandatory = DeviceVideoConstraints();
    capsVideoDeviceOnly.video.mandatory!.width = 640;
    capsVideoDeviceOnly.video.mandatory!.height = 480;
    capsVideoDeviceOnly.video.mandatory!.fps = 30;

    var capsVideoDisplayOnly = DisplayConstraints();
    capsVideoDisplayOnly.video.mandatory = DeviceVideoConstraints();
    capsVideoDisplayOnly.video.mandatory!.width = 640;
    capsVideoDisplayOnly.video.mandatory!.height = 480;
    capsVideoDisplayOnly.video.mandatory!.fps = 30;

    var capsAudioOnly = DeviceConstraints();
    capsAudioOnly.audio.mandatory = AudioConstraints();

    var capsVideoAudio = DeviceConstraints();
    capsVideoAudio.audio.mandatory = AudioConstraints();
    capsVideoAudio.video.mandatory = DeviceVideoConstraints();
    capsVideoAudio.video.mandatory!.width = 640;
    capsVideoAudio.video.mandatory!.height = 480;
    capsVideoAudio.video.mandatory!.fps = 30;

    var tracksAudioOnly = await getUserMedia(capsAudioOnly);
    bool video = tracksAudioOnly.any((track) => track.kind() == MediaKind.video);
    bool audio = tracksAudioOnly.any((track) => track.kind() == MediaKind.audio);
    expect(video, isFalse);
    expect(audio, isTrue);

    var tracksVideoDeviceOnly = await getUserMedia(capsVideoDeviceOnly);
    video = tracksVideoDeviceOnly.any((track) => track.kind() == MediaKind.video);
    audio = tracksVideoDeviceOnly.any((track) => track.kind() == MediaKind.audio);
    expect(video, isTrue);
    expect(audio, isFalse);

    var tracksVideoDisplayOnly = await getDisplayMedia(capsVideoDisplayOnly);
    video = tracksVideoDisplayOnly.any((track) => track.kind() == MediaKind.video);
    audio = tracksVideoDisplayOnly.any((track) => track.kind() == MediaKind.audio);
    expect(video, isTrue);
    expect(audio, isFalse);

    var tracksVideoAudio = await getUserMedia(capsVideoAudio);
    video = tracksVideoAudio.any((track) => track.kind() == MediaKind.video);
    audio = tracksVideoAudio.any((track) => track.kind() == MediaKind.audio);
    expect(video, isTrue);
    expect(audio, isTrue);

  });

  testWidgets('Boundle politic', (WidgetTester tester) async {
    var pc1 = await PeerConnection.create(IceTransportType.all, []);
    var pc2 = await PeerConnection.create(IceTransportType.all, []);

    var count1 = 0;
    var count2 = 0;
    var c1 = Completer();
    var c2 = Completer();
    pc1.onIceCandidate((candidate) async {
      ++count1;
      if (count1 == 1) {
        c1.complete();
      }
    });

    pc2.onIceCandidate((candidate) async {
      ++count2;
      if (count2 == 1) {
        c2.complete();
      }
    });
    await pc1.addTransceiver(
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));
    await pc1.addTransceiver(
        MediaKind.audio, RtpTransceiverInit(TransceiverDirection.sendRecv));

    await pc2.addTransceiver(
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));
    await pc2.addTransceiver(
        MediaKind.audio, RtpTransceiverInit(TransceiverDirection.sendRecv));

    var offer = await pc2.createOffer();
    await pc2.setLocalDescription(offer);
    await pc1.setRemoteDescription(offer); 

    var answer = await pc1.createAnswer();
    await pc1.setLocalDescription(answer);
    await pc2.setRemoteDescription(answer);

    // await c1.future;
    // await c2.future;

    print('___________________');
    print(count1);
    print(count2);
  });

    testWidgets('transceiver direction', (WidgetTester tester) async {
    var caps = DeviceConstraints();
    caps.audio.mandatory = AudioConstraints();
    caps.video.mandatory = DeviceVideoConstraints();
    caps.video.mandatory!.width = 640;
    caps.video.mandatory!.height = 480;
    caps.video.mandatory!.fps = 30;

    var trackspc1 = await getUserMedia(caps);

    var server =
      IceServer(['stun:stun.l.google.com:19302'], 'username', 'password');
    var pc1 = await PeerConnection.create(IceTransportType.all, [server]);
    var pc2 = await PeerConnection.create(IceTransportType.all, [server]);

    var allFutures = List<Completer>.generate(2, (_) => Completer());


    pc2.onTrack((track, trans) async {
      if (track.kind() == MediaKind.video) {
        // allFutures[0].complete();
      } else {
        allFutures[0].complete();
        allFutures[1].complete();
      }
    });

    var pc1vtrans = await pc1.addTransceiver(
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));    

    var pc1atrans = await pc1.addTransceiver(
        MediaKind.audio, RtpTransceiverInit(TransceiverDirection.sendRecv));

    var offer = await pc1.createOffer();
    await pc1.setLocalDescription(offer);
    await pc2.setRemoteDescription(offer);

    var answer = await pc2.createAnswer();
    await pc2.setLocalDescription(answer);
    await pc1.setRemoteDescription(answer);


    await pc1vtrans.sender.replaceTrack(
        trackspc1.firstWhere((track) => track.kind() == MediaKind.video));

    await pc1atrans.sender.replaceTrack(
        trackspc1.firstWhere((track) => track.kind() == MediaKind.audio));

    var complete = Completer();
    // pc1.onNegotiationNeeded(() => complete.complete());
    pc2.onNegotiationNeeded(() => complete.complete());

    
    // await (await pc1.getTransceivers())[1].setDirection(TransceiverDirection.recvOnly);
    // await (await pc1.getTransceivers())[0].stop();

    // // await pc1vtrans.setDirection(TransceiverDirection.recvOnly);
    // print(await (await pc1.getTransceivers())[0].getDirection());
    // print(await (await pc1.getTransceivers())[1].getDirection());
    // print(await pc1vtrans.getDirection());
    // print(await pc1atrans.getDirection());
    await (await pc1.getTransceivers())[0].setDirection(TransceiverDirection.sendOnly);
    await (await pc1.getTransceivers())[1].setDirection(TransceiverDirection.sendOnly);
    // await (await pc1.getTransceivers())[2].setDirection(TransceiverDirection.sendOnly);

    var pc1vtrans2 = await pc1.addTransceiver(
      MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));    

    offer = await pc1.createOffer();
    await pc1.setLocalDescription(offer);
    await pc2.setRemoteDescription(offer);

    answer = await pc2.createAnswer();
    await pc2.setLocalDescription(answer);
    await pc1.setRemoteDescription(answer);

    offer = await pc2.createOffer();
    await pc2.setLocalDescription(offer);
    await pc1.setRemoteDescription(offer);

    answer = await pc1.createAnswer();
    await pc1.setLocalDescription(answer);
    await pc2.setRemoteDescription(answer);

    await (await pc1.getTransceivers())[2].setDirection(TransceiverDirection.sendOnly);

    // await complete.future;
    print(await (await pc2.getTransceivers())[0].getDirection());
    print(await (await pc2.getTransceivers())[1].getDirection());
    print(await (await pc2.getTransceivers())[2].getDirection());
    print(await (await pc1.getTransceivers())[0].getDirection());
    print(await (await pc1.getTransceivers())[1].getDirection());
    print(await (await pc1.getTransceivers())[2].getDirection());


    await Future.wait(allFutures.map((e) => e.future))
        .timeout(const Duration(seconds: 5));
  });

  
}
