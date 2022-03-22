// import 'dart:ffi';
// import 'dart:io';
//
// import 'bridge.g.dart';
//
// export 'bridge.g.dart';
//
// late final ffi.FlutterWebrtcNativeImpl api = buildBridge();
//
// ffi.FlutterWebrtcNativeImpl buildBridge() {
//   const base = 'flutter_webrtc_native';
//   final path = Platform.isWindows ? '$base.dll' : 'lib$base.so';
//   late final dylib = Platform.isMacOS
//       ? DynamicLibrary.executable()
//       : DynamicLibrary.open(path);
//
//   return ffi.FlutterWebrtcNativeImpl(dylib);
// }
