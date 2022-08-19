@JS()
library fake_media;

import 'package:js/js.dart';

@JS()
external enableMock();

/// Configures media acquisition to use fake devices instead of actual camera
/// and microphone.
///
/// This must be called before any other function to work properly.
Future<void> enableFakeMedia() async {
  enableMock();
}
