import 'package:flutter_webrtc/src/model/output_audio_device_info.dart';
import '/src/api/channel.dart';
import '/src/platform/output_audio_devices.dart';

/// Returns [OutputAudioDevices] for the platform on
/// which this function was called.
OutputAudioDevices createOutputAudioDevices() {
  return NativeOutputAudioDevices();
}

/// [MethodChannel] used for the messaging with a native side.
final _outputAudioDevicesMethodChannel = methodChannel('OutputAudioDevices', 0);

class NativeOutputAudioDevices implements OutputAudioDevices {
  @override
  Future<List<OutputAudioDeviceInfo>> enumerateDevices() async {
    List<dynamic> res =
        await _outputAudioDevicesMethodChannel.invokeMethod('enumerateDevices');
    return res.map((i) => OutputAudioDeviceInfo.fromMap(i)).toList();
  }

  @override
  Future<void> setDevice(String deviceId) async {
    await _outputAudioDevicesMethodChannel
        .invokeMethod('setDevice', {'deviceId': deviceId});
  }
}
