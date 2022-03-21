import 'package:flutter/services.dart';

import '/src/platform/track.dart';
import 'channel.dart';
import 'peer.dart';

abstract class RtpSender {
  static RtpSender fromMap(dynamic map,
      {int peerId = -1, int transceiverId = -1}) {
    RtpSender? sender;

    if (IS_DESKTOP) {
      sender = _RtpSenderFFI(peerId, transceiverId);
    } else {
      sender = _RtpSenderChannel.fromMap(map);
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
  final int _peerId;
  final int _transceiverId;

  _RtpSenderFFI(this._peerId, this._transceiverId);

  @override
  Future<void> replaceTrack(MediaStreamTrack? t) async {
    api.senderReplaceTrack(
        peerId: _peerId,
        transceiverId: _transceiverId,
        trackId: t != null ? int.parse(t.id()) : -1);
  }
}
