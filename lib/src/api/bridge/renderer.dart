// This file is automatically generated, so please do not edit it.
// @generated by `flutter_rust_bridge`@ 2.9.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:freezed_annotation/freezed_annotation.dart' hide protected;

import 'frb_generated.dart';

part 'renderer.freezed.dart';

@freezed
sealed class TextureEvent with _$TextureEvent {
  const TextureEvent._();

  /// Height, width, or rotation have changed.
  const factory TextureEvent.onTextureChange({
    /// ID of the texture.
    required PlatformInt64 textureId,

    /// Width of the last processed frame.
    required int width,

    /// Height of the last processed frame.
    required int height,

    /// Rotation of the last processed frame.
    required int rotation,
  }) = TextureEvent_OnTextureChange;

  /// First frame event.
  const factory TextureEvent.onFirstFrameRendered({
    /// ID of the texture.
    required PlatformInt64 textureId,
  }) = TextureEvent_OnFirstFrameRendered;
}
