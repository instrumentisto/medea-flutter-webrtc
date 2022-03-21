import 'package:flutter/services.dart';

import '/src/model/transceiver.dart';
import 'bridge.g.dart';
import 'channel.dart';
import 'peer.dart';
import 'sender.dart';

abstract class RtpTransceiver {
  /// Creates an [RtpTransceiver] basing on the [Map] received from the native
  /// side.
  static RtpTransceiver fromMap(dynamic map, {int peerId = -1}) {
    RtpTransceiver? transceivers;

    if (IS_DESKTOP) {
      transceivers = _RtpTransceiverFFI.fromMap(map, peerId);
    } else {
      transceivers = _RtpTransceiverChannel.fromMap(map);
    }

    return transceivers;
  }

  /// [RtpSender] owned by this [RtpTransceiver].
  late RtpSender _sender;

  /// Current mID of this [RtpTransceiver].
  ///
  /// mID will be automatically updated on all actions changing it.
  String? _mid;

  /// Indicates that this [RtpTransceiver] is stopped and doesn't send or
  /// receive media.
  bool _isStopped = false;

  /// Getter for the [RtpSender] of this [RtpTransceiver].
  RtpSender get sender => _sender;

  /// Returns current mID of this [RtpTransceiver].
  String? get mid => _mid;

  /// Changes the [TransceiverDirection] of this [RtpTransceiver].
  Future<void> setDirection(TransceiverDirection direction);

  /// Returns current preferred [TransceiverDirection] of this [RtpTransceiver].
  Future<TransceiverDirection> getDirection();

  /// Synchronizes [_mid] of this [RtpTransceiver] with the native side.
  Future<void> syncMid();

  /// Stops this [RtpTransceiver].
  ///
  /// After this action, no media will be transferred from/to this
  /// [RtpTransceiver].
  Future<void> stop();

  /// Notifies the [RtpTransceiver] that it was stopped by the peer.
  void stoppedByPeer() {
    _isStopped = true;
  }

  /// Indicates whether this [RtpTransceiver] is not transferring media.
  bool isStopped() {
    return _isStopped;
  }
}

class _RtpTransceiverChannel extends RtpTransceiver {
  /// Creates an [RtpTransceiver] basing on the [Map] received from the native
  /// side.
  _RtpTransceiverChannel.fromMap(dynamic map) {
    int channelId = map['channelId'];
    _chan = methodChannel('RtpTransceiver', channelId);
    _sender = RtpSender.fromMap(map['sender']);
    _mid = map['mid'];
  }

  /// [MethodChannel] used for the messaging with the native side.
  late MethodChannel _chan;

  /// Changes the [TransceiverDirection] of this [RtpTransceiver].
  @override
  Future<void> setDirection(TransceiverDirection direction) async {
    await _chan.invokeMethod('setDirection', {'direction': direction.index});
  }

  /// Returns current preferred [TransceiverDirection] of this [RtpTransceiver].
  @override
  Future<TransceiverDirection> getDirection() async {
    int res = await _chan.invokeMethod('getDirection');
    return TransceiverDirection.values[res];
  }

  /// Synchronizes [_mid] of this [RtpTransceiver] with the native side.
  @override
  Future<void> syncMid() async {
    _mid = await _chan.invokeMethod('getMid');
  }

  /// Stops this [RtpTransceiver].
  ///
  /// After this action, no media will be transferred from/to this
  /// [RtpTransceiver].
  @override
  Future<void> stop() async {
    _isStopped = true;
    await _chan.invokeMethod('stop');
  }
}

class _RtpTransceiverFFI extends RtpTransceiver {
  _RtpTransceiverFFI.fromMap(dynamic map, int peerId) {
    _peerId = peerId;
    // _id = map['id'];
    // _sender =
    //     RtpSender.fromMap(map['sender'], peerId: _peerId!, transceiverId: _id!);
    // _mid = map['mid'];
  }

  int? _peerId;
  int? _id;

  @override
  Future<TransceiverDirection> getDirection() async {
    TransceiverDirection? direction;

    switch (await api.getTransceiverDirection(
        peerId: _peerId!, transceiverId: _id!)) {
      default:
        direction = TransceiverDirection.stopped;
    }

    return direction;
  }

  @override
  Future<void> setDirection(TransceiverDirection direction) async {
    RtpTransceiverDirection? direct;

    switch (direction) {
      case TransceiverDirection.sendRecv:
        direct = RtpTransceiverDirection.SendRecv;
        break;

      case TransceiverDirection.sendOnly:
        direct = RtpTransceiverDirection.SendOnly;
        break;

      case TransceiverDirection.recvOnly:
        direct = RtpTransceiverDirection.RecvOnly;
        break;

      case TransceiverDirection.stopped:
        direct = RtpTransceiverDirection.Stopped;
        break;

      case TransceiverDirection.inactive:
        direct = RtpTransceiverDirection.Inactive;
        break;
    }
    api.setTransceiverDirection(peerId: 1, transceiverId: 2, direction: direct);
  }

  @override
  Future<void> stop() async {
    api.stopTransceiver(peerId: 1, transceiverId: 2);
  }

  @override
  Future<void> syncMid() {
    // TODO: implement syncMid
    throw UnimplementedError();
  }
}
