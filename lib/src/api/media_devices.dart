import 'package:flutter/services.dart';

import '/src/api/utils/channel_name_generator.dart';
import '/src/model/constraints.dart';
import '/src/model/media_device_info.dart';
import '/src/universal/native/media_stream_track.dart';

/// [MethodChannel] used for the messaging with a native side.
const _mediaDevicesMethodChannel = MethodChannel('$CHANNEL_TAG/MediaDevices');

/// Returns list of [MediaDeviceInfo]s for the currently available devices.
Future<List<MediaDeviceInfo>> enumerateDevices() async {
  List<dynamic> res =
      await _mediaDevicesMethodChannel.invokeMethod('enumerateDevices');
  return res.map((i) => MediaDeviceInfo.fromMap(i)).toList();
}

/// Returns list of local audio and video [NativeMediaStreamTrack]s based on
/// the provided [Constraints].
Future<List<NativeMediaStreamTrack>> getUserMedia(
    Constraints constraints) async {
  List<dynamic> res = await _mediaDevicesMethodChannel
      .invokeMethod('getUserMedia', {'constraints': constraints.toMap()});
  return res.map((t) => NativeMediaStreamTrack.fromMap(t)).toList();
}
// TODO(#31): getDisplayMedia
