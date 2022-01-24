enum MediaDeviceKind {
  audioinput,
  audiooutput,
  videoinput,
  videooutput,
}

class MediaDeviceInfo {
  MediaDeviceInfo.fromMap(dynamic map) {
    deviceId = map['deviceId'];
    label = map['label'];
    kind = MediaDeviceKind.values[map['kind']];
  }

  late String deviceId;
  late String label;
  late MediaDeviceKind kind;
}
