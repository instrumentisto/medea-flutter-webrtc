import 'dart:ffi';
import 'dart:io';

import 'package:flutter/services.dart';

import 'bridge_generated.dart';


const base = 'flutter_webrtc_native';
final path = Platform.isWindows ? '$base.dll' : 'lib$base.so';
late final dylib = Platform.isIOS
    ? DynamicLibrary.process()
    : Platform.isMacOS
        ? DynamicLibrary.executable()
        : DynamicLibrary.open(path);

late final api = FlutterWebrtcNativeImpl(dylib);

class WebRTC {
  static const MethodChannel _channel = MethodChannel('FlutterWebRTC.Method');

  static bool get platformIsDesktop =>
      Platform.isWindows ||
      Platform.isLinux ||
      Platform.isMacOS ||
      Platform.isLinux;

  static bool get platformIsWindows => Platform.isWindows;

  static bool get platformIsLinux => Platform.isLinux;

  static bool get platformIsMobile => Platform.isIOS || Platform.isAndroid;

  static bool get platformIsIOS => Platform.isIOS;

  static bool get platformIsAndroid => Platform.isAndroid;

  static bool get platformIsWeb => false;

  static Future<T?> invokeMethod<T, P>(String methodName,
          [dynamic param]) async =>
      _channel.invokeMethod<T>(
        methodName,
        param,
      );
}
