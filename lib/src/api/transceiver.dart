import 'package:flutter/services.dart';

import '/src/model/transceiver.dart';
import 'bridge.g.dart' as ffi;
import 'channel.dart';
import 'peer.dart';
import 'sender.dart';
import 'utils.dart';

abstract class RtpTransceiver {
  /// Creates an [RtpTransceiver] basing on the [Map] received from the native
  /// side.
  static RtpTransceiver fromMap(dynamic map) {
    return _RtpTransceiverChannel.fromMap(map);
  }

  static RtpTransceiver fromFFI(ffi.RtcRtpTransceiver transceiver) {
    return RtpTransceiverFFI(transceiver);
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

class RtpTransceiverFFI extends RtpTransceiver {
  RtpTransceiverFFI(ffi.RtcRtpTransceiver transceiver) {
    _peerId = transceiver.peerId;
    _id = transceiver.id;
    _sender = RtpSender.fromFFI(_peerId, _id);
    _mid = transceiver.mid;
  }

  late final int _peerId;
  late final int _id;

  int get id => _id;

  @override
  Future<TransceiverDirection> getDirection() async {
    TransceiverDirection? direction;

    switch (await api.getTransceiverDirection(
        peerId: _peerId, transceiverId: _id)) {
      default:
        direction = TransceiverDirection.stopped;
    }

    return direction;
  }

  @override
  Future<void> setDirection(TransceiverDirection direction) async {
    api.setTransceiverDirection(
        peerId: _peerId,
        transceiverId: _id,
        direction: ffi.RtpTransceiverDirection.values[direction.index]);
  }

  @override
  Future<void> stop() async {
    api.stopTransceiver(peerId: _peerId, transceiverId: _id);
  }

  @override
  Future<void> syncMid() {
    // TODO: implement syncMid
    throw UnimplementedError();
  }
}
