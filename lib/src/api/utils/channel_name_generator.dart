/// Prefix tag for the all channels created by the [flutter_webrtc].
const CHANNEL_TAG = 'com.instrumentisto.flutter_webrtc';

/// Returns channel name with a provided `name` and `channelId`.
String channelNameWithId(String name, int channelId) {
  return '$CHANNEL_TAG/$name/$channelId';
}

/// Returns channel name with a provided `name`.
String channelNameWithoutId(String name) {
  return '$CHANNEL_TAG/$name';
}
