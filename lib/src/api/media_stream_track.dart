import 'package:flutter/services.dart';
import 'package:flutter_webrtc/src/api/utils/channel_name_generator.dart';
import 'package:flutter_webrtc/src/model/media_kind.dart';

class MediaStreamTrack {
  MediaStreamTrack.fromMap(Map<String, dynamic> map) {
    _methodChannel =
        MethodChannel(channelNameWithId('MediaStreamTrack', map['channelId']));
    _id = map['id'];
    _deviceId = map['deviceId'];
    _kind = MediaKind.values[map['kind']];
  }

  bool _enabled = true;

  late String _id;
  late MediaKind _kind;
  late String _deviceId;

  late MethodChannel _methodChannel;

  String id() {
    return _id;
  }

  MediaKind kind() {
    return _kind;
  }

  String deviceId() {
    return _deviceId;
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
