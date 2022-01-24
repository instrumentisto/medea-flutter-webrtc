import 'package:flutter/services.dart';
import 'package:flutter_webrtc/src/universal/native/media_stream_track.dart';
import 'package:flutter_webrtc/src/api/utils/channel_name_generator.dart';
import 'package:flutter_webrtc/src/model/constraints.dart';
import 'package:flutter_webrtc/src/model/media_device_info.dart';

const _mediaDevicesMethodChannel = MethodChannel('$CHANNEL_TAG/MediaDevices');

Future<List<MediaDeviceInfo>> enumerateDevices() async {
  List<dynamic> res =
      await _mediaDevicesMethodChannel.invokeMethod('enumerateDevices');
  return res.map((i) => MediaDeviceInfo.fromMap(i)).toList();
}

Future<List<NativeMediaStreamTrack>> getUserMedia(Constraints constraints) async {
  List<dynamic> res = await _mediaDevicesMethodChannel
      .invokeMethod('getUserMedia', {'constraints': constraints.toMap()});
  return res.map((t) => NativeMediaStreamTrack.fromMap(t)).toList();
}
