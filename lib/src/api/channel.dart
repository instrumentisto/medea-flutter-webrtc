import 'package:flutter/services.dart';

/// Prefix for the all channels created by the [flutter_webrtc].
const prefix = 'FlutterWebRtc';

/// Returns channel name with a provided `name` and `channelId`.
MethodChannel methodChannel(String name, int id) {
  return MethodChannel('$prefix/$name/$id');
}

EventChannel eventChannel(String name, int id) {
  return EventChannel('$prefix/$name/$id');
}
