import 'package:flutter/services.dart';
import 'package:flutter_webrtc/src/api/media_stream_track.dart';
import 'package:flutter_webrtc/src/api/utils/channel_name_generator.dart';
import 'package:flutter_webrtc/src/model/constraints.dart';
import 'package:flutter_webrtc/src/model/media_device_info.dart';

const _mediaDevicesMethodChannel = MethodChannel('$CHANNEL_TAG/MediaDevices');

Future<List<MediaDeviceInfo>> enumerateDevices() async {
  List<Map<String, dynamic>> res =
      await _mediaDevicesMethodChannel.invokeMethod('enumerateDevices');
  return res.map((i) => MediaDeviceInfo.fromMap(i)).toList();
}

Future<List<MediaStreamTrack>> getUserMedia(Constraints constraints) async {
  List<Map<String, dynamic>> res = await _mediaDevicesMethodChannel
      .invokeMethod('getUserMedia', {'constraints': constraints.toMap()});
  return res.map((t) => MediaStreamTrack.fromMap(t)).toList();
}
