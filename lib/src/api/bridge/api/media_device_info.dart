// This file is automatically generated, so please do not edit it.
// @generated by `flutter_rust_bridge`@ 2.10.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

import '../frb_generated.dart';

// These function are ignored because they are on traits that is not defined in current crate (put an empty `#[frb]` on it to unignore): `assert_receiver_is_total_eq`, `clone`, `eq`, `fmt`, `fmt`

/// Returns a list of all available media input and output devices, such as
/// microphones, cameras, headsets, and so forth.
Future<List<MediaDeviceInfo>> enumerateDevices() =>
    RustLib.instance.api.crateApiMediaDeviceInfoEnumerateDevices();

/// Information describing a single media input or output device.
class MediaDeviceInfo {
  /// Unique identifier for the represented device.
  final String deviceId;

  /// Kind of the represented device.
  final MediaDeviceKind kind;

  /// Label describing the represented device.
  final String label;

  const MediaDeviceInfo({
    required this.deviceId,
    required this.kind,
    required this.label,
  });

  @override
  int get hashCode => deviceId.hashCode ^ kind.hashCode ^ label.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaDeviceInfo &&
          runtimeType == other.runtimeType &&
          deviceId == other.deviceId &&
          kind == other.kind &&
          label == other.label;
}

/// Possible kinds of media devices.
enum MediaDeviceKind {
  /// Audio input device (for example, a microphone).
  audioInput,

  /// Audio output device (for example, a pair of headphones).
  audioOutput,

  /// Video input device (for example, a webcam).
  videoInput,
}
