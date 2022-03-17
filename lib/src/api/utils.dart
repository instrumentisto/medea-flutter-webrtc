

import 'dart:ffi';
import 'dart:io';

export 'bridge_generated.dart';
import 'bridge_generated.dart';

const base = 'flutter_webrtc_native';
final path = Platform.isWindows ? '$base.dll' : 'lib$base.so';
late final dylib = Platform.isIOS
    ? DynamicLibrary.process()
    : Platform.isMacOS
        ? DynamicLibrary.executable()
        : DynamicLibrary.open(path);

late final api = FlutterWebrtcNativeImpl(dylib);