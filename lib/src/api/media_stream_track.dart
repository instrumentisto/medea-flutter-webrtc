import 'package:flutter/services.dart';
import 'package:flutter_webrtc/src/api/utils/channel_name_generator.dart';
import 'package:flutter_webrtc/src/model/media_kind.dart';

class MediaStreamTrack {
  MediaStreamTrack.fromMap(Map<String, dynamic> map) {
    _methodChannel =
        MethodChannel(channelNameWithId('MediaStreamTrack', map['channelId']));
  }

  bool _enabled = true;

  late MethodChannel _methodChannel;

  String id() {
    throw UnimplementedError();
  }

  MediaKind kind() {
    throw UnimplementedError();
  }

  String deviceId() {
    throw UnimplementedError();
  }

  bool isEnabled() {
    return _enabled;
  }

  Future<void> setEnabled(bool enabled) async {
    await _methodChannel.invokeMethod('setEnabled', {'enabled': true});
    _enabled = enabled;
  }

  Future<void> stop() async {
    await _methodChannel.invokeMethod('stop');
  }
}
