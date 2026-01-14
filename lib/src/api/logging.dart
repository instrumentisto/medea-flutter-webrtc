import 'dart:io';

import 'package:flutter/services.dart';

import 'bridge/api.dart' as ffi;
import 'channel.dart';

/// Supported logging levels.
enum LogLevel {
  /// Verbose.
  verbose,

  /// Info.
  info,

  /// Warning.
  warning,

  /// Error.
  error,
}

/// Checks whether the running platform is a desktop.
final bool _isDesktop =
    Platform.isWindows || Platform.isLinux || Platform.isMacOS;

/// [MethodChannel] used for the logging-related messaging with a native side.
final MethodChannel _loggingMethodChannel = methodChannel('logging', 0);

/// Sets the logging level for the native-side.
///
/// Default logging level for the Rust-side is [LogLevel.warning].
/// Logging in `libwebrtc` is disabled in release builds and is [LogLevel.info]
/// in debug builds by default.
Future<void> setLogLevel(LogLevel level) async {
  if (_isDesktop) {
    await ffi.setLogLevel(level: ffi.LogLevel.values[level.index]);
  } else {
    await _loggingMethodChannel.invokeMethod('setLogLevel', {
      'level': level.index,
    });
  }
}
