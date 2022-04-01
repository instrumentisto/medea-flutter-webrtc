import '/src/platform/track.dart';
import 'peer.dart';

/// [RTCSender][1] implementation.
///
/// [1]: https://w3.org/TR/webrtc#dom-rtcrtpsender
class RtpSender {
  /// `ID` of the native side peer.
  final int _peerId;

  /// `ID` of the native side transceiver.
  final int _transceiverId;

  /// Create a new [RtpSender] from the provided [peerId] and [transceiverId].
  RtpSender(this._peerId, this._transceiverId);

  /// Current [MediaStreamTrack] of this [RtpSender].
  MediaStreamTrack? _track;

  /// Getter for the [MediaStreamTrack] currently owned by this [RtpSender].
  MediaStreamTrack? get track => _track;

  /// Replaces [MediaStreamTrack] of this [RtpSender].
  Future<void> replaceTrack(MediaStreamTrack? t) async {
    await api.senderReplaceTrack(
        peerId: _peerId,
        transceiverIndex: _transceiverId,
        trackId: t == null ? null : int.parse(t.id()));
  }
}
