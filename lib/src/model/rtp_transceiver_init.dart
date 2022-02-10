import '/src/model/transceiver_direction.dart';

/// Init config for `RtpTransceiver` creation.
class RtpTransceiverInit {
  /// Creates new [RtpTransceiverInit] config with a provided
  /// [TransceiverDirection].
  RtpTransceiverInit(TransceiverDirection direction) {
    this.direction = direction;
  }

  /// Direction of `RtpTransceiver` which will be created from this config.
  late TransceiverDirection direction;

  /// Converts this model to the [Map] expected by Flutter.
  Map<String, dynamic> toMap() {
    return {'direction': direction.index};
  }
}
