import '/src/model/transceiver.dart';
import 'bridge.g.dart' as ffi;
import 'peer.dart';
import 'sender.dart';

/// [RTCTransceiver][1] representation
///
/// [1]: https://w3.org/TR/webrtc#dom-rtcrtptransceiver
class RtpTransceiver {
  RtpTransceiver(ffi.RtcRtpTransceiver transceiver) {
    _peerId = transceiver.peerId;
    _id = transceiver.index;
    _sender = RtpSender(_peerId, _id);
    _mid = transceiver.mid;
  }

  /// `ID` of the native side peer.
  late final int _peerId;

  /// `ID` of the native side transceiver`.
  late final int _id;

  /// Returns an `ID` of the native side peer.
  int get id => _id;

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
  Future<void> setDirection(TransceiverDirection direction) async {
    await api.setTransceiverDirection(
        peerId: _peerId,
        transceiverIndex: _id,
        direction: ffi.RtpTransceiverDirection.values[direction.index]);
  }

  /// Returns current preferred [TransceiverDirection] of this [RtpTransceiver].
  Future<TransceiverDirection> getDirection() async {
    return TransceiverDirection.values[(await api.getTransceiverDirection(
            peerId: _peerId, transceiverIndex: _id))
        .index];
  }

  /// Synchronizes [_mid] of this [RtpTransceiver] with the native side.
  Future<void> syncMid() async {
    _mid = await api.getTransceiverMid(peerId: _peerId, transceiverIndex: _id);
  }

  /// Stops this [RtpTransceiver].
  ///
  /// After this action, no media will be transferred from/to this
  /// [RtpTransceiver].
  Future<void> stop() async {
    await api.stopTransceiver(peerId: _peerId, transceiverIndex: _id);
  }

  /// Notifies the [RtpTransceiver] that it was stopped by the peer.
  void stoppedByPeer() {
    _isStopped = true;
  }

  /// Indicates whether this [RtpTransceiver] is not transferring media.
  bool isStopped() {
    return _isStopped;
  }
}
