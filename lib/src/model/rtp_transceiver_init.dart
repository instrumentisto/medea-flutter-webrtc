import 'package:flutter_webrtc/src/model/transceiver_direction.dart';

class RtpTransceiverInit {
  RtpTransceiverInit(TransceiverDirection direction) {
    this.direction = direction;
  }

  late TransceiverDirection direction;

  dynamic toMap() {
    return {
      'direction': direction.index
    };
  }
}