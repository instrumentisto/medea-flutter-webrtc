export 'native/output_audio_devices.dart'
    if (dart.library.html) 'web/output_audio_devices.dart';

import 'package:flutter_webrtc/src/model/output_audio_device_info.dart';

/// Output audio devices manager.
abstract class OutputAudioDevices {
  /// Returns [OutputAudioDeviceInfo] list.
  Future<List<OutputAudioDeviceInfo>> enumerateDevices();

  /// Switches output audio device to the provided [deviceId].
  ///
  /// List of output audio devices can be obtained by [enumerateDevices].
  Future<void> setDevice(String deviceId);
}