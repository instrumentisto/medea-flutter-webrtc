import 'dart:html' as html;

import '/src/model/output_audio_device_info.dart';
import '/src/platform/output_audio_devices.dart';
import '/src/platform/web/video_renderer.dart';

// ignore_for_file: avoid_web_libraries_in_flutter

/// Returns [OutputAudioDevices] for the platform on
/// which this function was called.
OutputAudioDevices createOutputAudioDevices() {
  return WebOutputAudioDevices();
}

class WebOutputAudioDevices implements OutputAudioDevices {
  @override
  Future<List<OutputAudioDeviceInfo>> enumerateDevices() async {
    return (await html.window.navigator.mediaDevices!.enumerateDevices())
        .map((i) => i as html.MediaDeviceInfo)
        .where((i) => i.kind == 'audiooutput')
        .map((i) => OutputAudioDeviceInfo(
            i.deviceId!, i.label!, OutputAudioDeviceInfoKind.unknown))
        .toList();
  }

  @override
  Future<void> setDevice(String deviceId) async {
    setOutputAudioSinkId(deviceId);
  }
}
