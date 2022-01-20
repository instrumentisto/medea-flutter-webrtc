import 'package:flutter/services.dart';
import 'package:flutter_webrtc/src/api/utils/channel_name_generator.dart';
import 'package:flutter_webrtc/src/model/media_kind.dart';
import '../media_stream_track.dart';

class NativeMediaStreamTrack extends MediaStreamTrack {
  NativeMediaStreamTrack.fromMap(Map<String, dynamic> map) {
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

  @override
  String id() {
    return _id;
  }

  @override
  MediaKind kind() {
    return _kind;
  }

  @override
  String deviceId() {
    return _deviceId;
  }

  @override
  bool isEnabled() {
    return _enabled;
  }

  @override
  Future<void> setEnabled(bool enabled) async {
    await _methodChannel.invokeMethod('setEnabled', {'enabled': true});
    _enabled = enabled;
  }

  @override
  Future<void> stop() async {
    await _methodChannel.invokeMethod('stop');
  }

  // TODO(evdokimovs): implement disposing for native side
  @override
  Future<void> dispose() async {
  }
}
