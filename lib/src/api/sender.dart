import 'dart:io';

import 'package:flutter/services.dart';

import '/src/platform/track.dart';
import 'channel.dart';
import 'peer.dart';
import 'utils.dart';

abstract class RtpSender {
  static RtpSender fromMap(dynamic map) {
    RtpSender? sender;

    if (Platform.isAndroid || Platform.isIOS) {
      sender = _RtpSenderChannel.fromMap(map);
    } else {
      sender = _RtpSenderFFI();
    }

    return sender;
  }

  /// Current [MediaStreamTrack] of this [RtpSender].
  MediaStreamTrack? _track;

  /// Getter for the [MediaStreamTrack] currently owned by this [RtpSender].
  MediaStreamTrack? get track => _track;

  /// Replaces [MediaStreamTrack] of this [RtpSender].
  Future<void> replaceTrack(MediaStreamTrack? t);
}

class _RtpSenderChannel extends RtpSender {
  /// Creates an [RtpSender] basing on the [Map] received from the native side.
  _RtpSenderChannel.fromMap(dynamic map) {
    _chan = methodChannel('RtpSender', map['channelId']);
  }

  /// [MethodChannel] used for the messaging with the native side.
  late MethodChannel _chan;

  /// Replaces [MediaStreamTrack] of this [RtpSender].
  @override
  Future<void> replaceTrack(MediaStreamTrack? t) async {
    _track = t;
    await _chan.invokeMethod('replaceTrack', {'trackId': t?.id()});
  }
}

class _RtpSenderFFI extends RtpSender {
  @override
  Future<void> replaceTrack(MediaStreamTrack? t) async {
    api.senderReplaceTrack(peerId: 1, transceiverId: 2, trackId: 3);
  }
}
