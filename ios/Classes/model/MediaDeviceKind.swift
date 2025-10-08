/// Possible kinds of a media device.
enum MediaDeviceKind: Int {
  /// Audio input device (for example, a microphone).
  case audioInput

  /// Video input device (for example, a webcam).
  case audioOutput

  /// Audio output device (for example, a pair of headphones).
  case videoInput
}

/// Audio-specific classification of device types mirroring Android/Dart
/// `AudioDeviceKind`.
///
/// Used to provide additional semantics for `MediaDeviceKind.audioOutput`
/// entries and serialized
/// to Flutter under the `audioKind` key of `MediaDeviceInfo`.
enum AudioDeviceKind: Int {
  /// Built-in earpiece speaker.
  case earSpeaker

  /// Built-in loudspeaker.
  case speakerphone

  /// Wired headphones without microphone.
  case wiredHeadphones

  /// Wired headset with a microphone.
  case wiredHeadset

  /// USB headphones without microphone.
  case usbHeadphones

  /// USB headset with a microphone.
  case usbHeadset

  /// Bluetooth headphones profile (A2DP/BLE speaker).
  case bluetoothHeadphones

  /// Bluetooth headset profile suitable for calls (SCO/BLE headset).
  case bluetoothHeadset
}
