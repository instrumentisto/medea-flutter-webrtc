import 'package:flutter/services.dart';
import 'package:flutter_webrtc/src/model/transceiver_direction.dart';

class RtpTransceiver {
  RtpTransceiver.fromMap(Map<String, dynamic> map) {
    String channelId = map['channelId'];
    _methodChannel = MethodChannel(channelId);
  }

  late MethodChannel _methodChannel;
  String? _mid;
  bool _isStopped = false;

  Future<void> setDirection(TransceiverDirection direction) async {
    await _methodChannel
        .invokeMethod('setDirection', {'direction': direction.index});
  }

  Future<TransceiverDirection> getDirection() async {
    int res = await _methodChannel.invokeMethod('getDirection');
    return TransceiverDirection.values[res];
  }

  Future<void> syncMid() async {
    _mid = await _methodChannel.invokeMethod('getMid');
  }

  String? mid() {
    return _mid;
  }

  Future<void> stop() async {
    _isStopped = true;
    await _methodChannel.invokeMethod('stop');
  }

  bool isStopped() {
    return _isStopped;
  }
}
