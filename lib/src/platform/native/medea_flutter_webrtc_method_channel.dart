import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

final isIOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

/// MethodChannel bridge for iOS-only helpers in `medea_flutter_webrtc`.
///
/// This is used for small platform-specific actions that don’t fit the main
/// WebRTC API surface (e.g., restoring the iOS `AVAudioSession` to an idle state).
class MedeaFlutterWebrtcMethodChannel {
  static const MethodChannel _channel = MethodChannel('medea_flutter_webrtc');

  /// In-flight guard to avoid multiple concurrent calls to the same iOS method.
  static Future<void>? _inFlight;

  /// Resets the iOS audio session back to an “idle” state.
  ///
  /// No-op on non-iOS platforms. On iOS, this invokes the native
  /// `setIdleAudioSession` implementation and coalesces concurrent callers
  /// into a single in-flight invocation.
  static Future<void> setIdleAudioSession() {
    if (!isIOS) return Future.value();

    _inFlight ??= _channel
        .invokeMethod<void>('setIdleAudioSession')
        .whenComplete(() => _inFlight = null);

    return _inFlight!;
  }
}
