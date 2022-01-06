import '../interface/media_stream_track.dart';
import '../interface/rtc_rtp_receiver.dart';
import '../interface/rtc_rtp_transceiver.dart';
import '../interface/rtc_track_event.dart';

class RTCTrackEventWeb extends RTCTrackEvent {
  RTCTrackEventWeb(
      {RTCRtpReceiver? receiver,
      required MediaStreamTrack track,
      RTCRtpTransceiver? transceiver})
      : super(receiver: receiver, track: track, transceiver: transceiver);
}
