import 'package:flutter/services.dart';
import 'package:flutter_webrtc/src/model/transceiver_direction.dart';

class RtpTransceiver {
  RtpTransceiver.fromMap(Map<String, dynamic> map) {
    String channelId = map['channelId'];
    _methodChannel = MethodChannel(channelId);
  }

  late MethodChannel _methodChannel;

  Future<void> setDirection(TransceiverDirection direction) async {
    await _methodChannel
        .invokeMethod('setDirection', {'direction': direction.index});
  }

  Future<TransceiverDirection> getDirection() async {
    int res = await _methodChannel.invokeMethod('getDirection');
    return TransceiverDirection.values[res];
  }

  String? mid() {
    throw UnimplementedError();
  }

  bool isStopped() {
    throw UnimplementedError();
  }
}
