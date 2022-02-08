import '../interface/media_stream.dart';
import '../interface/mediadevices.dart';
import '../interface/navigator.dart';
import 'mediadevices_impl.dart';

class NavigatorNative extends Navigator {
  MediaDeviceNative? _mediaDevices;

  @override
  Future<MediaStream> getDisplayMedia(Map<String, dynamic> mediaConstraints) {
    return mediaDevices.getDisplayMedia(mediaConstraints);
  }

  @override
  Future<List> getSources() {
    return mediaDevices.enumerateDevices();
  }

  @override
  Future<MediaStream> getUserMedia(Map<String, dynamic> mediaConstraints) {
    return mediaDevices.getUserMedia(mediaConstraints);
  }

  /// Returns the [MediaDevices], if it exists or creates if it does not.
  @override
  MediaDevices get mediaDevices {
    if (_mediaDevices == null) {
      _mediaDevices = MediaDeviceNative();
    }

    return _mediaDevices!;
  }
}
