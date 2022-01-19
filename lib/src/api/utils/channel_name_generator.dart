const CHANNEL_TAG = 'com.instrumentisto.flutter_webrtc';

String channelNameWithId(String name, int channelId) {
  return '$CHANNEL_TAG/$name/$channelId';
}

String channelNameWithoutId(String name) {
  return '$CHANNEL_TAG/$name';
}
