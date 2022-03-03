/// Kind of the [OutputAudioDeviceInfo].
enum OutputAudioDeviceInfoKind {
  /// Audio will be played on the ear speaker.
  earSpeaker,

  /// Audio will be played on the speakerphone.
  speakerphone,

  /// Audio will be played on some audio device which can't be assigned to the
  /// other [OutputAudioDeviceInfoKind]. Speakers in the browser, for example.
  unknown,
}

/// Information about some output audio device.
class OutputAudioDeviceInfo {
  /// Create a [OutputAudioDeviceInfo] based on the provided properties.
  OutputAudioDeviceInfo(this.deviceId, this.label, this.kind);

  /// Creates a [OutputAudioDeviceInfo] basing on the [Map] received from the
  /// native side.
  OutputAudioDeviceInfo.fromMap(dynamic map) {
    deviceId = map['deviceId'];
    label = map['label'];
    kind = OutputAudioDeviceInfoKind.values[map['kind']];
  }
  
  /// Identifier of the represented device.
  late String deviceId;
  
  /// Human-readable device description (for example, "Ear speaker").
  late String label;
  
  /// Kind of the device.
  late OutputAudioDeviceInfoKind kind;
}