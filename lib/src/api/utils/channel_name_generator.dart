/// Prefix tag for the all channels created by the [flutter_webrtc].
const CHANNEL_TAG = 'FlutterWebRtc';

/// Returns channel name with a provided `name` and `channelId`.
String channelNameWithId(String name, int channelId) {
  return '$CHANNEL_TAG/$name/$channelId';
}
