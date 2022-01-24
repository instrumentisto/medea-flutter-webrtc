class Constraints {
  ConstraintMap<AudioConstraints> audio = ConstraintMap();
  ConstraintMap<VideoConstraints> video = ConstraintMap();

  dynamic toMap() {
    return {
      'audio': audio.toMap(),
      'video': video.toMap(),
    };
  }
}

class ConstraintMap<T extends MediaConstraints> {
  T? mandatory;
  T? optional;

  dynamic toMap() {
    return {
      'mandatory': mandatory?.toMap(),
      'optional': optional?.toMap(),
    };
  }
}

abstract class MediaConstraints {
  dynamic toMap();
}

class AudioConstraints implements MediaConstraints {
  String? deviceId;

  @override
  dynamic toMap() {
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

  VideoConstraints(this.deviceId, this.facingMode);

  @override
  dynamic toMap() {
    return {
      'deviceId': deviceId,
      'facingMode': facingMode?.index,
    };
  }
}
