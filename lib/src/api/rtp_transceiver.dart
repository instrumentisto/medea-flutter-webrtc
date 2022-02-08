import 'package:flutter/services.dart';

import 'package:flutter_webrtc/src/api/rtp_sender.dart';
import 'package:flutter_webrtc/src/api/utils/channel_name_generator.dart';
import 'package:flutter_webrtc/src/model/transceiver_direction.dart';

class RtpTransceiver {
  /// Creates [RtpTransceiver] based on the [Map] received from the native side.
  RtpTransceiver.fromMap(dynamic map) {
    int channelId = map['channelId'];
    _methodChannel =
        MethodChannel(channelNameWithId('RtpTransceiver', channelId));
    _sender = RtpSender.fromMap(map['sender']);
    _mid = map['mid'];
  }

  /// [MethodChannel] used for the messaging with a native side.
  late MethodChannel _methodChannel;

  /// [RtpSender] owned by this [RtpTransceiver].
  late RtpSender _sender;

  /// Current mid of this [RtpTransceiver].
  ///
  /// Mid will be automatically updated on all actions which change it.
  String? _mid;

  /// Indicates that this [RtpTransceiver] is stopped and doesn't
  /// send/recv media.
  bool _isStopped = false;

  /// Getter for the [RtpSender] of this [RtpTransceiver].
  RtpSender get sender => _sender;

  /// Returns current mid of this [RtpTransceiver].
  String? get mid => _mid;

  /// Changes [TransceiverDirection] of this [RtpTransceiver].
  Future<void> setDirection(TransceiverDirection direction) async {
    await _methodChannel
        .invokeMethod('setDirection', {'direction': direction.index});
  }

  /// Returns current preffered [TransceiverDirection] of this [RtpTransceiver].
  Future<TransceiverDirection> getDirection() async {
    int res = await _methodChannel.invokeMethod('getDirection');
    return TransceiverDirection.values[res];
  }

  /// Synchonizes [_mid] of this [RtpTransceiver] with a native side.
  Future<void> syncMid() async {
    _mid = await _methodChannel.invokeMethod('getMid');
  }

  /// Stops this [RtpTransceiver].
  ///
  /// After this action, no media will be transferred from/to this [RtpTransceiver].
  Future<void> stop() async {
    _isStopped = true;
    await _methodChannel.invokeMethod('stop');
  }

  /// Notifies [RtpTransceiver] that it was stopped by peer.
  void stoppedByPeer() {
    _isStopped = true;
  }

  /// Indicates that this [RtpTransceiver] is not transfering media.
  bool isStopped() {
    return _isStopped;
  }
}
