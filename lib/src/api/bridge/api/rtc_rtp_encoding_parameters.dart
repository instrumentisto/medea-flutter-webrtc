// This file is automatically generated, so please do not edit it.
// @generated by `flutter_rust_bridge`@ 2.11.1.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

import '../frb_generated.dart';

// These function are ignored because they are on traits that is not defined in current crate (put an empty `#[frb]` on it to unignore): `from`

/// Representation of [RTCRtpEncodingParameters][0].
///
/// [0]: https://w3.org/TR/webrtc#rtcrtpencodingparameters
class RtcRtpEncodingParameters {
  /// [RTP stream ID (RID)][0] to be sent using the RID header extension.
  ///
  /// [0]: https://w3.org/TR/webrtc#dom-rtcrtpcodingparameters-rid
  final String rid;

  /// Indicator whether the described [`RtcRtpEncodingParameters`] are
  /// currently actively being used.
  final bool active;

  /// Maximum number of bits per second to allow for these
  /// [`RtcRtpEncodingParameters`].
  final int? maxBitrate;

  /// Maximum number of frames per second to allow for these
  /// [`RtcRtpEncodingParameters`].
  final double? maxFramerate;

  /// Factor for scaling down the video with these
  /// [`RtcRtpEncodingParameters`].
  final double? scaleResolutionDownBy;

  /// Scalability mode describing layers within the media stream.
  final String? scalabilityMode;

  const RtcRtpEncodingParameters({
    required this.rid,
    required this.active,
    this.maxBitrate,
    this.maxFramerate,
    this.scaleResolutionDownBy,
    this.scalabilityMode,
  });

  @override
  int get hashCode =>
      rid.hashCode ^
      active.hashCode ^
      maxBitrate.hashCode ^
      maxFramerate.hashCode ^
      scaleResolutionDownBy.hashCode ^
      scalabilityMode.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RtcRtpEncodingParameters &&
          runtimeType == other.runtimeType &&
          rid == other.rid &&
          active == other.active &&
          maxBitrate == other.maxBitrate &&
          maxFramerate == other.maxFramerate &&
          scaleResolutionDownBy == other.scaleResolutionDownBy &&
          scalabilityMode == other.scalabilityMode;
}
