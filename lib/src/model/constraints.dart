class Constraints {
  ConstraintMap<AudioConstraints> audio = ConstraintMap();
  ConstraintMap<VideoConstraints> video = ConstraintMap();

  Map<String, dynamic> toMap() {
    return {
      'audio': audio.toMap(),
      'video': video.toMap(),
    };
  }
}

class ConstraintMap<T extends MediaConstraints> {
  T? mandatory;
  T? optional;

  Map<String, dynamic> toMap() {
    return {
      'mandatory': mandatory?.toMap(),
      'optional': optional?.toMap(),
    };
  }
}

abstract class MediaConstraints {
  Map<String, dynamic> toMap();
}

class AudioConstraints implements MediaConstraints {
  String? deviceId;

  @override
  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
    };
  }
}

enum FacingMode {
  user,
  environment,
}

class VideoConstraints implements MediaConstraints {
  String? deviceId;
  FacingMode? facingMode;

  @override
  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'facingMode': facingMode?.index,
    };
  }
}
