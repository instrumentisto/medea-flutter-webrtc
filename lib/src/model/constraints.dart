/// Audio and video constraints data.
class Constraints {
  /// Optional constraints with which audio devices will be lookuped.
  ConstraintMap<AudioConstraints> audio = ConstraintMap();

  /// Optional constraints with which video devices will be lookuped.
  ConstraintMap<VideoConstraints> video = ConstraintMap();

  /// Converts this model to the [Map] expected by Flutter.
  dynamic toMap() {
    return {
      'audio': audio.toMap(),
      'video': video.toMap(),
    };
  }
}

/// Abstract constraint property.
class ConstraintMap<T extends MediaConstraints> {
  /// Storage for the mandatory constraint.
  T? mandatory;

  /// Storage for the optional constraint.
  T? optional;

  /// Converts this model to the [Map] expected by Flutter.
  dynamic toMap() {
    return {
      'mandatory': mandatory?.toMap(),
      'optional': optional?.toMap(),
    };
  }
}

/// Some abstract constraints.
abstract class MediaConstraints {
  /// Converts [MediaConstraints] to the [Map] expected by Flutter.
  dynamic toMap();
}

/// [MediaConstraints] for the audio devices.
class AudioConstraints implements MediaConstraints {
  String? deviceId;

  /// Converts this model to the [Map] expected by Flutter.
  @override
  dynamic toMap() {
    var map = {};
    if (deviceId != null) {
      map['deviceId'] = deviceId;
    }
    return map;
  }
}

/// Direction in which the camera producing the video.
enum FacingMode {
  /// Indicates that video source is facing toward the user;
  /// this includes, for example, the front-facing camera on
  /// a smartphone.
  user,

  /// Indicates that video source is facing away from the user,
  /// thereby viewing their environment.
  ///
  /// This is the back camera on a smartphone.
  environment,
}

/// Constraints related to the video.
class VideoConstraints implements MediaConstraints {
  // TODO(#31): height, width, fps
  /// Constraint which will search for device with some concrete device ID.
  String? deviceId;

  /// Constraint which will search for device with some [FacingMode].
  FacingMode? facingMode;

  /// Converts this model to the [Map] expected by Flutter.
  @override
  dynamic toMap() {
    var map = {};
    if (deviceId != null) {
      map['deviceId'] = deviceId;
    }
    if (facingMode != null) {
      map['facingMode'] = facingMode!.index;
    }
    return map;
  }
}
