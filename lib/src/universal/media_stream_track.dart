import 'package:flutter_webrtc/src/model/media_kind.dart';

abstract class MediaStreamTrack {
  String id();

  MediaKind kind();

  String deviceId();

  bool isEnabled();

  Future<void> setEnabled(bool enabled);

  Future<void> stop();

  Future<void> dispose();
}