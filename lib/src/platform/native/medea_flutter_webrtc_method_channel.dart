import 'package:flutter/services.dart';

import 'package:flutter/foundation.dart';

final isIOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

class MedeaFlutterWebrtcMethodChannel {
  static const MethodChannel _channel = MethodChannel('medea_flutter_webrtc');

  // Optional: prevent multiple simultaneous calls
  static Future<void>? _inFlight;

  static Future<void> setIdleAudioSession() {
    if (!isIOS) return Future.value();

    _inFlight ??= _channel
        .invokeMethod<void>('setIdleAudioSession')
        .whenComplete(() => _inFlight = null);

    return _inFlight!;
  }
}
