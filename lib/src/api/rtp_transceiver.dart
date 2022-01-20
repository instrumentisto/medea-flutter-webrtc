import 'package:flutter/services.dart';
import 'package:flutter_webrtc/src/api/rtp_sender.dart';
import 'package:flutter_webrtc/src/api/utils/channel_name_generator.dart';
import 'package:flutter_webrtc/src/model/transceiver_direction.dart';

class RtpTransceiver {
  RtpTransceiver.fromMap(Map<String, dynamic> map) {
    int channelId = map['channelId'];
    int senderChannelId = map['senderChannelId'];
    _methodChannel = MethodChannel(channelNameWithId('RtpTransceiver', channelId));
    _sender = RtpSender(senderChannelId);
  }

  late MethodChannel _methodChannel;
  late RtpSender _sender;
  String? _mid;
  bool _isStopped = false;
  RtpSender get sender => _sender;
  String? get mid => _mid;

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

  Future<void> stop() async {
    _isStopped = true;
    await _methodChannel.invokeMethod('stop');
  }

  bool isStopped() {
    return _isStopped;
  }
}
