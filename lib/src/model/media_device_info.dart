enum MediaDeviceKind {
  audioinput,
  audiooutput,
  videoinput,
  videooutput,
}

class MediaDeviceInfo {
  MediaDeviceInfo.fromMap(Map<String, dynamic> map) {
    deviceId = map['deviceId'];
    label = map['label'];
    kind = map['kind'];
  }

  late String deviceId;
  late String label;
  late MediaDeviceKind kind;
}
