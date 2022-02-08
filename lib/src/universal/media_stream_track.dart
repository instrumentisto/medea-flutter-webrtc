import 'package:flutter_webrtc/src/model/media_kind.dart';

/// Abstract representation of the one media unit on native or web side.
abstract class MediaStreamTrack {
  /// Returns unique identifier of this [MediaStreamTrack].
  String id();

  /// Returns [MediaKind] of this [MediaStreamTrack].
  MediaKind kind();

  /// Returns unique ID of the device from which this [MediaStremTrack]
  /// was created.
  String deviceId();

  /// Returns enabled state of the [MediaStreamTrack].
  ///
  /// If it's `false` then blank (black screen for video and 0dB for audio)
  /// media will be transmitted.
  bool isEnabled();

  /// Sets enabled state of the [MediaStreamTrack].
  ///
  /// If `false` is provided then blank (black screen for video and
  /// 0dB for audio) media will be transmitted.
  Future<void> setEnabled(bool enabled);

  /// Stops this [MediaStreamTrack].
  ///
  /// After this action [MediaStreamTrack] will stop trasmitting it's
  /// media data to the remote and local renderers.
  ///
  /// This action will unhold device in case of last local [MediaStreamTrack]s
  /// of some device.
  Future<void> stop();

  /// Creates new instance of [MediaStreamTrack], which will depend on the same
  /// media source as this [MediaStremTrack].
  ///
  /// If parent or child [MediaStreamTrack] will be stopped then another
  /// [MediaStreamTrack] will continue to work normally. But when all
  /// [MediaStreamTrack] dependent on the same device are stopped, then
  /// media device will be unholded.
  Future<MediaStreamTrack> clone();

  /// Disposes this [MediaStreamTrack] instance.
  Future<void> dispose();
}
