// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '/src/platform/native/video_renderer.dart';
import 'track.dart';

export 'native/video_renderer.dart'
    if (dart.library.html) 'web/video_renderer.dart';

/// Using for describe steaming video.
@immutable
class RTCVideoValue {
  const RTCVideoValue({
    this.width = 0.0,
    this.height = 0.0,
    this.rotation = 0,
    this.renderVideo = false,
  });

  /// An empty instance of [RTCVideoValue].
  static const RTCVideoValue empty = RTCVideoValue();

  /// Width of the video.
  final double width;

  /// Height of the video.
  final double height;

  /// Rotation of the video.
  final int rotation;

  /// Describes to render video or not.
  final bool renderVideo;

  /// Returns an aspect ratio of the [RTCVideoValue].
  double get aspectRatio {
    if (width == 0.0 || height == 0.0) {
      return 1.0;
    }
    return (rotation == 90 || rotation == 270)
        ? height / width
        : width / height;
  }

  RTCVideoValue copyWith({
    double? width,
    double? height,
    int? rotation,
    bool renderVideo = true,
  }) {
    return RTCVideoValue(
      width: width ?? this.width,
      height: height ?? this.height,
      rotation: rotation ?? this.rotation,
      renderVideo: this.width != 0 && this.height != 0 && renderVideo,
    );
  }

  @override
  String toString() =>
      '$runtimeType(width: $width, height: $height, rotation: $rotation)';
}

abstract class VideoRenderer extends ValueNotifier<RTCVideoValue> {
  VideoRenderer() : super(RTCVideoValue.empty);

  /// On resize handler.
  Function? onResize;

  /// `Width` of the video.
  int get videoWidth;

  /// `Height` of the video.
  int get videoHeight;

  /// Mirroring of the video.
  set mirror(bool mirror);

  /// Describes to render video or not.
  bool get renderVideo;

  /// `Id` if the used [Texture].
  int? get textureId;

  /// Using to initialize the [VideoRenderer].
  Future<void> initialize();

  /// Reutrns the source of [VideoRenderer] as [MediaStreamTrack].
  MediaStreamTrack? get srcObject;

  /// Sets the source of [VideoRenderer].
  set srcObject(MediaStreamTrack? track);

  @override
  @mustCallSuper
  Future<void> dispose() async {
    super.dispose();
    return Future.value();
  }
}

/// Fitting of the [VideoView].
enum VideoViewObjectFit {
  contain,
  cover,
}

/// Creates a new [VideoRenderer].
VideoRenderer createVideoRenderer() {
  return createPlatformSpecificVideoRenderer();
}
