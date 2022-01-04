import '../interface/media_stream_track.dart';
import '../interface/rtc_rtp_receiver.dart';
import '../interface/rtc_rtp_transceiver.dart';
import '../interface/rtc_track_event.dart';
import 'media_stream_track_impl.dart';
import 'rtc_rtp_receiver_impl.dart';
import 'rtc_rtp_transceiver_impl.dart';

class RTCTrackEventNative extends RTCTrackEvent {
  RTCTrackEventNative(RTCRtpReceiver receiver,
      MediaStreamTrack track, RTCRtpTransceiver transceiver)
      : super(
            receiver: receiver,
            track: track,
            transceiver: transceiver);

  factory RTCTrackEventNative.fromMap(
      Map<String, dynamic> map, String peerConnectionId) {
    return RTCTrackEventNative(
        RTCRtpReceiverNative.fromMap(map['receiver'],
            peerConnectionId: peerConnectionId),
        MediaStreamTrackNative.fromMap(map['track']),
        RTCRtpTransceiverNative.fromMap(map['transceiver'],
            peerConnectionId: peerConnectionId));
  }
}
