import 'media_stream_track.dart';
import 'rtc_rtp_receiver.dart';
import 'rtc_rtp_transceiver.dart';

class RTCTrackEvent {
  RTCTrackEvent({
    this.receiver,
    required this.track,
    this.transceiver,
  });
  final RTCRtpReceiver? receiver;
  final MediaStreamTrack track;
  final RTCRtpTransceiver? transceiver;
}
