import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

import '/src/api/bridge/api/stats.dart' as ffi;
import '/src/api/bridge/api/stats/rtc_ice_candidate_stats.dart' as ffi;

import '/src/api/bridge/api/stats/rtc_inbound_rtp_stream_media_type.dart'
    as ffi;
import '/src/api/bridge/api/stats/rtc_media_source_stats_media_type.dart'
    as ffi;
import '/src/api/bridge/api/stats/rtc_outbound_rtp_stream_media_type.dart'
    as ffi;

part 'stats.g.dart';

/// Represents the [stats object] constructed by inspecting a specific
/// [monitored object].
///
/// [Full doc on W3C][1].
///
/// [stats object]: https://w3.org/TR/webrtc-stats#dfn-stats-object
/// [monitored object]: https://w3.org/TR/webrtc-stats#dfn-monitored-object
/// [1]: https://w3.org/TR/webrtc#rtcstats-dictionary
@JsonSerializable(createFactory: false, includeIfNull: false)
class RtcStats {
  RtcStats(this.id, this.timestamp, this.type, this.stat);

  /// Creates [RTCStats] basing on the [ffi.RtcStats] received from the native
  /// side.
  static RtcStats? fromFFI(ffi.RtcStats stats) {
    var stat = RtcStat.fromFFI(stats.kind);
    if (stat == null) {
      return null;
    } else {
      return RtcStats(stats.id, stats.timestampUs / 1000, stat.type(), stat);
    }
  }

  /// Creates [RTCStats] basing on the [Map] received from the native side.
  static RtcStats? fromMap(dynamic stats) {
    var stat = RtcStat.fromMap(stats);
    if (stat == null) {
      return null;
    } else {
      return RtcStats(
        stats['id'],
        (parseInt(stats['timestampUs']) ?? 0) / 1000,
        stat.type(),
        stat,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {..._$RtcStatsToJson(this), ...stat.toJson()};
  }

  /// Unique ID that is associated with the object that was inspected to produce
  /// these [RTCStats].
  ///
  /// [RTCStats]: https://w3.org/TR/webrtc#dom-rtcstats
  String id;

  /// Timestamp associated with this object.
  ///
  /// The time is relative to the UNIX epoch (Jan 1, 1970, UTC).
  ///
  /// For statistics that came from a remote source (e.g., from received RTCP
  /// packets), timestamp represents the time at which the information arrived
  /// at the local endpoint. The remote timestamp can be found in an additional
  /// field in an [RTCStats]-derived dictionary, if applicable.
  ///
  /// [RTCStats]: https://w3.org/TR/webrtc#dom-rtcstats
  double timestamp;

  /// Indicates the type of the object that the [RtcStats] object represents.
  RtcStatsType type;

  /// Actual stats of these [RtcStats].
  @JsonKey(includeToJson: false, includeFromJson: false) // manually flattened
  RtcStat stat;
}

/// Indicates the type of the object that the [RtcStats] object represents.
@JsonEnum(fieldRename: FieldRename.kebab)
enum RtcStatsType {
  /// Statistics for a codec that is currently used by [RTP stream]s being
  /// sent or received by [RTCPeerConnection] object.
  ///
  /// [RTCPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
  /// [RTP stream]: https://w3.org/TR/webrtc-stats#dfn-rtp-stream
  codec,

  /// Statistics for an inbound [RTP stream] that is currently received with
  /// this [RTCPeerConnection] object.
  ///
  /// RTX streams do not show up as separate [RtcInboundRtpStreamStats]
  /// objects but affect the [RtcReceivedRtpStreamStats.packetsReceived],
  /// [RtcInboundRtpStreamStats.bytesReceived],
  /// [RtcInboundRtpStreamStats.retransmittedPacketsReceived] and
  /// [RtcInboundRtpStreamStats.retransmittedBytesReceived] counters of
  /// the relevant [RtcInboundRtpStreamStats] objects.
  ///
  /// FEC streams do not show up as separate [RtcInboundRtpStreamStats]
  /// objects but affect the [RtcReceivedRtpStreamStats.packetsReceived],
  /// [RtcInboundRtpStreamStats.bytesReceived],
  /// [RtcInboundRtpStreamStats.fecPacketsReceived] and
  /// [RtcInboundRtpStreamStats.fecBytesReceived] counters of the
  /// relevant [RtcInboundRtpStreamStats] objects.
  ///
  /// [RTCPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
  /// [RTP stream]: https://w3.org/TR/webrtc-stats#dfn-rtp-stream
  inboundRtp,

  /// Statistics for an outbound [RTP stream] that is currently sent with this
  /// [RTCPeerConnection] object.
  ///
  /// When there are multiple [RTP stream]s connected to the same sender due
  /// to using simulcast, there will be one [RtcOutboundRtpStreamStats]
  /// per [RTP stream], with distinct values of the [SSRC] member. RTX streams
  /// do not show up as separate [RtcOutboundRtpStreamStats] objects but
  /// affect the [RtcSentRtpStreamStats.packetsSent],
  /// [RtcSentRtpStreamStats.bytesSent],
  /// [RtcOutboundRtpStreamStats.retransmittedPacketsSent] and
  /// [RtcOutboundRtpStreamStats.retransmittedBytesSent] counters of the
  /// relevant [RtcOutboundRtpStreamStats] objects.
  ///
  /// [RTCPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
  /// [RTP stream]: https://w3.org/TR/webrtc-stats#dfn-rtp-stream
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  outboundRtp,

  /// Statistics for the remote endpoint's inbound [RTP stream] corresponding
  /// to an outbound stream that is currently sent with this
  /// [RTCPeerConnection] object.
  ///
  /// It is measured at the remote endpoint and reported in an
  /// [RTCP Receiver Report][1] (RR) or [RTCP Extended Report][2] (XR).
  ///
  /// [RTCPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
  /// [RTP stream]: https://w3.org/TR/webrtc-stats#dfn-rtp-stream
  /// [1]: https://w3.org/TR/webrtc-stats#dfn-receiver-report
  /// [2]: https://w3.org/TR/webrtc-stats#dfn-extended-report
  remoteInboundRtp,

  /// Statistics for the remote endpoint's outbound [RTP stream] corresponding
  /// to an inbound stream that is currently received with this
  /// [RTCPeerConnection] object.
  ///
  /// It is measured at the remote endpoint and reported in an
  /// [RTCP Sender Report][1] (SR).
  ///
  /// [RTCPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
  /// [RTP stream]: https://w3.org/TR/webrtc-stats#dfn-rtp-stream
  /// [1]: https://w3.org/TR/webrtc-stats#dfn-sender-report
  remoteOutboundRtp,

  /// Statistics for the media produced by a [MediaStreamTrack][1] that is
  /// currently attached to an [RTCRtpSender].
  ///
  /// This reflects the media that is fed to the encoder; after
  /// [getUserMedia()][2] constraints have been applied (i.e. not the raw
  /// media produced by the camera).
  ///
  /// [RTCRtpSender]: https://w3.org/TR/webrtc#dom-rtcrtpsender
  /// [1]: https://w3.org/TR/mediacapture-streams#dom-mediastreamtrack
  /// [2]: https://tinyurl.com/w3-streams#dom-mediadevices-getusermedia
  mediaSource,

  /// Statistics related to audio playout.
  mediaPlayout,

  /// Statistics related to an [RTCPeerConnection] object.
  ///
  /// [RTCPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
  peerConnection,

  /// Statistics related to each [RTCDataChannel] ID.
  ///
  /// [RTCDataChannel]: https://w3.org/TR/webrtc#dom-rtcdatachannel
  dataChannel,

  /// Transport statistics related to an [RTCPeerConnection] object.
  ///
  /// It is accessed by the [RtcTransportStats].
  ///
  /// [RTCPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
  transport,

  /// [ICE] candidate pair statistics related to [RTCIceTransport] objects.
  ///
  /// A candidate pair that is not the current pair for a transport is
  /// [deleted][1] when the [RTCIceTransport] does an [ICE] restart, at the
  /// time the state changes to `new`. The candidate pair that is the current
  /// pair for a transport is deleted after an [ICE] restart when the
  /// [RTCIceTransport] switches to using a candidate pair generated from the
  /// new candidates; this time doesn't correspond to any other externally
  /// observable event.
  ///
  /// [ICE]: https://datatracker.ietf.org/doc/html/rfc8445
  /// [RTCIceTransport]: https://w3.org/TR/webrtc#dom-rtcicetransport
  /// [1]: https://w3.org/TR/webrtc-stats#dfn-deleted
  candidatePair,

  /// [ICE] local candidate statistics related to the [RTCIceTransport]
  /// objects.
  ///
  /// A local candidate is [deleted][1] when the [RTCIceTransport] does an
  /// [ICE] restart, and the candidate is no longer a member of any
  /// non-deleted candidate pair.
  ///
  /// [ICE]: https://datatracker.ietf.org/doc/html/rfc8445
  /// [RTCIceTransport]: https://w3.org/TR/webrtc#dom-rtcicetransport
  /// [1]: https://w3.org/TR/webrtc-stats#dfn-deleted
  localCandidate,

  /// [ICE] remote candidate statistics related to the [RTCIceTransport]
  /// objects.
  ///
  /// A remote candidate is [deleted][1] when the [RTCIceTransport] does an
  /// [ICE] restart, and the candidate is no longer a member of any
  /// non-deleted candidate pair.
  ///
  /// [ICE]: https://datatracker.ietf.org/doc/html/rfc8445
  /// [RTCIceTransport]: https://w3.org/TR/webrtc#dom-rtcicetransport
  /// [1]: https://w3.org/TR/webrtc-stats#dfn-deleted
  remoteCandidate,

  /// Information about a certificate used by the [RTCIceTransport].
  ///
  /// It is accessed by [RtcCertificateStats].
  ///
  /// [RTCIceTransport]: https://w3.org/TR/webrtc#dom-rtcicetransport
  certificate,
}

/// Each candidate pair in the check list has a foundation and a state.
/// The foundation is the combination of the foundations of the local and remote
/// candidates in the pair. The state is assigned once the check list for each
/// media stream has been computed. There are five potential values that the
/// state can have.
@JsonEnum(fieldRename: FieldRename.kebab)
enum RtcStatsIceCandidatePairState {
  /// Check for this pair hasn't been performed, and it can't yet be performed
  /// until some other check succeeds, allowing this pair to unfreeze and move
  /// into the [waiting] state.
  frozen,

  /// Check has not been performed for this pair, and can be performed as soon
  /// as it is the highest-priority Waiting pair on the check list.
  waiting,

  /// Check has been sent for this pair, but the transaction is in progress.
  inProgress,

  /// Check for this pair was already done and failed, either never producing
  /// any response or producing an unrecoverable failure response.
  failed,

  /// Check for this pair was already done and produced a successful result.
  succeeded,

  /// Other candidate pair was nominated.
  ///
  /// This state is **obsolete and not spec compliant**, however, it still
  /// may be emitted by some implementations.
  cancelled,
}

/// Variants of [ICE roles][1].
///
/// More info in the [RFC 5245].
///
/// [RFC 5245]: https://tools.ietf.org/html/rfc5245
/// [1]: https://w3.org/TR/webrtc#dom-icetransport-role
@JsonEnum(fieldRename: FieldRename.kebab)
enum RtcIceRole {
  /// Agent whose role as defined by [Section 3 in RFC 5245][1], has not yet
  /// been determined.
  ///
  /// [1]: https://tools.ietf.org/html/rfc5245#section-3
  unknown,

  /// Controlling agent as defined by [Section 3 in RFC 5245][1].
  ///
  /// [1]: https://tools.ietf.org/html/rfc5245#section-3
  controlling,

  /// Controlled agent as defined by [Section 3 in RFC 5245][1].
  ///
  /// [1]: https://tools.ietf.org/html/rfc5245#section-3
  controlled,
}

/// [RtcIceCandidateType] represents the type of the ICE candidate, as defined
/// in [Section 15.1 of RFC 5245][1].
///
/// [RTCIceCandidateType]: https://w3.org/TR/webrtc#rtcicecandidatetype-enum
/// [1]: https://tools.ietf.org/html/rfc5245#section-15.1
@JsonEnum(fieldRename: FieldRename.kebab)
enum RtcIceCandidateType {
  /// Host candidate, as defined in [Section 4.1.1.1 of RFC 5245][1].
  ///
  /// [1]: https://tools.ietf.org/html/rfc5245#section-4.1.1.1
  host,

  /// Server reflexive candidate, as defined in
  /// [Section 4.1.1.2 of RFC 5245][1].
  ///
  /// [1]: https://tools.ietf.org/html/rfc5245#section-4.1.1.2
  srflx,

  /// Peer reflexive candidate, as defined in [Section 4.1.1.2 of RFC 5245][1].
  ///
  /// [1]: https://tools.ietf.org/html/rfc5245#section-4.1.1.2
  prflx,

  /// Relay candidate, as defined in [Section 7.1.3.2.1 of RFC 5245][1].
  ///
  /// [1]: https://tools.ietf.org/html/rfc5245#section-7.1.3.2.1
  relay,
}

/// Transport protocols used in [WebRTC].
///
/// [WebRTC]: https://w3.org/TR/webrtc
@JsonEnum(fieldRename: FieldRename.kebab)
enum Protocol {
  /// [Transmission Control Protocol][1].
  ///
  /// [1]: https://en.wikipedia.org/wiki/Transmission_Control_Protocol
  tcp,

  /// [User Datagram Protocol][1].
  ///
  /// [1]: https://en.wikipedia.org/wiki/User_Datagram_Protocol
  udp,
}

/// All known types of [RtcStats].
///
/// [List of all RTCStats types on W3C][1].
///
/// [1]: https://w3.org/TR/webrtc-stats#rtctatstype-%2A
sealed class RtcStat {
  RtcStat();

  /// Creates an [RtcStat] basing on the [ffi.RtcStatsType] received from
  /// the native side.
  static RtcStat? fromFFI(ffi.RtcStatsType stats) {
    switch (stats) {
      case ffi.RtcStatsType_RtcMediaSourceStats s:
        switch (s.kind) {
          case ffi.RtcMediaSourceStatsMediaType_RtcVideoSourceStats k:
            return RtcVideoSourceStats.fromFFI(k, s.trackIdentifier);
          case ffi.RtcMediaSourceStatsMediaType_RtcAudioSourceStats k:
            return RtcAudioSourceStats.fromFFI(k, s.trackIdentifier);
        }
      case ffi.RtcStatsType_RtcIceCandidateStats s:
        return RtcIceCandidateStats.fromFFI(s);
      case ffi.RtcStatsType_RtcOutboundRtpStreamStats s:
        return RtcOutboundRtpStreamStats.fromFFI(s);
      case ffi.RtcStatsType_RtcInboundRtpStreamStats s:
        return RtcInboundRtpStreamStats.fromFFI(s);
      case ffi.RtcStatsType_RtcTransportStats s:
        return RtcTransportStats.fromFFI(s);
      case ffi.RtcStatsType_RtcRemoteInboundRtpStreamStats s:
        return RtcRemoteInboundRtpStreamStats.fromFFI(s);
      case ffi.RtcStatsType_RtcRemoteOutboundRtpStreamStats s:
        return RtcRemoteOutboundRtpStreamStats.fromFFI(s);
      case ffi.RtcStatsType_RtcIceCandidatePairStats s:
        return RtcIceCandidatePairStats.fromFFI(s);
      default:
        return null;
    }
  }

  /// Creates an [RtcStat] basing on the [Map] received from the native
  /// side.
  static RtcStat? fromMap(dynamic stats) {
    var type = _$RtcStatsTypeEnumMap.entries.firstWhereOrNull(
      (e) => e.value == stats['type'],
    );
    if (type == null) {
      return null;
    }

    switch (type.key) {
      case RtcStatsType.codec:
        return RtcCodecStats.fromMap(stats);
      case RtcStatsType.inboundRtp:
        return RtcInboundRtpStreamStats.fromMap(stats);
      case RtcStatsType.outboundRtp:
        return RtcOutboundRtpStreamStats.fromMap(stats);
      case RtcStatsType.remoteInboundRtp:
        return RtcRemoteInboundRtpStreamStats.fromMap(stats);
      case RtcStatsType.remoteOutboundRtp:
        return RtcRemoteOutboundRtpStreamStats.fromMap(stats);
      case RtcStatsType.mediaSource:
        if (stats['kind'] == 'audio') {
          return RtcAudioSourceStats.fromMap(stats);
        } else {
          return RtcVideoSourceStats.fromMap(stats);
        }
      case RtcStatsType.mediaPlayout:
        return RtcAudioPlayoutStats.fromMap(stats);
      case RtcStatsType.peerConnection:
        return RtcPeerConnectionStats.fromMap(stats);
      case RtcStatsType.dataChannel:
        return RtcDataChannelStats.fromMap(stats);
      case RtcStatsType.transport:
        return RtcTransportStats.fromMap(stats);
      case RtcStatsType.candidatePair:
        return RtcIceCandidatePairStats.fromMap(stats);
      case RtcStatsType.localCandidate:
        return RtcIceCandidateStats.fromMap(stats);
      case RtcStatsType.remoteCandidate:
        return RtcIceCandidateStats.fromMap(stats);
      case RtcStatsType.certificate:
        return RtcCertificateStats.fromMap(stats);
    }
  }

  Map<String, dynamic> toJson();

  /// Returns an [RtcStatsType] of this [RtcStat].
  RtcStatsType type();
}

/// Statistics that apply to any end of any [RTP stream].
///
/// [Full doc on W3C][spec].
///
/// [RTP stream]: https://w3.org/TR/webrtc-stats#dfn-rtp-stream
/// [spec]: https://w3.org/TR/webrtc-stats#dom-rtcrtpstreamstats
abstract class RtcRtpStreamStats extends RtcStat {
  RtcRtpStreamStats({this.ssrc, this.kind, this.transportId, this.codecId});

  /// Synchronization source ([SSRC]) identifier is an unsigned integer value
  /// per [RFC3550] used to identify the stream of [RTP] packets that this
  /// stats object is describing.
  ///
  /// For outbound and inbound local, [SSRC] describes the stats for the [RTP]
  /// stream that were sent and received, respectively by those endpoints.
  ///
  /// For the remote inbound and remote outbound, [SSRC] describes the stats
  /// for the [RTP] stream that were received by and sent to the remote
  /// endpoint.
  ///
  /// [RFC3550]: https://rfc-editor.org/rfc/rfc3550
  /// [RTP]: https://webrtcglossary.com/rtp
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  int? ssrc;

  /// Either `audio` or `video`.
  ///
  /// This MUST match the [kind` attribute][1] of the related
  /// [MediaStreamTrack][0].
  ///
  /// [0]: https://w3.org/TR/mediacapture-streams#dom-mediastreamtrack
  /// [1]: https://w3.org/TR/mediacapture-streams#dom-mediastreamtrack-kind
  String? kind;

  /// Unique identifier that is associated to the object that was inspected to
  /// produce the [RtcTransportStats] associated with this [RTP stream].
  ///
  /// [RTP stream]: https://w3.org/TR/webrtc-stats#dfn-rtp-stream
  String? transportId;

  /// Unique identifier that is associated to the object that was inspected to
  /// produce the [RtcCodecStats] associated with this [RTP stream].
  ///
  /// [RTP stream]: https://w3.org/TR/webrtc-stats#dfn-rtp-stream
  String? codecId;
}

/// Statistics measured at the receiving end of an [RTP stream], known either
/// because they're measured locally or transmitted via an
/// [RTCP Receiver Report] (RR) or [Extended Report] (XR) block.
///
/// [Full doc on W3C][spec].
///
/// [Extended Report]: https://w3.org/TR/webrtc-stats#dfn-extended-report
/// [RTP stream]: https://w3.org/TR/webrtc-stats#dfn-rtp-stream
/// [RTCP Receiver Report]: https://w3.org/TR/webrtc-stats#dfn-receiver-report
/// [spec]: https://w3.org/TR/webrtc-stats#dom-rtcreceivedrtpstreamstats
abstract class RtcReceivedRtpStreamStats extends RtcRtpStreamStats {
  RtcReceivedRtpStreamStats({
    super.ssrc,
    super.kind,
    super.transportId,
    super.codecId,
    this.packetsReceived,
    this.packetsReceivedWithEct1,
    this.packetsReceivedWithCe,
    this.packetsReportedAsLost,
    this.packetsReportedAsLostButRecovered,
    this.packetsLost,
    this.jitter,
  });

  /// Total number of [RTP] packets received for this [SSRC].
  ///
  /// This includes retransmissions.
  ///
  /// At the receiving endpoint, this is calculated as defined in
  /// [RFC3550 Section 6.4.1][1].
  ///
  /// At the sending endpoint the [packetsReceived][0] is estimated by
  /// subtracting the Cumulative Number of Packets Lost from the Extended
  /// Highest Sequence Number Received, both reported in the
  /// [RTCP Receiver Report][2], and then subtracting the initial
  /// Extended Sequence Number that was sent to this [SSRC] in an
  /// [RTCP Sender Report] and then adding one, to mirror what is discussed in
  /// [Appendix A.3 in RFC3550][3], but for the sender side.
  ///
  /// If no [RTCP Receiver Report][0] has been received yet, then is `0`.
  ///
  /// [RTCP Sender Report]: https://w3.org/TR/webrtc-stats#dfn-sender-report
  /// [RTP]: https://webrtcglossary.com/rtp
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  /// [0]: RtcReceivedRtpStreamStats.packetsReceived
  /// [1]: https://rfc-editor.org/rfc/rfc3550#section-6.4.1
  /// [2]: https://w3.org/TR/webrtc-stats#dfn-receiver-report
  /// [3]: https://rfc-editor.org/rfc/rfc3550#appendix-A.3
  int? packetsReceived;

  /// Total number of [RTP] packets received for this [SSRC] marked with the
  /// [ECT(1) marking][1].
  ///
  /// [RTP]: https://webrtcglossary.com/rtp
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  /// [1]: https://rfc-editor.org/rfc/rfc3168#section-3
  int? packetsReceivedWithEct1;

  /// Total number of [RTP] packets received for this [SSRC] marked with the
  /// [CE marking][1].
  ///
  /// [RTP]: https://webrtcglossary.com/rtp
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  /// [1]: https://rfc-editor.org/rfc/rfc3168#section-4
  int? packetsReceivedWithCe;

  /// Total number of [RTP] packets for which an [RFC8888 Section 3.1][1]
  /// report has been sent with a zero `R` bit.
  ///
  /// Only exists if support for the `ccfb` feedback mechanism has been
  /// negotiated.
  ///
  /// [RTP]: https://webrtcglossary.com/rtp
  /// [1]: https://rfc-editor.org/rfc/rfc8888#section-3.1
  int? packetsReportedAsLost;

  /// Total number of [RTP] packets for which an [RFC8888 Section 3.1][1]
  /// report has been sent with a zero `R` bit, but a later report for the
  /// same packet has the `R` bit set to `1`.
  ///
  /// Only exists if support for the `ccfb` feedback mechanism has been
  /// negotiated.
  ///
  /// [RTP]: https://webrtcglossary.com/rtp
  /// [1]: https://rfc-editor.org/rfc/rfc8888#section-3.1
  int? packetsReportedAsLostButRecovered;

  /// Total number of [RTP] packets lost for this [SSRC].
  ///
  /// Calculated as defined in [RFC3550 Section 6.4.1][1].
  ///
  /// Note that because of how this is estimated, it can be negative if more
  /// packets are received than sent.
  ///
  /// [RTP]: https://webrtcglossary.com/rtp
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  /// [1]: https://rfc-editor.org/rfc/rfc3550#section-6.4.1
  int? packetsLost;

  /// Packet jitter measured in seconds for this [SSRC].
  ///
  /// Calculated as defined in [Section 6.4.1 of RFC3550][1].
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  /// [1]: https://rfc-editor.org/rfc/rfc3550#section-6.4.1
  double? jitter;
}

/// Statistics measured at the sending end of an [RTP stream], known either
/// because they're measured locally or because they're received via [RTCP],
/// usually in an [RTCP Sender Report] (SR).
///
/// [Full doc on W3C][spec].
///
/// [RTP stream]: https://w3.org/TR/webrtc-stats#dfn-rtp-stream
/// [RTCP]: https://webrtcglossary.com/rtcp
/// [RTCP Sender Report]: https://w3.org/TR/webrtc-stats#dfn-sender-report
/// [spec]: https://w3.org/TR/webrtc-stats#dom-rtcsentrtpstreamstats
@JsonSerializable(createFactory: false, includeIfNull: false)
abstract class RtcSentRtpStreamStats extends RtcRtpStreamStats {
  RtcSentRtpStreamStats({
    super.ssrc,
    super.kind,
    super.transportId,
    super.codecId,
    this.packetsSent,
    this.bytesSent,
  });

  /// Total number of [RTP] packets sent for this [SSRC].
  ///
  /// This includes retransmissions.
  ///
  /// Calculated as defined in [RFC3550 Section 6.4.1][1].
  ///
  /// [RTP]: https://webrtcglossary.com/rtp
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  /// [1]: https://rfc-editor.org/rfc/rfc3550#section-6.4.1
  int? packetsSent;

  /// Total number of bytes sent for this [SSRC].
  ///
  /// This includes retransmissions.
  ///
  /// Calculated as defined in [RFC3550 Section 6.4.1][1].
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  /// [1]: https://rfc-editor.org/rfc/rfc3550#section-6.4.1
  int? bytesSent;
}

/// Statistics of a track that is currently attached to one or more senders.
///
/// It contains information about media sources such as frame rate and
/// resolution prior to encoding. This is the media passed from the
/// [MediaStreamTrack][1] to the [RTCRtpSender]s. This is in contrast to
/// [RtcOutboundRtpStreamStats] whose members describe metrics as measured
/// after the encoding step. For example, a track may be captured from a
/// high-resolution camera, its frames downscaled due to track constraints and
/// then further downscaled by the encoders due to CPU and network conditions.
/// This dictionary reflects the video frames or [audio sample]s passed out from
/// the track - after track constraints have been applied but before any
/// encoding or further downsampling occurs.
///
/// [Full doc on W3C][spec].
///
/// [audio sample]: https://w3.org/TR/webrtc-stats#dfn-audio-sample
/// [RTCRtpSender]: https://w3.org/TR/webrtc#dom-rtcrtpsender
/// [spec]: https://w3.org/TR/webrtc-stats#dom-rtcmediasourcestats
/// [1]: https://w3.org/TR/mediacapture-streams#mediastreamtrack
abstract class RtcMediaSourceStats extends RtcStat {
  RtcMediaSourceStats({this.trackIdentifier, this.kind});

  /// The value of the [MediaStreamTrack][1]'s `kind` attribute. This is
  /// either "audio" or "video". If it is "audio" then this stats object is of
  /// type [RtcAudioSourceStats]. If it is "video" then this stats object is
  /// of type [RtcVideoSourceStats].
  ///
  /// [1]: https://w3.org/TR/mediacapture-streams#mediastreamtrack
  String? kind;

  /// [id` attribute][2] value of the [MediaStreamTrack][1].
  ///
  /// [1]: https://w3.org/TR/mediacapture-streams#mediastreamtrack
  /// [2]: https://w3.org/TR/mediacapture-streams#dom-mediastreamtrack-id
  String? trackIdentifier;
}

/// [RtcStats] fields of audio [RtcMediaSourceStats].
@JsonSerializable(createFactory: false, includeIfNull: false)
class RtcAudioSourceStats extends RtcMediaSourceStats {
  RtcAudioSourceStats({
    super.trackIdentifier,
    super.kind,
    this.audioLevel,
    this.totalAudioEnergy,
    this.totalSamplesDuration,
    this.echoReturnLoss,
    this.echoReturnLossEnhancement,
  });

  /// Creates [RtcAudioSourceStats] basing on the
  /// [ffi.RtcMediaSourceStatsMediaType_RtcAudioSourceStats] received from the
  /// native side.
  static RtcAudioSourceStats fromFFI(
    ffi.RtcMediaSourceStatsMediaType_RtcAudioSourceStats stats,
    String? trackIdentifier,
  ) {
    return RtcAudioSourceStats(
      trackIdentifier: trackIdentifier,
      kind: 'audio',
      audioLevel: stats.audioLevel,
      totalAudioEnergy: stats.totalAudioEnergy,
      totalSamplesDuration: stats.totalSamplesDuration,
      echoReturnLoss: stats.echoReturnLoss,
      echoReturnLossEnhancement: stats.echoReturnLossEnhancement,
    );
  }

  /// Creates [RtcAudioSourceStats] basing on the [Map] received from the native
  /// side.
  static RtcAudioSourceStats fromMap(dynamic stats) {
    return RtcAudioSourceStats(
      trackIdentifier: stats['trackIdentifier'],
      kind: 'audio',
      audioLevel: stats['audioLevel'],
      totalAudioEnergy: stats['totalAudioEnergy'],
      totalSamplesDuration: stats['totalSamplesDuration'],
      echoReturnLoss: stats['echoReturnLoss'],
      echoReturnLossEnhancement: stats['echoReturnLossEnhancement'],
    );
  }

  @override
  Map<String, dynamic> toJson() => _$RtcAudioSourceStatsToJson(this);

  @override
  RtcStatsType type() => RtcStatsType.mediaSource;

  /// Audio level of the media source.
  ///
  /// For audio levels of remotely sourced tracks, see
  /// [RtcInboundRtpStreamStats] instead.
  ///
  /// The value is between `0..1` (linear), where `1.0` represents `0`
  /// dBov, `0` represents silence, and `0.5` represents approximately
  /// `6` dBSPL change in the sound pressure level from `0` dBov.
  ///
  /// The audio level is averaged over some small interval, using the
  /// algorithm described under
  /// [RtcAudioSourceStats.totalAudioEnergy]. The interval used
  /// is implementation-defined.
  double? audioLevel;

  /// Audio energy of the media source.
  ///
  /// For audio energy of remotely sourced tracks, see
  /// [RtcInboundRtpStreamStats] instead.
  double? totalAudioEnergy;

  /// Audio duration of the media source.
  ///
  /// For audio durations of remotely sourced tracks, see
  /// [RtcInboundRtpStreamStats] instead.
  ///
  /// Represents the total duration in seconds of all samples that have
  /// been produced by this source for the lifetime of this stats object.
  /// Can be used with [RtcAudioSourceStats.totalAudioEnergy]
  /// to compute an average audio level over different intervals.
  double? totalSamplesDuration;

  /// Only exists when the [MediaStreamTrack][0] is sourced from a
  /// microphone where echo cancellation is applied.
  ///
  /// Calculated in decibels, as defined in [ECHO] (2012) section 3.14.
  ///
  /// If multiple audio channels are used, the channel of the least audio
  /// energy is considered for any sample.
  ///
  /// [0]: https://w3.org/TR/mediacapture-streams#dom-mediastreamtrack
  /// [ECHO]: https://w3.org/TR/webrtc-stats#bib-echo
  double? echoReturnLoss;

  /// Only exists when the [MediaStreamTrack][0] is sourced from a
  /// microphone where echo cancellation is applied.
  ///
  /// Calculated in decibels, as defined in [ECHO] (2012) section 3.15.
  ///
  /// If multiple audio channels are used, the channel of the least audio
  /// energy is considered for any sample.
  ///
  /// [0]: https://w3.org/TR/mediacapture-streams#dom-mediastreamtrack
  /// [ECHO]: https://w3.org/TR/webrtc-stats#bib-echo
  double? echoReturnLossEnhancement;
}

/// [RtcStats] fields of video [RtcMediaSourceStats].
@JsonSerializable(createFactory: false, includeIfNull: false)
class RtcVideoSourceStats extends RtcMediaSourceStats {
  RtcVideoSourceStats({
    super.trackIdentifier,
    super.kind,
    this.width,
    this.height,
    this.frames,
    this.framesPerSecond,
  });

  /// Creates [RtcVideoSourceStats] basing on the
  /// [ffi.RtcMediaSourceStatsMediaType_RtcVideoSourceStats] received from the
  /// native side.
  static RtcVideoSourceStats fromFFI(
    ffi.RtcMediaSourceStatsMediaType_RtcVideoSourceStats stats,
    String? trackIdentifier,
  ) {
    return RtcVideoSourceStats(
      trackIdentifier: trackIdentifier,
      kind: 'video',
      width: stats.width,
      height: stats.height,
      frames: stats.frames,
      framesPerSecond: stats.framesPerSecond,
    );
  }

  /// Creates [RtcVideoSourceStats] basing on the [Map] received from the native
  /// side.
  static RtcVideoSourceStats fromMap(dynamic stats) {
    return RtcVideoSourceStats(
      trackIdentifier: stats['trackIdentifier'],
      kind: 'video',
      width: parseInt(stats['width']),
      height: parseInt(stats['height']),
      frames: parseInt(stats['frames']),
      framesPerSecond: stats['framesPerSecond'],
    );
  }

  @override
  Map<String, dynamic> toJson() => _$RtcVideoSourceStatsToJson(this);

  @override
  RtcStatsType type() => RtcStatsType.mediaSource;

  /// Width (in pixels) of the last frame originating from the source.
  ///
  /// Before a frame has been produced this attribute is missing.
  int? width;

  /// Height (in pixels) of the last frame originating from the source.
  ///
  /// Before a frame has been produced this attribute is missing.
  int? height;

  /// Total number of frames originating from the source.
  int? frames;

  /// Number of frames originating from the source, measured during the
  /// last second.
  ///
  /// For the first second of this object's lifetime this attribute is
  /// missing.
  double? framesPerSecond;
}

/// Statistics of one playout path.
///
/// If the same playout statistics object is referenced by multiple
/// [RtcInboundRtpStreamStats] this is an indication that audio mixing is
/// happening in which case sample counters in this statistics object refer to
/// the samples after mixing.
///
/// [Full doc on W3C][spec].
///
/// [spec]: https://w3.org/TR/webrtc-stats#dom-rtcaudioplayoutstats
@JsonSerializable(createFactory: false, includeIfNull: false)
class RtcAudioPlayoutStats extends RtcStat {
  RtcAudioPlayoutStats({
    this.kind,
    this.synthesizedSamplesDuration,
    this.synthesizedSamplesEvents,
    this.totalSamplesDuration,
    this.totalPlayoutDelay,
    this.totalSamplesCount,
  });

  static RtcAudioPlayoutStats fromMap(dynamic stats) {
    return RtcAudioPlayoutStats(
      kind: stats['kind'],
      synthesizedSamplesDuration: stats['synthesizedSamplesDuration'],
      synthesizedSamplesEvents: parseInt(stats['synthesizedSamplesEvents']),
      totalSamplesDuration: stats['totalSamplesDuration'],
      totalPlayoutDelay: stats['totalPlayoutDelay'],
      totalSamplesCount: parseInt(stats['totalSamplesCount']),
    );
  }

  @override
  Map<String, dynamic> toJson() => _$RtcAudioPlayoutStatsToJson(this);

  @override
  RtcStatsType type() => RtcStatsType.mediaPlayout;

  /// For audio playout, this has the value `audio`.
  ///
  /// This reflects the [kind` attribute][1] of the [MediaStreamTrack][0]
  /// being played out.
  ///
  /// [0]: https://w3.org/TR/mediacapture-streams#mediastreamtrack
  /// [1]: https://w3.org/TR/mediacapture-streams#dom-mediastreamtrack-kind
  String? kind;

  /// Total duration, in seconds, of synthesized audio samples that have been
  /// played out.
  ///
  /// If the playout path is unable to produce audio samples on time for
  /// device playout, samples are synthesized to be playout out instead.
  /// [synthesizedSamplesDuration][1] is measured in seconds and is
  /// incremented each time an audio sample is synthesized by this playout
  /// path.
  ///
  /// This metric can be used together with [totalSamplesDuration][2] to
  /// calculate the percentage of played out media being synthesized.
  ///
  /// Synthesization typically only happens if the pipeline is
  /// underperforming. Samples synthesized by the [RtcInboundRtpStreamStats]
  /// are not counted for here, but in
  /// [RtcInboundRtpStreamAudio.concealedSamples].
  ///
  /// [1]: RtcAudioPlayoutStats.synthesizedSamplesDuration
  /// [2]: RtcAudioPlayoutStats.totalSamplesDuration
  double? synthesizedSamplesDuration;

  /// Number of synthesized samples events.
  ///
  /// This counter increases every time a sample is synthesized after a
  /// non-synthesized sample. That is, multiple consecutive synthesized
  /// samples will increase the [synthesizedSamplesDuration][1] multiple
  /// times but is a single synthesization samples event.
  ///
  /// [1]: RtcAudioPlayoutStats.synthesizedSamplesDuration
  int? synthesizedSamplesEvents;

  /// Total duration, in seconds, of all audio samples that have been played
  /// out.
  ///
  /// Includes both synthesized and non-synthesized samples.
  double? totalSamplesDuration;

  /// Total estimated delay of the playout path for all audio samples.
  ///
  /// When audio samples are pulled by the playout device, this counter is
  /// incremented with the estimated delay of the playout path for that audio
  /// sample. The playout delay includes the delay from being emitted to the
  /// actual time of playout on the device.
  ///
  /// This metric can be used together with [totalSamplesCount][1] to
  /// calculate the average playout delay per sample.
  ///
  /// [1]: RtcAudioPlayoutStats.totalSamplesCount
  double? totalPlayoutDelay;

  /// Total number of samples emitted for playout.
  ///
  /// When audio samples are pulled by the playout device, this counter is
  /// incremented with the number of samples emitted for playout.
  int? totalSamplesCount;
}

/// Statistics for an [RTCPeerConnection] object.
///
/// [Full doc on W3C][spec].
///
/// [RTCPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
/// [spec]: https://w3.org/TR/webrtc-stats#dom-rtcpeerconnectionstats
@JsonSerializable(createFactory: false, includeIfNull: false)
class RtcPeerConnectionStats extends RtcStat {
  RtcPeerConnectionStats({this.dataChannelsOpened, this.dataChannelsClosed});

  static RtcPeerConnectionStats fromMap(dynamic stats) {
    return RtcPeerConnectionStats(
      dataChannelsOpened: parseInt(stats['dataChannelsOpened']),
      dataChannelsClosed: parseInt(stats['dataChannelsClosed']),
    );
  }

  @override
  Map<String, dynamic> toJson() => _$RtcPeerConnectionStatsToJson(this);

  @override
  RtcStatsType type() => RtcStatsType.peerConnection;

  /// Number of unique [RTCDataChannel]s that have entered the
  /// [open` state][1] during their lifetime.
  ///
  /// [RTCDataChannel]: https://w3.org/TR/webrtc#dom-rtcdatachannel
  /// [1]: https://w3.org/TR/webrtc#dom-rtcdatachannelstate-open
  int? dataChannelsOpened;

  /// Number of unique [RTCDataChannel]s that have left the [open` state][1]
  /// during their lifetime (due to being closed by either end or the
  /// underlying transport being closed).
  ///
  /// [RTCDataChannel]s that transition from [connecting][2] to
  /// [closing][3] or [closed][4] state without ever being [open][1] are
  /// not counted in this number.
  ///
  /// [RTCDataChannel]: https://w3.org/TR/webrtc#dom-rtcdatachannel
  /// [1]: https://w3.org/TR/webrtc#dom-rtcdatachannelstate-open
  /// [2]: https://w3.org/TR/webrtc#dom-rtcdatachannelstate-connecting
  /// [3]: https://w3.org/TR/webrtc#dom-rtcdatachannelstate-closing
  /// [4]: https://w3.org/TR/webrtc#dom-rtcdatachannelstate-closed
  int? dataChannelsClosed;
}

/// Statistics related to each [RTCDataChannel] ID.
///
/// [Full doc on W3C][spec].
///
/// [RTCDataChannel]: https://w3.org/TR/webrtc#dom-rtcdatachannel
/// [spec]: https://w3.org/TR/webrtc-stats#dom-rtcdatachannelstats
@JsonSerializable(createFactory: false, includeIfNull: false)
class RtcDataChannelStats extends RtcStat {
  RtcDataChannelStats({
    this.label,
    this.protocol,
    this.dataChannelIdentifier,
    this.state,
    this.messagesSent,
    this.bytesSent,
    this.messagesReceived,
    this.bytesReceived,
  });

  static RtcDataChannelStats fromMap(dynamic stats) {
    return RtcDataChannelStats(
      label: stats['label'],
      protocol: stats['protocol'],
      dataChannelIdentifier: parseInt(stats['dataChannelIdentifier']),
      state: _$RtcDataChannelStateEnumMap.entries
          .firstWhereOrNull((e) => e.value == stats['state'])
          ?.key,
      messagesSent: parseInt(stats['messagesSent']),
      bytesSent: parseInt(stats['bytesSent']),
      messagesReceived: parseInt(stats['messagesReceived']),
      bytesReceived: parseInt(stats['bytesReceived']),
    );
  }

  @override
  Map<String, dynamic> toJson() => _$RtcDataChannelStatsToJson(this);

  @override
  RtcStatsType type() => RtcStatsType.dataChannel;

  /// [label] value of the [RTCDataChannel] object.
  ///
  /// [RTCDataChannel]: https://w3.org/TR/webrtc#dom-rtcdatachannel
  /// [label]: https://w3.org/TR/webrtc#dom-datachannel-label
  String? label;

  /// [protocol][1] value of the [RTCDataChannel] object.
  ///
  /// [RTCDataChannel]: https://w3.org/TR/webrtc#dom-rtcdatachannel
  /// [1]: https://w3.org/TR/webrtc#dom-datachannel-protocol
  String? protocol;

  /// [id][1] attribute of the [RTCDataChannel] object.
  ///
  /// [RTCDataChannel]: https://w3.org/TR/webrtc#dom-rtcdatachannel
  /// [1]: https://w3.org/TR/webrtc#dom-rtcdatachannel-id
  int? dataChannelIdentifier;

  /// [readyState][1] value of the [RTCDataChannel] object.
  ///
  /// [RTCDataChannel]: https://w3.org/TR/webrtc#dom-rtcdatachannel
  /// [1]: https://w3.org/TR/webrtc#dom-datachannel-readystate
  RtcDataChannelState? state;

  /// Total number of API `message` events sent.
  int? messagesSent;

  /// Total number of payload bytes sent on the [RTCDataChannel].
  ///
  /// [RTCDataChannel]: https://w3.org/TR/webrtc#dom-rtcdatachannel
  int? bytesSent;

  /// Total number of API `message` events received.
  int? messagesReceived;

  /// Total number of bytes received on the [RTCDataChannel].
  ///
  /// [RTCDataChannel]: https://w3.org/TR/webrtc#dom-rtcdatachannel
  int? bytesReceived;
}

@JsonEnum(fieldRename: FieldRename.kebab)
enum RtcDataChannelState {
  /// User agent is attempting to establish the underlying data transport.
  ///
  /// This is the initial state of an [RTCDataChannel] object, whether created
  /// with [createDataChannel()][1], or dispatched as a part of an
  /// [RTCDataChannelEvent].
  ///
  /// [RTCDataChannel]: https://w3.org/TR/webrtc#dom-rtcdatachannel
  /// [RTCDataChannelEvent]: https://w3.org/TR/webrtc#dom-rtcdatachannelevent
  /// [1]: https://w3.org/TR/webrtc#dom-peerconnection-createdatachannel
  connecting,

  /// [Underlying data transport][1] is established and communication is
  /// possible.
  ///
  /// [1]: https://w3.org/TR/webrtc#dfn-data-transport
  open,

  /// [Procedure][2] to close down the [underlying data transport][1] has
  /// started.
  ///
  /// [1]: https://w3.org/TR/webrtc#dfn-data-transport
  /// [2]: https://w3.org/TR/webrtc#data-transport-closing-procedure
  closing,

  /// [Underlying data transport][1] has been [closed][2] or could not be
  /// established.
  ///
  /// [1]: https://w3.org/TR/webrtc#dfn-data-transport
  /// [2]: https://w3.org/TR/webrtc#dom-rtcdatachannelstate-closed
  closed,
}

/// Properties of a `candidate` in [Section 15.1 of RFC 5245][1].
/// It corresponds to a [RTCIceTransport] object.
///
/// [Full doc on W3C][2].
///
/// [RTCIceTransport]: https://w3.org/TR/webrtc#dom-rtcicetransport
/// [1]: https://tools.ietf.org/html/rfc5245#section-15.1
/// [2]: https://w3.org/TR/webrtc-stats#icecandidate-dict%2A
abstract class RtcIceCandidateStats extends RtcStat {
  RtcIceCandidateStats({
    this.transportId,
    this.address,
    this.port,
    this.protocol,
    this.candidateType,
    this.priority,
    this.url,
    this.relayProtocol,
    this.foundation,
    this.relatedAddress,
    this.relatedPort,
    this.usernameFragment,
    this.tcpType,
    this.networkType,
  });

  /// Creates [RtcIceCandidateStats] basing on the
  /// [ffi.RtcStatsType_RtcIceCandidateStats] received from the native side.
  static RtcIceCandidateStats fromFFI(
    ffi.RtcStatsType_RtcIceCandidateStats stats,
  ) {
    IceServerTransportProtocol? relayProtocol;
    if (stats.field0.field0.relayProtocol != null) {
      relayProtocol = IceServerTransportProtocol
          .values[stats.field0.field0.relayProtocol!.index];
    }
    if (stats.field0 is ffi.RtcIceCandidateStats_Local) {
      var local = stats.field0 as ffi.RtcIceCandidateStats_Local;
      return RtcLocalIceCandidateStats(
        transportId: local.field0.transportId,
        address: local.field0.address,
        port: local.field0.port,
        protocol: local.field0.protocol.name,
        candidateType:
            RtcIceCandidateType.values[local.field0.candidateType.index],
        priority: local.field0.priority,
        url: local.field0.url,
        relayProtocol: relayProtocol,
      );
    } else {
      var remote = stats.field0 as ffi.RtcIceCandidateStats_Remote;
      return RtcRemoteIceCandidateStats(
        transportId: remote.field0.transportId,
        address: remote.field0.address,
        port: remote.field0.port,
        protocol: remote.field0.protocol.name,
        candidateType:
            RtcIceCandidateType.values[remote.field0.candidateType.index],
        priority: remote.field0.priority,
        url: remote.field0.url,
        relayProtocol: relayProtocol,
      );
    }
  }

  /// Creates [RtcIceCandidateStats] basing on the [Map] received from the
  /// native side.
  static RtcIceCandidateStats fromMap(dynamic stats) {
    var candidateType = _$RtcIceCandidateTypeEnumMap.entries
        .firstWhereOrNull((e) => e.value == stats['candidateType'])
        ?.key;
    var relayProtocol = _$IceServerTransportProtocolEnumMap.entries
        .firstWhereOrNull((e) => e.value == stats['relayProtocol'])
        ?.key;
    var tcpType = _$RtcIceTcpCandidateTypeEnumMap.entries
        .firstWhereOrNull((e) => e.value == stats['tcpType'])
        ?.key;

    if (stats['isRemote']) {
      return RtcRemoteIceCandidateStats(
        transportId: stats['transportId'],
        address: stats['address'],
        port: parseInt(stats['port']),
        protocol: stats['protocol'],
        candidateType: candidateType,
        priority: parseInt(stats['priority']),
        url: stats['url'],
        relayProtocol: relayProtocol,
        foundation: stats['foundation'],
        relatedAddress: stats['relatedAddress'],
        relatedPort: parseInt(stats['relatedPort']),
        usernameFragment: stats['usernameFragment'],
        tcpType: tcpType,
        networkType: stats['networkType'],
      );
    } else {
      return RtcLocalIceCandidateStats(
        transportId: stats['transportId'],
        address: stats['address'],
        port: parseInt(stats['port']),
        protocol: stats['protocol'],
        candidateType: candidateType,
        priority: parseInt(stats['priority']),
        url: stats['url'],
        relayProtocol: relayProtocol,
        foundation: stats['foundation'],
        relatedAddress: stats['relatedAddress'],
        relatedPort: parseInt(stats['relatedPort']),
        usernameFragment: stats['usernameFragment'],
        tcpType: tcpType,
        networkType: stats['networkType'],
      );
    }
  }

  /// Unique ID that is associated to the object that was inspected to produce
  /// the [RtcTransportStats] associated with the candidate.
  String? transportId;

  /// Address of the candidate, allowing for IPv4 addresses, IPv6 addresses,
  /// and fully qualified domain names (FQDNs).
  ///
  /// See [RFC5245 Section 15.1][1] for details.
  ///
  /// [1]: https://rfc-editor.org/rfc/rfc5245#section-15.1
  String? address;

  /// Port number of the candidate.
  int? port;

  /// Valid values for transport is one of `udp` and `tcp`.
  ///
  /// Based on the `transport` defined in [RFC5245 Section 15.1][1].
  ///
  /// [1]: https://rfc-editor.org/rfc/rfc5245#section-15.1
  String? protocol;

  /// Type of the [ICE] candidate.
  ///
  /// [ICE]: https://datatracker.ietf.org/doc/html/rfc8445
  RtcIceCandidateType? candidateType;

  /// Priority calculated as defined in [RFC5245 Section 15.1][1].
  ///
  /// [1]: https://rfc-editor.org/rfc/rfc5245#section-15.1
  int? priority;

  /// For local candidates of type [RtcIceCandidateType.srflx] or type
  /// [RtcIceCandidateType.relay] this is the URL of the [ICE] server
  /// from which the candidate was obtained and defined in [WebRTC].
  ///
  /// For remote candidates, this property MUST NOT be present.
  ///
  /// [ICE]: https://datatracker.ietf.org/doc/html/rfc8445
  /// [WebRTC]: https://w3.org/TR/webrtc
  String? url;

  /// Protocol used by the endpoint to communicate with the [TURN] server.
  ///
  /// This is only present for local relay candidates and defined in [WebRTC].
  ///
  /// For remote candidates, this property MUST NOT be present.
  ///
  /// [TURN]: https://webrtcglossary.com/turn
  /// [WebRTC]: https://w3.org/TR/webrtc
  IceServerTransportProtocol? relayProtocol;

  /// [ICE] foundation as defined in [RFC5245 Section 15.1][1].
  ///
  /// [ICE]: https://datatracker.ietf.org/doc/html/rfc8445
  /// [1]: https://rfc-editor.org/rfc/rfc5245#section-15.1
  String? foundation;

  /// [ICE] `rel-addr` as defined in [RFC5245 Section 15.1][1].
  ///
  /// Only set for [RtcIceCandidateType.srflx],
  /// [RtcIceCandidateType.prflx] and
  /// [RtcIceCandidateType.relay] candidates.
  ///
  /// [ICE]: https://datatracker.ietf.org/doc/html/rfc8445
  /// [1]: https://rfc-editor.org/rfc/rfc5245#section-15.1
  String? relatedAddress;

  /// [ICE] `rel-port` as defined in [RFC5245 Section 15.1][1].
  ///
  /// Only set for [RtcIceCandidateType.srflx],
  /// [RtcIceCandidateType.prflx] and
  /// [RtcIceCandidateType.relay] candidates.
  ///
  /// [ICE]: https://datatracker.ietf.org/doc/html/rfc8445
  /// [1]: https://rfc-editor.org/rfc/rfc5245#section-15.1
  int? relatedPort;

  /// [ICE] username fragment as defined in [RFC5245 section 7.1.2.3][1].
  ///
  /// For [RtcIceCandidateType.prflx] remote candidates this is not
  /// set unless the [ICE] username fragment has been previously signaled.
  ///
  /// [ICE]: https://datatracker.ietf.org/doc/html/rfc8445
  /// [1]: https://rfc-editor.org/rfc/rfc5245#section-7.1.2.3
  String? usernameFragment;

  /// [ICE] candidate TCP type, as defined іn [RtcIceTcpCandidateType] and
  /// used in [RTCIceCandidate].
  ///
  /// [ICE]: https://datatracker.ietf.org/doc/html/rfc8445
  /// [RTCIceCandidate]: https://w3.org/TR/webrtc#dom-rtcicecandidate
  RtcIceTcpCandidateType? tcpType;

  /// Type of network used by a local [ICE] candidate.
  ///
  /// **Not spec compliant**, but provided by most user agents.
  ///
  /// [ICE]: https://datatracker.ietf.org/doc/html/rfc8445
  String? networkType;
}

/// Possible types of the transport protocol used between the client and the
/// server, as defined in [RFC8656 Section 3.1][1].
///
/// [1]: https://rfc-editor.org/rfc/rfc8656#section-3.1
@JsonEnum(fieldRename: FieldRename.kebab)
enum IceServerTransportProtocol {
  /// UDP as transport to the server.
  udp,

  /// TCP as transport to the server.
  tcp,

  /// TLS as transport to the server.
  tls,
}

/// Possible types of an [ICE] TCP candidate, as defined in [RFC6544].
///
/// [ICE]: https://datatracker.ietf.org/doc/html/rfc8445
/// [RFC6544]: https://rfc-editor.org/rfc/rfc6544
@JsonEnum(fieldRename: FieldRename.kebab)
enum RtcIceTcpCandidateType {
  /// Candidate for which the transport will attempt to open an outbound
  /// connection but will not receive incoming connection requests.
  active,

  /// Candidate for which the transport will receive incoming connection
  /// attempts, but not attempt a connection.
  passive,

  /// Candidate for which the transport will attempt to open a connection
  /// simultaneously with its peer.
  so,
}

/// Local [RtcIceCandidateStats].
@JsonSerializable(createFactory: false, includeIfNull: false)
class RtcLocalIceCandidateStats extends RtcIceCandidateStats {
  RtcLocalIceCandidateStats({
    super.transportId,
    super.address,
    super.port,
    super.protocol,
    super.candidateType,
    super.priority,
    super.url,
    super.relayProtocol,
    super.foundation,
    super.relatedAddress,
    super.relatedPort,
    super.usernameFragment,
    super.tcpType,
    super.networkType,
  });

  @override
  RtcStatsType type() => RtcStatsType.localCandidate;

  @override
  Map<String, dynamic> toJson() => _$RtcLocalIceCandidateStatsToJson(this);
}

/// Remote [RtcIceCandidateStats].
@JsonSerializable(createFactory: false, includeIfNull: false)
class RtcRemoteIceCandidateStats extends RtcIceCandidateStats {
  RtcRemoteIceCandidateStats({
    super.transportId,
    super.address,
    super.port,
    super.protocol,
    super.candidateType,
    super.priority,
    super.url,
    super.relayProtocol,
    super.foundation,
    super.relatedAddress,
    super.relatedPort,
    super.usernameFragment,
    super.tcpType,
    super.networkType,
  });

  @override
  RtcStatsType type() => RtcStatsType.remoteCandidate;

  @override
  Map<String, dynamic> toJson() => _$RtcRemoteIceCandidateStatsToJson(this);
}

/// Information about a certificate used by an [RTCIceTransport].
///
/// [Full doc on W3C][spec].
///
/// [RTCIceTransport]: https://w3.org/TR/webrtc#dom-rtcicetransport
/// [spec]: https://w3.org/TR/webrtc-stats#dom-rtccertificatestats
@JsonSerializable(createFactory: false, includeIfNull: false)
class RtcCertificateStats extends RtcStat {
  RtcCertificateStats({
    this.fingerprint,
    this.fingerprintAlgorithm,
    this.base64Certificate,
    this.issuerCertificateId,
  });

  static RtcCertificateStats fromMap(dynamic stats) {
    return RtcCertificateStats(
      fingerprint: stats['fingerprint'],
      fingerprintAlgorithm: stats['fingerprintAlgorithm'],
      base64Certificate: stats['base64Certificate'],
      issuerCertificateId: stats['issuerCertificateId'],
    );
  }

  @override
  Map<String, dynamic> toJson() => _$RtcCertificateStatsToJson(this);

  @override
  RtcStatsType type() => RtcStatsType.certificate;

  /// Fingerprint of the certificate.
  ///
  /// Only use the fingerprint value as defined in
  /// [Section 5 of RFC4572][1].
  ///
  /// [1]: https://tools.ietf.org/html/rfc4572#section-5
  String? fingerprint;

  /// Hash function used to compute the certificate fingerprint.
  ///
  /// For instance, `sha-256`.
  String? fingerprintAlgorithm;

  /// The DER-encoded [Base64] representation of the certificate.
  ///
  /// [Base64]: https://en.wikipedia.org/wiki/Base64
  /// [DER]: https://en.wikipedia.org/wiki/X.690#DER_encoding
  String? base64Certificate;

  /// Identifier referring to the stats object that contains the next
  /// certificate in the certificate chain.
  ///
  /// If the current certificate is at the end of the chain (i.e. a
  /// self-signed certificate), this will not be set.
  String? issuerCertificateId;
}

sealed class RtcOutboundRtpStreamStatsMediaType {}

/// Audio [RtcOutboundRtpStreamStatsMediaType].
@JsonSerializable(createFactory: false, includeIfNull: false)
class RtcOutboundRtpStreamAudio extends RtcOutboundRtpStreamStatsMediaType {
  RtcOutboundRtpStreamAudio({this.totalSamplesSent, this.voiceActivityFlag});

  Map<String, dynamic> toJson() => _$RtcOutboundRtpStreamAudioToJson(this);

  /// Total number of samples that have been sent over the [RTP stream].
  ///
  /// [RTP stream]: https://w3.org/TR/webrtc-stats#dfn-rtp-stream
  int? totalSamplesSent;

  /// Indicator whether the last [RTP] packet sent contained voice
  /// activity or not, based on the presence of the `V` bit in the
  /// extension header.
  ///
  /// [RTP]: https://webrtcglossary.com/rtp
  bool? voiceActivityFlag;
}

/// Video [RtcOutboundRtpStreamStatsMediaType].
@JsonSerializable(createFactory: false, includeIfNull: false)
class RtcOutboundRtpStreamVideo extends RtcOutboundRtpStreamStatsMediaType {
  RtcOutboundRtpStreamVideo({
    this.rid,
    this.encodingIndex,
    this.totalEncodedBytesTarget,
    this.frameWidth,
    this.frameHeight,
    this.framesPerSecond,
    this.framesSent,
    this.hugeFramesSent,
    this.framesEncoded,
    this.keyFramesEncoded,
    this.qpSum,
    this.psnrSum,
    this.psnrMeasurements,
    this.totalEncodeTime,
    this.firCount,
    this.pliCount,
    this.encoderImplementation,
    this.powerEfficientEncoder,
    this.qualityLimitationDurations,
    this.qualityLimitationReason,
    this.qualityLimitationResolutionChanges,
    this.scalabilityMode,
  });

  Map<String, dynamic> toJson() => _$RtcOutboundRtpStreamVideoToJson(this);

  /// Only exists if a [rid] has been set for the [RTP stream].
  ///
  /// If [rid] is set, this value will be present regardless if the
  /// [RID RTP header extension][1] has been negotiated.
  ///
  /// [rid]: https://w3.org/TR/webrtc#dom-rtcrtpcodingparameters-rid
  /// [RTP stream]: https://w3.org/TR/webrtc-stats#dfn-rtp-stream
  /// [1]: https://www.rfc-editor.org/rfc/rfc9429#section-5.2.1-13.11
  String? rid;

  /// Index of the encoding that represents the [RTP stream] in the RTP
  /// sender's list of [encodings][0].
  ///
  /// [0]: https://w3.org/TR/webrtc#dom-rtcrtpsendparameters-encodings
  int? encodingIndex;

  /// Value, increased by the target frame size in bytes every time a frame
  /// has been encoded.
  ///
  /// The actual frame size may be bigger or smaller than this number.
  ///
  /// This value goes up every time the
  /// [RtcOutboundRtpStreamVideo.framesEncoded] goes up.
  int? totalEncodedBytesTarget;

  /// Width of the last encoded frame.
  ///
  /// The resolution of the encoded frame may be lower than the media source
  /// (see [RTCVideoSourceStats.width][1]).
  ///
  /// Before the first frame is encoded this attribute is missing.
  ///
  /// [1]: https://w3.org/TR/webrtc-stats#dom-rtcvideosourcestats-width
  int? frameWidth;

  /// Height of the last encoded frame.
  ///
  /// The resolution of the encoded frame may be lower than the media source
  /// (see [RTCVideoSourceStats.height][1]).
  ///
  /// Before the first frame is encoded this attribute is missing.
  ///
  /// [1]: https://w3.org/TR/webrtc-stats#dom-rtcvideosourcestats-height
  int? frameHeight;

  /// Number of encoded frames during the last second.
  ///
  /// This may be lower than the media source frame rate (see
  /// [RTCVideoSourceStats.framesPerSecond][1]).
  ///
  /// [1]: https://tinyurl.com/rrmkrfk
  double? framesPerSecond;

  /// Total number of frames sent on the [RTP stream].
  ///
  /// [RTP stream]: https://w3.org/TR/webrtc-stats#dfn-rtp-stream
  int? framesSent;

  /// Total number of huge frames sent by the [RTP stream].
  ///
  /// Huge frames, by definition, are frames that have an encoded size at
  /// least 2.5 times the average size of the frames. The average size of the
  /// frames is defined as the target bitrate per second divided by the target
  /// FPS at the time the frame was encoded. These are usually complex to
  /// encode frames with a lot of changes in the picture. This can be used to
  /// estimate slide changes in the streamed presentation.
  ///
  /// The multiplier of 2.5 is chosen from analyzing encoded frame sizes for a
  /// sample presentation using [WebRTC] standalone implementation. 2.5 is a
  /// reasonably large multiplier which still caused all slide change events
  /// to be identified as a huge frames. It, however, produced 1.4% of false
  /// positive slide change detections which is deemed reasonable.
  ///
  /// [RTP stream]: https://w3.org/TR/webrtc-stats#dfn-rtp-stream
  /// [WebRTC]: https://w3.org/TR/webrtc
  int? hugeFramesSent;

  /// Total number of frames successfully encoded for the media [RTP stream].
  ///
  /// [RTP stream]: https://w3.org/TR/webrtc-stats#dfn-rtp-stream
  int? framesEncoded;

  /// Total number of key frames, such as key frames in VP8 [RFC6386] or
  /// IDR-frames in H.264 [RFC6184], successfully encoded for the media
  /// [RTP stream].
  ///
  /// This is a subset of
  /// [RtcOutboundRtpStreamVideo.framesEncoded].
  /// [RtcOutboundRtpStreamVideo.framesEncoded] -
  /// [RtcOutboundRtpStreamVideo.keyFramesEncoded] gives the number of
  /// delta frames encoded.
  ///
  /// [RFC6386]: https://rfc-editor.org/rfc/rfc6386
  /// [RFC6184]: https://rfc-editor.org/rfc/rfc6184
  /// [RTP stream]: https://w3.org/TR/webrtc-stats#dfn-rtp-stream
  int? keyFramesEncoded;

  /// Sum of the QP values of frames encoded by the sender.
  ///
  /// The count of frames is in [RtcOutboundRtpStreamVideo.framesEncoded].
  ///
  /// The definition of QP value depends on the codec; for VP8, the QP value
  /// is the value carried in the frame header as the syntax element
  /// `y_ac_qi`, and defined in [RFC6386] section 19.2. Its range is `0..127`.
  ///
  /// Note, that the QP value is only an indication of quantizer values used;
  /// many formats have ways to vary the quantizer value within the frame.
  ///
  /// [RFC6386]: https://rfc-editor.org/rfc/rfc6386
  int? qpSum;

  /// Cumulative sum of the PSNR values of frames encoded by the sender.
  ///
  /// The record includes values for the `y`, `u` and `v` components.
  ///
  /// The count of measurements is in
  /// [RtcOutboundRtpStreamVideo.psnrMeasurements].
  Map<String, double>? psnrSum;

  /// Number of times PSNR was measured.
  ///
  /// The components of [RtcOutboundRtpStreamVideo.psnrSum] are aggregated with
  /// this measurement.
  int? psnrMeasurements;

  /// Total number of seconds that has been spent encoding the
  /// [RtcOutboundRtpStreamVideo.framesEncoded] frames of the
  /// [RTP stream].
  ///
  /// The average encode time can be calculated by dividing this value with
  /// [RtcOutboundRtpStreamVideo.framesEncoded]. The time it takes to
  /// encode one frame is the time passed between feeding the encoder a frame
  /// and the encoder returning encoded data for that frame. This doesn't
  /// include any additional time it may take to packetize the resulting data.
  ///
  /// [RTP stream]: https://w3.org/TR/webrtc-stats#dfn-rtp-stream
  double? totalEncodeTime;

  /// Total number of Full Intra Request (FIR) packets, as defined in
  /// [RFC5104] section 4.3.1, received by the sender.
  ///
  /// Doesn't count the RTCP FIR indicated in [RFC2032] which was deprecated
  /// by [RFC4587].
  ///
  /// [RFC5104]: https://rfc-editor.org/rfc/rfc5104
  /// [RFC2032]: https://rfc-editor.org/rfc/rfc2032
  /// [RFC4587]: https://rfc-editor.org/rfc/rfc4587
  int? firCount;

  /// Total number of Picture Loss Indication (PLI) packets, as defined in
  /// [RFC4585] section 6.3.1, received by the sender.
  ///
  /// [RFC4585]: https://rfc-editor.org/rfc/rfc4585
  int? pliCount;

  /// Identification of the used encoder implementation.
  ///
  /// This is useful for diagnosing interoperability issues.
  String? encoderImplementation;

  /// Indicator whether the encoder currently used is considered power
  /// efficient by the user agent.
  ///
  /// This SHOULD reflect if the configuration results in hardware
  /// acceleration, but the user agent MAY take other information into account
  /// when deciding if the configuration is considered power efficient.
  bool? powerEfficientEncoder;

  /// Current reason for limiting the resolution and/or framerate.
  ///
  /// The implementation reports the most limiting factor. If the
  /// implementation is not able to determine the most limiting factor because
  /// multiple may exist, the reasons MUST be reported in the following order
  /// of priority: `bandwidth`, `cpu`, `other`.
  RtcQualityLimitationReason? qualityLimitationReason;

  /// Record of the total time, in seconds, that the [RTP stream] has spent in
  /// each quality limitation state.
  ///
  /// The record includes a mapping for all [RtcQualityLimitationReason]
  /// types, including [RtcQualityLimitationReason.none].
  ///
  /// The sum of all entries minus [RtcQualityLimitationReason.none]
  /// gives the total time that the stream has been limited.
  ///
  /// [RTP stream]: https://w3.org/TR/webrtc-stats#dfn-rtp-stream
  Map<String, double>? qualityLimitationDurations;

  /// Number of times that the resolution has changed because of the quality
  /// limit (`qualityLimitationReason` has a value other than
  /// [RtcQualityLimitationReason.none]).
  ///
  /// The counter is initially zero and increases when the resolution goes up
  /// or down. For example, if a `720p` track is sent as `480p` for some time
  /// and then recovers to `720p`, this will have the value `2`.
  int? qualityLimitationResolutionChanges;

  /// Currently configured [scalability mode][0] the [RTP stream], if any.
  ///
  /// [0]: https://w3c.github.io/webrtc-svc#scalabilitymodes*
  /// [RTP stream]: https://w3.org/TR/webrtc-stats#dfn-rtp-stream
  String? scalabilityMode;
}

/// Reason of why media quality in a stream is being reduced by a codec during
/// encoding.
@JsonEnum(fieldRename: FieldRename.kebab)
enum RtcQualityLimitationReason {
  /// Resolution and/or framerate is not limited.
  none,

  /// Resolution and/or framerate is primarily limited due to CPU load.
  cpu,

  /// Resolution and/or framerate is primarily limited due to congestion cues
  /// during bandwidth estimation.
  ///
  /// Typical, congestion control algorithms use inter-arrival time,
  /// round-trip time, packet or other congestion cues to perform bandwidth
  /// estimation.
  bandwidth,

  /// Resolution and/or framerate is primarily limited for a reason other than
  /// the above.
  other,
}

/// Statistics for an outbound [RTP] stream that is currently sent with
/// [RTCPeerConnection] object.
///
/// When there are multiple [RTP] streams connected to the same sender, such as
/// when using simulcast or RTX, there will be one
/// [RTCOutboundRtpStreamStats][5] per RTP stream, with distinct values of the
/// [SSRC] attribute, and all these senders will have a reference to the same
/// "sender" object (of type [RTCAudioSenderStats][1] or
/// [RTCVideoSenderStats][2]) and "track" object (of type
/// [RTCSenderAudioTrackAttachmentStats][3] or
/// [RTCSenderVideoTrackAttachmentStats][4]).
///
/// [RTP]: https://en.wikipedia.org/wiki/Real-time_Transport_Protocol
/// [RTCPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
/// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
/// [1]: https://w3.org/TR/webrtc-stats#dom-rtcaudiosenderstats
/// [2]: https://w3.org/TR/webrtc-stats#dom-rtcvideosenderstats
/// [3]: https://tinyurl.com/sefa5z4
/// [4]: https://tinyurl.com/rkuvpl4
/// [5]: https://w3.org/TR/webrtc-stats#dom-rtcoutboundrtpstreamstats
@JsonSerializable(createFactory: false, includeIfNull: false)
class RtcOutboundRtpStreamStats extends RtcSentRtpStreamStats {
  RtcOutboundRtpStreamStats({
    super.ssrc,
    super.kind,
    super.transportId,
    super.codecId,
    super.packetsSent,
    super.bytesSent,
    this.mediaType,
    this.mid,
    this.mediaSourceId,
    this.remoteId,
    this.headerBytesSent,
    this.retransmittedPacketsSent,
    this.retransmittedBytesSent,
    this.rtxSsrc,
    this.targetBitrate,
    this.totalPacketSendDelay,
    this.nackCount,
    this.active,
    this.packetsSentWithEct1,
  });

  /// Creates [RtcOutboundRtpStreamStats] basing on the
  /// [ffi.RtcStatsType_RtcOutboundRtpStreamStats] received from the native
  /// side.
  static RtcOutboundRtpStreamStats fromFFI(
    ffi.RtcStatsType_RtcOutboundRtpStreamStats stats,
  ) {
    RtcOutboundRtpStreamStatsMediaType? mediaType = switch (stats.mediaType) {
      ffi.RtcOutboundRtpStreamStatsMediaType_Audio m =>
        RtcOutboundRtpStreamAudio(
          totalSamplesSent: m.totalSamplesSent?.toInt(),
          voiceActivityFlag: m.voiceActivityFlag,
        ),
      ffi.RtcOutboundRtpStreamStatsMediaType_Video m =>
        RtcOutboundRtpStreamVideo(
          frameWidth: m.frameWidth,
          frameHeight: m.frameHeight,
          framesPerSecond: m.framesPerSecond,
        ),
    };

    return RtcOutboundRtpStreamStats(
      ssrc: stats.ssrc,
      kind: stats.kind,
      packetsSent: stats.packetsSent,
      bytesSent: stats.bytesSent?.toInt(),
      mediaType: mediaType,
      mediaSourceId: stats.mediaSourceId,
    );
  }

  /// Creates [RtcOutboundRtpStreamStats] basing on the [Map] received from the
  /// native side.
  static RtcOutboundRtpStreamStats fromMap(dynamic stats) {
    RtcOutboundRtpStreamStatsMediaType? mediaType;
    if (stats['kind'] == 'audio') {
      mediaType = RtcOutboundRtpStreamAudio(
        totalSamplesSent: parseInt(stats['totalSamplesSent']),
        voiceActivityFlag: stats['voiceActivityFlag'],
      );
    } else if (stats['kind'] == 'video') {
      mediaType = RtcOutboundRtpStreamVideo(
        rid: stats['rid'],
        encodingIndex: parseInt(stats['encodingIndex']),
        totalEncodedBytesTarget: parseInt(stats['totalEncodedBytesTarget']),
        frameWidth: parseInt(stats['frameWidth']),
        frameHeight: parseInt(stats['frameHeight']),
        framesPerSecond: stats['framesPerSecond'],
        framesSent: parseInt(stats['framesSent']),
        hugeFramesSent: parseInt(stats['hugeFramesSent']),
        framesEncoded: parseInt(stats['framesEncoded']),
        keyFramesEncoded: parseInt(stats['keyFramesEncoded']),
        qpSum: parseInt(stats['qpSum']),
        psnrSum: parseMapStringDouble(stats['psnrSum']),
        psnrMeasurements: parseInt(stats['psnrMeasurements']),
        totalEncodeTime: stats['totalEncodeTime'],
        firCount: parseInt(stats['firCount']),
        pliCount: parseInt(stats['pliCount']),
        encoderImplementation: stats['encoderImplementation'],
        powerEfficientEncoder: stats['powerEfficientEncoder'],
        qualityLimitationReason: _$RtcQualityLimitationReasonEnumMap.entries
            .firstWhereOrNull(
              (e) => e.value == stats['qualityLimitationReason'],
            )
            ?.key,
        qualityLimitationDurations: parseMapStringDouble(
          stats['qualityLimitationDurations'],
        ),
        qualityLimitationResolutionChanges: parseInt(
          stats['qualityLimitationResolutionChanges'],
        ),
        scalabilityMode: stats['scalabilityMode'],
      );
    }

    return RtcOutboundRtpStreamStats(
      ssrc: parseInt(stats['ssrc']),
      kind: stats['kind'],
      transportId: stats['transportId'],
      codecId: stats['codecId'],
      packetsSent: parseInt(stats['packetsSent']),
      bytesSent: parseInt(stats['bytesSent']),
      mediaType: mediaType,
      mid: stats['mid'],
      mediaSourceId: stats['mediaSourceId'],
      remoteId: stats['remoteId'],
      headerBytesSent: parseInt(stats['headerBytesSent']),
      retransmittedPacketsSent: parseInt(stats['retransmittedPacketsSent']),
      retransmittedBytesSent: parseInt(stats['retransmittedBytesSent']),
      rtxSsrc: parseInt(stats['rtxSsrc']),
      targetBitrate: stats['targetBitrate'],
      totalPacketSendDelay: stats['totalPacketSendDelay'],
      nackCount: parseInt(stats['nackCount']),
      active: stats['active'],
      packetsSentWithEct1: parseInt(stats['packetsSentWithEct1']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    var map = _$RtcOutboundRtpStreamStatsToJson(this);

    if (mediaType == null) {
      return map;
    }

    return {
      ...map,
      'mediaType': ?kind,
      ...switch (mediaType!) {
        RtcOutboundRtpStreamVideo v => v.toJson(),
        RtcOutboundRtpStreamAudio a => a.toJson(),
      },
    };
  }

  @override
  RtcStatsType type() => RtcStatsType.outboundRtp;

  /// Media-kind-specific part of [RtcOutboundRtpStreamStats].
  @JsonKey(includeToJson: false, includeFromJson: false) // manually flattened
  RtcOutboundRtpStreamStatsMediaType? mediaType;

  /// [mid] value of the [RTCRtpTransceiver][0] owning this stream.
  ///
  /// If the [RTCRtpTransceiver][0] owning this stream has a [mid] value that
  /// is not `null`, this is that value, otherwise this member MUST NOT be
  /// present.
  ///
  /// [mid]: https://w3.org/TR/webrtc#dom-rtptransceiver-mid
  /// [0]: https://w3.org/TR/webrtc#rtcrtptransceiver-interface
  String? mid;

  /// Identifier of the stats object representing the track currently attached
  /// to the sender of this stream, an [RtcMediaSourceStats].
  String? mediaSourceId;

  /// Identifier for looking up the remote [RtcRemoteInboundRtpStreamStats]
  /// object for the same [SSRC].
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  String? remoteId;

  /// Total number of [RTP] header and padding bytes sent for this [SSRC].
  ///
  /// This does not include the size of transport layer headers such as IP or
  /// UDP.
  ///
  /// [headerBytesSent] + [RtcSentRtpStreamStats.bytesSent] equals the
  /// number of bytes sent as payload over the transport.
  ///
  /// [headerBytesSent]: RtcOutboundRtpStreamStats.headerBytesSent
  /// [RTP]: https://webrtcglossary.com/rtp
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  int? headerBytesSent;

  /// Total number of packets that were retransmitted for this [SSRC].
  ///
  /// This is a subset of the [RtcSentRtpStreamStats.packetsSent].
  ///
  /// If RTX is not negotiated, retransmitted packets are sent over this
  /// [SSRC].
  ///
  /// If RTX was negotiated, retransmitted packets are sent over a separate
  /// [SSRC] but is still accounted for here.
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  int? retransmittedPacketsSent;

  /// Total number of bytes that were retransmitted for this [SSRC], only
  /// including payload bytes.
  ///
  /// This is a subset of [RtcSentRtpStreamStats.bytesSent].
  ///
  /// If RTX is not negotiated, retransmitted bytes are sent over this [SSRC].
  ///
  /// If RTX was negotiated, retransmitted bytes are sent over a separate
  /// [SSRC] but is still accounted for here.
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  int? retransmittedBytesSent;

  /// [SSRC] of the RTX stream that is associated with this stream's [SSRC].
  ///
  /// If RTX is negotiated for retransmissions on a separate [RTP stream],
  /// this is the [SSRC] of the RTX stream that is associated with this
  /// stream's [SSRC].
  ///
  /// If RTX is not negotiated, this value MUST NOT be present.
  ///
  /// [RTP stream]: https://w3.org/TR/webrtc-stats#dfn-rtp-stream
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  int? rtxSsrc;

  /// Current encoder target in bits per second.
  ///
  /// The target is an instantaneous value reflecting the encoder's settings,
  /// but the resulting payload bytes sent per second, excluding
  /// retransmissions, SHOULD closely correlate to the target.
  ///
  /// See also the [RtcSentRtpStreamStats.bytesSent] and the
  /// [retransmittedBytesSent][1].
  ///
  /// This is defined in the same way as the ["TIAS" bitrate RFC3890][0].
  ///
  /// [0]: https://rfc-editor.org/rfc/rfc3890#section-6.2
  /// [1]: RtcOutboundRtpStreamStats.retransmittedBytesSent
  double? targetBitrate;

  /// Total number of seconds that packets have spent buffered locally before
  /// being transmitted onto the network.
  ///
  /// The time is measured from when a packet is emitted from the [RTP]
  /// packetizer until it is handed over to the OS network socket. This
  /// measurement is added to [totalPacketSendDelay][1] when
  /// [RtcSentRtpStreamStats.packetsSent] is incremented.
  ///
  /// [RTP]: https://webrtcglossary.com/rtp
  /// [1]: RtcOutboundRtpStreamStats.totalPacketSendDelay
  double? totalPacketSendDelay;

  /// Total number of [Negative ACKnowledgement (NACK)][1] packets, as defined
  /// in [RFC4585 Section 6.2.1][0], received by this sender.
  ///
  /// [0]: https://rfc-editor.org/rfc/rfc4585#section-6.2.1
  /// [1]: https://bloggeek.me/webrtcglossary/nack
  int? nackCount;

  /// Indicates whether this [RTP stream] is configured to be sent or
  /// disabled.
  ///
  /// Note that an active stream can still not be sending, e.g. when being
  /// limited by network conditions.
  ///
  /// [RTP stream]: https://w3.org/TR/webrtc-stats#dfn-rtp-stream
  bool? active;

  /// Total number of [RTP] packets sent for this [SSRC] with the [ECT(1)][1]
  /// marking defined in [RFC3168 Section 5][2] and used by the L4S protocol
  /// described in [RFC9331].
  ///
  /// [RFC9331]: https://rfc-editor.org/rfc/rfc9331
  /// [RTP]: https://webrtcglossary.com/rtp
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  /// [1]: https://rfc-editor.org/rfc/rfc3168#section-3
  /// [2]: https://rfc-editor.org/rfc/rfc3168#section-5
  int? packetsSentWithEct1;
}

/// Media type pf [RtcInboundRtpStreamStats].
@JsonSerializable(createFactory: false, includeIfNull: false)
sealed class RtcInboundRtpStreamMediaType {}

/// Audio [RtcInboundRtpStreamMediaType].
@JsonSerializable(createFactory: false, includeIfNull: false)
class RtcInboundRtpStreamAudio extends RtcInboundRtpStreamMediaType {
  RtcInboundRtpStreamAudio({
    this.totalSamplesReceived,
    this.concealedSamples,
    this.silentConcealedSamples,
    this.concealmentEvents,
    this.insertedSamplesForDeceleration,
    this.removedSamplesForAcceleration,
    this.audioLevel,
    this.totalAudioEnergy,
    this.totalSamplesDuration,
    this.playoutId,
  });

  Map<String, dynamic> toJson() => _$RtcInboundRtpStreamAudioToJson(this);

  /// Total number of samples that have been received on the [RTP stream].
  ///
  /// This includes [RtcInboundRtpStreamAudio.concealedSamples].
  ///
  /// [RTP stream]: https://w3.org/TR/webrtc-stats#dfn-rtp-stream
  int? totalSamplesReceived;

  /// Total number of samples that are concealed samples.
  ///
  /// A concealed sample is a sample that was replaced with synthesized
  /// samples generated locally before being played out. Examples of
  /// samples that have to be concealed are samples from lost packets
  /// (reported in [RtcReceivedRtpStreamStats.packetsLost]) or samples
  /// from packets that arrive too late to be played out (reported in
  /// [RtcInboundRtpStreamStats.packetsDiscarded]).
  int? concealedSamples;

  /// Total number of concealed samples inserted that are "silent".
  ///
  /// Playing out silent samples results in silence or comfort noise.
  ///
  /// This is a subset of
  /// [RtcInboundRtpStreamAudio.concealedSamples].
  int? silentConcealedSamples;

  /// Number of concealment events.
  ///
  /// This counter increases every time a concealed sample is synthesized
  /// after a non-concealed sample. That is, multiple consecutive
  /// concealed samples will increase the
  /// [RtcInboundRtpStreamAudio.concealedSamples] count multiple
  /// times, but is a single concealment event.
  int? concealmentEvents;

  /// Number of inserted deceleration samples.
  ///
  /// When playout is slowed down, this counter is increased by the
  /// difference between the number of samples received and the number of
  /// samples played out. If playout is slowed down by inserting samples,
  /// this will be the number of inserted samples.
  int? insertedSamplesForDeceleration;

  /// Number of removed acceleration samples.
  ///
  /// When playout is sped up, this counter is increased by the difference
  /// between the number of samples received and the number of samples
  /// played out. If speedup is achieved by removing samples, this will be
  /// the count of samples removed.
  int? removedSamplesForAcceleration;

  /// Audio level of the receiving track.
  ///
  /// For audio levels of tracks attached locally, see the
  /// [RtcAudioSourceStats] instead.
  ///
  /// The value is between `0..1` (linear), where `1.0` represents
  /// `0 dBov`, `0` represents silence, and `0.5` represents approximately
  /// `6 dBSPL` change in the sound pressure level from `0 dBov`.
  ///
  /// The audio level is averaged over some small interval, using the
  /// algorithm described under [totalAudioEnergy][1]. The interval used
  /// is implementation-defined.
  ///
  /// [1]: https://tinyurl.com/webrtc-stats-totalaudioenergy
  double? audioLevel;

  /// Audio energy of the receiving track.
  ///
  /// For audio energy of tracks attached locally, see the
  /// [RtcAudioSourceStats] instead.
  double? totalAudioEnergy;

  /// Audio duration of the receiving track.
  ///
  /// For audio durations of tracks attached locally, see the
  /// [RtcAudioSourceStats] instead.
  double? totalSamplesDuration;

  /// Indicator whether audio playout is happening.
  ///
  /// This is used to look up the corresponding [RtcAudioPlayoutStats].
  String? playoutId;
}

/// Video [RtcInboundRtpStreamMediaType].
@JsonSerializable(createFactory: false, includeIfNull: false)
class RtcInboundRtpStreamVideo extends RtcInboundRtpStreamMediaType {
  RtcInboundRtpStreamVideo({
    this.framesDecoded,
    this.keyFramesDecoded,
    this.frameWidth,
    this.frameHeight,
    this.totalInterFrameDelay,
    this.framesPerSecond,
    this.firCount,
    this.pliCount,
    this.framesReceived,
  });

  Map<String, dynamic> toJson() => _$RtcInboundRtpStreamVideoToJson(this);

  /// Total number of frames correctly decoded for the [RTP stream], i.e.
  /// frames that would be displayed if no frames are dropped.
  ///
  /// [RTP stream]: https://w3.org/TR/webrtc-stats#dfn-rtp-stream
  int? framesDecoded;

  /// Total number of key frames, such as key frames in VP8 [RFC6386] or
  /// IDR-frames in H.264 [RFC6184], successfully decoded for the media
  /// [RTP stream].
  ///
  /// This is a subset of [RtcInboundRtpStreamVideo.framesDecoded].
  /// [RtcInboundRtpStreamVideo.framesDecoded] -
  /// [RtcInboundRtpStreamVideo.keyFramesDecoded] gives the number
  /// of delta frames decoded.
  ///
  /// [RFC6386]: https://w3.org/TR/webrtc-stats#bib-rfc6386
  /// [RFC6184]: https://w3.org/TR/webrtc-stats#bib-rfc6184
  /// [RTP stream]: https://w3.org/TR/webrtc-stats#dfn-rtp-stream
  int? keyFramesDecoded;

  /// Total number of frames that have been rendered.
  ///
  /// It's incremented just after a frame has been rendered.
  int? framesRendered;

  /// Total number of frames dropped prior to decode or dropped because
  /// the frame missed its display deadline for the receiver's track.
  ///
  /// The measurement begins when the receiver is created and is a
  /// cumulative metric as defined in Appendix A (g) of [RFC7004].
  ///
  /// [RFC7004]: https://rfc-editor.org/rfc/rfc7004
  int? framesDropped;

  /// Width of the last decoded frame.
  ///
  /// Before the first frame is decoded this attribute is missing.
  int? frameWidth;

  /// Height of the last decoded frame.
  ///
  /// Before the first frame is decoded this attribute is missing.
  int? frameHeight;

  /// Number of decoded frames in the last second.
  double? framesPerSecond;

  /// Sum of the QP values of frames decoded by the receiver.
  ///
  /// The count of frames is in
  /// [RtcInboundRtpStreamVideo.framesDecoded].
  ///
  /// The definition of QP value depends on the codec; for VP8, the QP
  /// value is the value carried in the frame header as the syntax element
  /// `y_ac_qi`, and defined in [RFC6386] section 19.2. Its range is
  /// `0..127`.
  ///
  /// Note, that the QP value is only an indication of quantizer values
  /// used; many formats have ways to vary the quantizer value within the
  /// frame.
  ///
  /// [RFC6386]: https://rfc-editor.org/rfc/rfc6386
  int? qpSum;

  /// Total number of seconds that have been spent decoding the
  /// [RtcInboundRtpStreamVideo.framesDecoded] frames of
  /// the [RTP stream].
  ///
  /// The average decode time can be calculated by dividing this value
  /// with the [RtcInboundRtpStreamVideo.framesDecoded]. The time
  /// it takes to decode one frame is the time passed between feeding the
  /// decoder a frame and the decoder returning decoded data for that
  /// frame.
  ///
  /// [RTP stream]: https://w3.org/TR/webrtc-stats#dfn-rtp-stream
  double? totalDecodeTime;

  /// Sum of the interframe delays in seconds between consecutively
  /// rendered frames, recorded just after a frame has been rendered.
  ///
  /// The interframe delay variance be calculated from
  /// [RtcInboundRtpStreamVideo.totalInterFrameDelay],
  /// [RtcInboundRtpStreamVideo.totalSquaredInterFrameDelay],
  /// and [RtcInboundRtpStreamVideo.framesRendered] according to the
  /// formula:
  /// `(totalSquaredInterFrameDelay - totalInterFrameDelay^2 /
  /// framesRendered) / framesRendered`.
  double? totalInterFrameDelay;

  /// Sum of the squared interframe delays in seconds between
  /// consecutively rendered frames, recorded just after a frame has been
  /// rendered.
  ///
  /// See the [RtcInboundRtpStreamVideo.totalInterFrameDelay] for
  /// details on how to calculate the interframe delay variance.
  double? totalSquaredInterFrameDelay;

  /// Total number of video pauses experienced by the receiver.
  ///
  /// Video is considered to be paused if time passed since last rendered
  /// frame exceeds 5 seconds. It's incremented when a frame is rendered
  /// after such a pause.
  int? pauseCount;

  /// Total duration of pauses, in seconds.
  ///
  /// For definition of pause see the
  /// [RtcInboundRtpStreamVideo.pauseCount].
  ///
  /// This value is updated when a frame is rendered.
  double? totalPausesDuration;

  /// Total number of video freezes experienced by the receiver.
  ///
  /// It's a freeze if frame duration, which is time interval between two
  /// consecutively rendered frames, is equal or exceeds
  /// `Max(3 * avg_frame_duration_ms, avg_frame_duration_ms + 150)`,
  /// where `avg_frame_duration_ms` is linear average of durations of last
  /// 30 rendered frames.
  int? freezeCount;

  /// Total duration of rendered frames which are considered as frozen, in
  /// seconds.
  ///
  /// For definition of freeze see the
  /// [RtcInboundRtpStreamVideo.freezeCount].
  ///
  /// This value is updated when a frame is rendered.
  double? totalFreezesDuration;

  /// Total number of Full Intra Request (FIR) packets, as defined in
  /// [RFC5104] section 4.3.1, sent by the receiver.
  ///
  /// Doesn't count the RTCP FIR indicated in [RFC2032] which was
  /// deprecated by [RFC4587].
  ///
  /// [RFC5104]: https://rfc-editor.org/rfc/rfc5104
  /// [RFC2032]: https://rfc-editor.org/rfc/rfc2032
  /// [RFC4587]: https://rfc-editor.org/rfc/rfc4587
  int? firCount;

  /// Total number of Picture Loss Indication (PLI) packets, as defined in
  /// [RFC4585] section 6.3.1, sent by the receiver.
  ///
  /// [RFC4585]: https://rfc-editor.org/rfc/rfc4585
  int? pliCount;

  /// Total number of complete frames received on the [RTP stream].
  ///
  /// This metric is incremented when the complete frame is received.
  ///
  /// [RTP stream]: https://w3.org/TR/webrtc-stats#dfn-rtp-stream
  int? framesReceived;

  /// Identification of the used the decoder implementation.
  ///
  /// This is useful for diagnosing interoperability issues.
  String? decoderImplementation;

  /// Indicator whether the decoder currently used is considered power
  /// efficient by the user agent.
  ///
  /// This SHOULD reflect if the configuration results in hardware
  /// acceleration, but the user agent MAY take other information into
  /// account when deciding if the configuration is considered power
  /// efficient.
  bool? powerEfficientDecoder;

  /// Total number of frames correctly decoded for the [RTP stream] that
  /// consist of more than one RTP packet.
  ///
  /// For such frames the [totalAssemblyTime][1] is incremented. The
  /// average frame assembly time can be calculated by dividing the
  /// [totalAssemblyTime][1] with this value.
  ///
  /// [RTP stream]: https://w3.org/TR/webrtc-stats#dfn-rtp-stream
  /// [1]: RtcInboundRtpStreamVideo.totalAssemblyTime
  int? framesAssembledFromMultiplePackets;

  /// Sum of the time, in seconds, each video frame takes from the time
  /// the first RTP packet is received (reception timestamp) and to the
  /// time the last RTP packet of a frame is received.
  ///
  /// Only incremented for frames consisting of more than one RTP packet.
  ///
  /// Given the complexities involved, the time of arrival or the
  /// reception timestamp is measured as close to the network layer as
  /// possible. This metric is not incremented for frames that are not
  /// decoded, i.e., [RtcInboundRtpStreamVideo.framesDropped] or
  /// frames that fail decoding for other reasons (if any).
  double? totalAssemblyTime;

  /// Cumulative sum of all corruption probability measurements that have
  /// been made for this SSRC.
  ///
  /// See the [RtcInboundRtpStreamVideo.corruptionMeasurements]
  /// regarding when this attribute SHOULD be present.
  ///
  /// Each measurement added to
  /// [RtcInboundRtpStreamVideo.totalCorruptionProbability] MUST be
  /// in the range `[0.0, 1.0]`, where a value of `0.0` indicates the
  /// system has estimated there is no or negligible corruption present in
  /// the processed frame. Similarly, a value of `1.0` indicates there is
  /// almost certainly a corruption visible in the processed frame. A
  /// value in between those two, indicates there is likely some
  /// corruption visible, but it could for instance have a low magnitude
  /// or be present only in a small portion of the frame.
  double? totalCorruptionProbability;

  /// Cumulative sum of all corruption probability measurements squared
  /// that have been made for this SSRC.
  ///
  /// See the [RtcInboundRtpStreamVideo.corruptionMeasurements]
  /// regarding when this attribute SHOULD be present.
  double? totalSquaredCorruptionProbability;

  /// Number of corruption probability measurements.
  ///
  /// When the user agent is able to make a corruption probability
  /// measurement, this counter is incremented for each such measurement
  /// and the [totalCorruptionProbability][2] and the
  /// [totalSquaredCorruptionProbability][1] are aggregated with this
  /// measurement and measurement squared respectively. If the
  /// [corruption-detection][0] header extension is present in the RTP
  /// packets, corruption probability measurements MUST be present.
  ///
  /// [0]: https://tinyurl.com/goog-corruption-detection
  /// [1]:RtcInboundRtpStreamVideo.totalSquaredCorruptionProbability
  /// [2]: RtcInboundRtpStreamVideo.totalCorruptionProbability
  int? corruptionMeasurements;
}

/// Codecs are created when registered for an [RTP] transport, but only the
/// subset of codecs that are in use (referenced by an [RTP stream]) are exposed
/// in [getStats()].
///
/// The [RtcCodecStats] object is created when one or more
/// [RtcRtpStreamStats.codecId] references the codec. When there no longer
/// exists any reference to the [RtcCodecStats], the stats object is deleted.
/// If the same codec is used again in the future, the [RtcCodecStats] object
/// is revived with the same [StatId] as before.
///
/// Codec objects may be referenced by multiple [RTP stream]s in media sections
/// using the same transport, but similar codecs in different transports have
/// different [RtcCodecStats] objects.
///
/// [Full doc on W3C][spec].
///
/// [getStats()]: https://tinyurl.com/webrtc-rfc-get-stats
/// [RTP]: https://webrtcglossary.com/rtp
/// [RTP stream]: https://w3.org/TR/webrtc-stats#dfn-rtp-stream
/// [spec]: https://w3.org/TR/webrtc-stats#dom-rtccodecstats
@JsonSerializable(createFactory: false, includeIfNull: false)
class RtcCodecStats extends RtcStat {
  RtcCodecStats({
    this.payloadType,
    this.transportId,
    this.mimeType,
    this.clockRate,
    this.channels,
    this.sdpFmtpLine,
  });

  static RtcCodecStats fromMap(dynamic stats) {
    return RtcCodecStats(
      payloadType: parseInt(stats['payloadType']),
      transportId: stats['transportId'],
      mimeType: stats['mimeType'],
      clockRate: parseInt(stats['clockRate']),
      channels: parseInt(stats['channels']),
      sdpFmtpLine: stats['sdpFmtpLine'],
    );
  }

  @override
  Map<String, dynamic> toJson() => _$RtcCodecStatsToJson(this);

  @override
  RtcStatsType type() => RtcStatsType.codec;

  /// Payload type as used in [RTP] encoding or decoding.
  ///
  /// [RTP]: https://webrtcglossary.com/rtp
  int? payloadType;

  /// Unique identifier of the transport on which this codec is being used,
  /// which can be used to look up the corresponding [RtcTransportStats]
  /// object.
  String? transportId;

  /// Codec MIME media type/subtype defined in the IANA media types registry
  /// [IANA-MEDIA-TYPES][0], e.g. `video/VP8`.
  ///
  /// [0]: https://iana.org/assignments/media-types/media-types.xhtml
  String? mimeType;

  /// Media sampling rate.
  int? clockRate;

  /// Number of channels (mono=1, stereo=2).
  int? channels;

  /// The "format specific parameters" field from the `a=fmtp` line in the
  /// SDP corresponding to the codec, if one exists, as
  /// [defined by RFC8829][1].
  ///
  /// [1]: https://rfc-editor.org/rfc/rfc8829#section-5.8
  String? sdpFmtpLine;
}

/// Statistics for an inbound [RTP] stream that is currently received with
/// [RTCPeerConnection] object.
///
/// [RTP]: https://en.wikipedia.org/wiki/Real-time_Transport_Protocol
/// [RTCPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
@JsonSerializable(createFactory: false, includeIfNull: false)
class RtcInboundRtpStreamStats extends RtcReceivedRtpStreamStats {
  RtcInboundRtpStreamStats({
    super.ssrc,
    super.kind,
    super.transportId,
    super.codecId,
    super.packetsReceived,
    super.packetsReceivedWithEct1,
    super.packetsReceivedWithCe,
    super.packetsReportedAsLost,
    super.packetsReportedAsLostButRecovered,
    super.packetsLost,
    super.jitter,
    this.mediaType,
    this.trackIdentifier,
    this.mid,
    this.remoteId,
    this.bytesReceived,
    this.jitterBufferEmittedCount,
    this.jitterBufferDelay,
    this.jitterBufferTargetDelay,
    this.jitterBufferMinimumDelay,
    this.headerBytesReceived,
    this.packetsDiscarded,
    this.lastPacketReceivedTimestamp,
    this.estimatedPlayoutTimestamp,
    this.fecBytesReceived,
    this.fecPacketsReceived,
    this.fecPacketsDiscarded,
    this.totalProcessingDelay,
    this.nackCount,
    this.retransmittedPacketsReceived,
    this.retransmittedBytesReceived,
    this.rtxSsrc,
    this.fecSsrc,
  });

  /// Creates [RtcInboundRtpStreamStats] basing on the
  /// [ffi.RtcStatsType_RtcInboundRtpStreamStats] received from the native side.
  static RtcInboundRtpStreamStats fromFFI(
    ffi.RtcStatsType_RtcInboundRtpStreamStats stats,
  ) {
    RtcInboundRtpStreamMediaType? mediaType = switch (stats.mediaType) {
      ffi.RtcInboundRtpStreamMediaType_Audio m => RtcInboundRtpStreamAudio(
        totalSamplesReceived: m.totalSamplesReceived?.toInt(),
        concealedSamples: m.concealedSamples?.toInt(),
        silentConcealedSamples: m.silentConcealedSamples?.toInt(),
        audioLevel: m.audioLevel,
        totalAudioEnergy: m.totalAudioEnergy,
        totalSamplesDuration: m.totalSamplesDuration,
      ),
      ffi.RtcInboundRtpStreamMediaType_Video m => RtcInboundRtpStreamVideo(
        framesDecoded: m.framesDecoded,
        keyFramesDecoded: m.keyFramesDecoded,
        frameWidth: m.frameWidth,
        frameHeight: m.frameHeight,
        totalInterFrameDelay: m.totalInterFrameDelay,
        framesPerSecond: m.framesPerSecond,
        firCount: m.firCount,
        pliCount: m.pliCount,
        framesReceived: m.framesReceived,
      ),
      null => null,
    };

    return RtcInboundRtpStreamStats(
      ssrc: stats.ssrc,
      kind: stats.kind,
      packetsReceived: stats.packetsReceived,
      mediaType: mediaType,
      remoteId: stats.remoteId,
      bytesReceived: stats.bytesReceived?.toInt(),
      jitterBufferEmittedCount: stats.jitterBufferEmittedCount?.toInt(),
    );
  }

  /// Creates [RtcInboundRtpStreamStats] basing on the [Map] received from the
  /// native side.
  static RtcInboundRtpStreamStats fromMap(dynamic stats) {
    RtcInboundRtpStreamMediaType? mediaType;
    if (stats['kind'] == 'audio') {
      mediaType = RtcInboundRtpStreamAudio(
        totalSamplesReceived: parseInt(stats['totalSamplesReceived']),
        concealedSamples: parseInt(stats['concealedSamples']),
        silentConcealedSamples: parseInt(stats['silentConcealedSamples']),
        concealmentEvents: parseInt(stats['concealmentEvents']),
        insertedSamplesForDeceleration: parseInt(
          stats['insertedSamplesForDeceleration'],
        ),
        removedSamplesForAcceleration: parseInt(
          stats['removedSamplesForAcceleration'],
        ),
        audioLevel: stats['audioLevel'],
        totalAudioEnergy: stats['totalAudioEnergy'],
        totalSamplesDuration: stats['totalSamplesDuration'],
        playoutId: stats['playoutId'],
      );
    } else if (stats['kind'] == 'video') {
      mediaType = RtcInboundRtpStreamVideo(
        framesDecoded: parseInt(stats['framesDecoded']),
        keyFramesDecoded: parseInt(stats['keyFramesDecoded']),
        frameWidth: parseInt(stats['frameWidth']),
        frameHeight: parseInt(stats['frameHeight']),
        totalInterFrameDelay: stats['totalInterFrameDelay'],
        framesPerSecond: stats['framesPerSecond'],
        firCount: parseInt(stats['firCount']),
        pliCount: parseInt(stats['pliCount']),
        framesReceived: parseInt(stats['framesReceived']),
      );
    }

    return RtcInboundRtpStreamStats(
      ssrc: parseInt(stats['ssrc']),
      kind: stats['kind'],
      transportId: stats['transportId'],
      codecId: stats['codecId'],
      packetsReceived: parseInt(stats['packetsReceived']),
      packetsReceivedWithEct1: parseInt(stats['packetsReceivedWithEct1']),
      packetsReceivedWithCe: parseInt(stats['packetsReceivedWithCe']),
      packetsReportedAsLost: parseInt(stats['packetsReportedAsLost']),
      packetsReportedAsLostButRecovered: parseInt(
        stats['packetsReportedAsLostButRecovered'],
      ),
      packetsLost: parseInt(stats['packetsLost']),
      jitter: stats['jitter'],
      mediaType: mediaType,
      trackIdentifier: stats['trackIdentifier'],
      mid: stats['mid'],
      remoteId: stats['remoteId'],
      bytesReceived: parseInt(stats['bytesReceived']),
      jitterBufferEmittedCount: parseInt(stats['jitterBufferEmittedCount']),
      jitterBufferDelay: stats['jitterBufferDelay'],
      jitterBufferTargetDelay: stats['jitterBufferTargetDelay'],
      jitterBufferMinimumDelay: stats['jitterBufferMinimumDelay'],
      headerBytesReceived: parseInt(stats['headerBytesReceived']),
      packetsDiscarded: parseInt(stats['packetsDiscarded']),
      lastPacketReceivedTimestamp: stats['lastPacketReceivedTimestamp'],
      estimatedPlayoutTimestamp: stats['estimatedPlayoutTimestamp'],
      fecBytesReceived: parseInt(stats['fecBytesReceived']),
      fecPacketsReceived: parseInt(stats['fecPacketsReceived']),
      fecPacketsDiscarded: parseInt(stats['fecPacketsDiscarded']),
      totalProcessingDelay: stats['totalProcessingDelay'],
      nackCount: parseInt(stats['nackCount']),
      retransmittedPacketsReceived: parseInt(
        stats['retransmittedPacketsReceived'],
      ),
      retransmittedBytesReceived: parseInt(stats['retransmittedBytesReceived']),
      rtxSsrc: parseInt(stats['rtxSsrc']),
      fecSsrc: parseInt(stats['fecSsrc']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    var map = _$RtcInboundRtpStreamStatsToJson(this);

    if (mediaType == null) {
      return map;
    }

    return {
      ...map,
      'mediaType': ?kind,
      ...switch (mediaType!) {
        RtcInboundRtpStreamVideo v => v.toJson(),
        RtcInboundRtpStreamAudio a => a.toJson(),
      },
    };
  }

  @override
  RtcStatsType type() => RtcStatsType.inboundRtp;

  /// Fields which should be in these [RtcStats] based on `mediaType`.
  @JsonKey(includeToJson: false, includeFromJson: false) // manually flattened
  RtcInboundRtpStreamMediaType? mediaType;

  /// [id` attribute][2] value of the [MediaStreamTrack][1].
  ///
  /// [1]: https://w3.org/TR/mediacapture-streams#mediastreamtrack
  /// [2]: https://w3.org/TR/mediacapture-streams#dom-mediastreamtrack-id
  String? trackIdentifier;

  /// [mid] value of the [RTCRtpTransceiver][0] owning this stream.
  ///
  /// If the [RTCRtpTransceiver][0] owning this stream has a [mid] value that
  /// is not `null`, this is that value, otherwise this member MUST NOT be
  /// present.
  ///
  /// [mid]: https://w3.org/TR/webrtc#dom-rtptransceiver-mid
  /// [0]: https://w3.org/TR/webrtc#rtcrtptransceiver-interface
  String? mid;

  /// Identifier for looking up the remote [RtcRemoteOutboundRtpStreamStats]
  /// object for the same [SSRC].
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  String? remoteId;

  /// Total number of bytes received for this [SSRC].
  ///
  /// This includes retransmissions.
  ///
  /// Calculated as defined in [RFC3550 Section 6.4.1][1].
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  /// [1]: https://rfc-editor.org/rfc/rfc3550#section-6.4.1
  int? bytesReceived;

  /// Total number of audio samples or video frames that have come out of the
  /// jitter buffer (increasing the [jitterBufferDelay][1]).
  ///
  /// [1]: RtcInboundRtpStreamStats.jitterBufferDelay
  int? jitterBufferEmittedCount;

  /// Sum of the time, in seconds, each [audio sample] or a video frame takes
  /// from the time the first packet is received by the jitter buffer (ingest
  /// timestamp) to the time it exits the jitter buffer (emit timestamp).
  ///
  /// The purpose of the jitter buffer is to recombine [RTP] packets into
  /// frames (in the case of video) and have smooth playout. The model
  /// described here assumes that the samples or frames are still compressed
  /// and have not yet been decoded.
  ///
  /// In the case of audio, several samples belong to the same [RTP] packet,
  /// hence they will have the same ingest timestamp but different jitter
  /// buffer emit timestamps.
  ///
  /// In the case of video, the frame may be received over several [RTP]
  /// packets, hence the ingest timestamp is the earliest packet of the frame
  /// that entered the jitter buffer and the emit timestamp is when the whole
  /// frame exits the jitter buffer.
  ///
  /// This metric increases upon samples or frames exiting, having completed
  /// their time in the buffer (and incrementing the
  /// [jitterBufferEmittedCount][1]).
  ///
  /// The average jitter buffer delay can be calculated by dividing the
  /// [jitterBufferDelay][2] with the [jitterBufferEmittedCount][1].
  ///
  /// [audio sample]: https://w3.org/TR/webrtc-stats#dfn-audio-sample
  /// [RTP]: https://webrtcglossary.com/rtp
  /// [1]: RtcInboundRtpStreamStats.jitterBufferEmittedCount
  /// [2]: RtcInboundRtpStreamStats.jitterBufferDelay
  double? jitterBufferDelay;

  /// Cumulative time of delays, in seconds, at the time that a sample is
  /// emitted from the jitter buffer.
  ///
  /// This value is increased by the target jitter buffer delay every time a
  /// sample is emitted by the jitter buffer. The added target is the target
  /// delay, in seconds, at the time that the sample was emitted from the
  /// jitter buffer.
  ///
  /// To get the average target delay, divide by
  /// [jitterBufferEmittedCount][1].
  ///
  /// [1]: RtcInboundRtpStreamStats.jitterBufferEmittedCount
  double? jitterBufferTargetDelay;

  /// Minimum jitter buffer delay, in seconds.
  ///
  /// There are various reasons why the jitter buffer delay might be increased
  /// to a higher value, such as to achieve A/V synchronization or because a
  /// [jitterBufferTarget][0] was set on an [RTCRtpReceiver]. When using
  /// one of these mechanisms, it can be useful to keep track of the minimal
  /// jitter buffer delay that could have been achieved, so clients can track
  /// the amount of additional delay that is being added.
  ///
  /// This metric works the same way as the [jitterBufferTargetDelay][1],
  /// except that it is not affected by external mechanisms that increase the
  /// jitter buffer target delay, such as [jitterBufferTarget][0], A/V sync,
  /// or any other mechanisms. This metric is purely based on the network
  /// characteristics such as jitter and packet loss, and can be seen as the
  /// minimum obtainable jitter buffer delay if no external factors would
  /// affect it.
  ///
  /// This metric is updated every time the [jitterBufferEmittedCount][2]
  /// is updated.
  ///
  /// [RTCRtpReceiver]: https://w3.org/TR/webrtc#rtcrtpreceiver-interface
  /// [0]: https://w3.org/TR/webrtc#dom-rtcrtpreceiver-jitterbuffertarget
  /// [1]: RtcInboundRtpStreamStats.jitterBufferTargetDelay
  /// [2]: RtcInboundRtpStreamStats.jitterBufferEmittedCount
  double? jitterBufferMinimumDelay;

  /// Total number of [RTP] header and padding bytes received for this [SSRC].
  ///
  /// This includes retransmissions. Does not include transport headers
  /// (IP/UDP). [headerBytesReceived][1] + [bytesReceived][2] equals
  /// the total number of bytes received as payload over the transport.
  ///
  /// [RTP]: https://webrtcglossary.com/rtp
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  /// [1]: RtcInboundRtpStreamStats.headerBytesReceived
  /// [2]: RtcInboundRtpStreamStats.bytesReceived
  int? headerBytesReceived;

  /// Cumulative number of [RTP] packets discarded by the jitter buffer due to
  /// late or early-arrival, i.e. these packets are not played out.
  ///
  /// [RTP] packets discarded due to packet duplication are not reported in
  /// this metric [XRBLOCK-STATS].
  ///
  /// Calculated as defined in [RFC7002 Section 3.2][1] and [Appendix A.a][2].
  ///
  /// [RTP]: https://webrtcglossary.com/rtp
  /// [XRBLOCK-STATS]: https://tinyurl.com/xr-report
  /// [1]: https://rfc-editor.org/rfc/rfc7002#section-3.2
  /// [2]: https://rfc-editor.org/rfc/rfc7002#appendix-A
  int? packetsDiscarded;

  /// Timestamp at which the last [RTP] packet was received for this [SSRC].
  ///
  /// This differs from the [RtcStat.timestamp], which represents the time
  /// at which the statistics were generated or received by the local
  /// endpoint.
  ///
  /// [RTP]: https://webrtcglossary.com/rtp
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  double? lastPacketReceivedTimestamp;

  /// Estimated playout time of this receiver's track in sender [NTP] time.
  ///
  /// Can be used to estimate A/V sync across tracks from the same source.
  ///
  /// [NTP]: https://en.wikipedia.org/wiki/Network_Time_Protocol
  double? estimatedPlayoutTimestamp;

  /// Total number of [RTP] FEC bytes received for this [SSRC], only including
  /// payload bytes.
  ///
  /// This is a subset of the [bytesReceived][1].
  ///
  /// If FEC uses a different [SSRC], packets are still accounted for here.
  ///
  /// [RTP]: https://webrtcglossary.com/rtp
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  /// [1]: RtcInboundRtpStreamStats.bytesReceived
  int? fecBytesReceived;

  /// Total number of [RTP] FEC packets received for this [SSRC].
  ///
  /// If FEC uses a different [SSRC], packets are still accounted for here.
  ///
  /// Can also increment when receiving in-band FEC (for example, [Opus]).
  ///
  /// [Opus]: https://en.wikipedia.org/wiki/Opus_(audio_format)
  /// [RTP]: https://webrtcglossary.com/rtp
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  int? fecPacketsReceived;

  /// Total number of [RTP] FEC packets received for this [SSRC] where the
  /// error correction payload was discarded (for example, sources already
  /// recovered or FEC arrived late).
  ///
  /// This is a subset of the [fecBytesReceived][1].
  ///
  /// [RTP]: https://webrtcglossary.com/rtp
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  /// [1]: RtcInboundRtpStreamStats.fecBytesReceived
  int? fecPacketsDiscarded;

  /// Sum of the time, in seconds, each [audio sample] or video frame takes
  /// from the time the first [RTP] packet is received (reception timestamp)
  /// and to the time the corresponding sample or frame is decoded (decoded
  /// timestamp).
  ///
  /// At this point the audio sample or video frame is ready for playout by
  /// the [MediaStreamTrack][1]. Typically ready for playout here means after
  /// the audio sample or video frame is fully decoded by the decoder.
  ///
  /// [audio sample]: https://w3.org/TR/webrtc-stats#dfn-audio-sample
  /// [RTP]: https://webrtcglossary.com/rtp
  /// [1]: https://w3.org/TR/mediacapture-streams#mediastreamtrack
  double? totalProcessingDelay;

  /// Total number of [Negative ACKnowledgement (NACK)][1] [RTCP] feedback
  /// packets sent by this receiver for this [SSRC], as defined in
  /// [RFC4585 Section 6.2.1][0].
  ///
  /// [RTCP]: https://webrtcglossary.com/rtcp
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  /// [0]: https://rfc-editor.org/rfc/rfc4585#section-6.2.1
  /// [1]: https://bloggeek.me/webrtcglossary/nack
  int? nackCount;

  /// Total number of retransmitted packets that were received for this
  /// [SSRC].
  ///
  /// This is a subset of the [RtcReceivedRtpStreamStats.packetsReceived].
  ///
  /// If RTX is not negotiated, retransmitted packets can not be identified
  /// and this member MUST NOT exist.
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  int? retransmittedPacketsReceived;

  /// Total number of retransmitted bytes that were received for this [SSRC],
  /// only including payload bytes.
  ///
  /// This is a subset of the [bytesReceived][1].
  ///
  /// If RTX is not negotiated, retransmitted packets can not be identified
  /// and this member MUST NOT exist.
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  /// [1]: RtcInboundRtpStreamStats.bytesReceived
  int? retransmittedBytesReceived;

  /// [SSRC] of the RTX stream that is associated with this stream's [SSRC].
  ///
  /// If RTX is negotiated for retransmissions on a separate [RTP stream],
  /// this is the [SSRC] of the RTX stream that is associated with this
  /// stream's [SSRC].
  ///
  /// If RTX is not negotiated, this value MUST NOT be present.
  ///
  /// [RTP stream]: https://w3.org/TR/webrtc-stats#dfn-rtp-stream
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  int? rtxSsrc;

  /// [SSRC] of the FEC stream that is associated with this stream's [SSRC].
  ///
  /// If a FEC mechanism that uses a separate [RTP stream] is negotiated, this
  /// is the [SSRC] of the FEC stream that is associated with this stream's
  /// [SSRC].
  ///
  /// If FEC is not negotiated or uses the same [RTP stream], this value MUST
  /// NOT be present.
  ///
  /// [RTP stream]: https://w3.org/TR/webrtc-stats#dfn-rtp-stream
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  int? fecSsrc;
}

/// ICE candidate pair statistics related to the [RTCIceTransport] objects.
///
/// A candidate pair that is not the current pair for a transport is [deleted]
/// when the [RTCIceTransport] does an ICE restart, at the time the state
/// changes to [new][1].
///
/// A candidate pair that is the current pair for a transport is [deleted] after
/// an ICE restart when the [RTCIceTransport] switches to using a candidate pair
/// generated from the new candidates; this time doesn't correspond to any other
/// externally observable event.
///
/// [deleted]: https://w3.org/TR/webrtc-stats#dfn-deleted
/// [RTCIceTransport]: https://w3.org/TR/webrtc#dom-rtcicetransport
/// [1]: https://w3.org/TR/webrtc#dom-rtcicetransportstate-new
@JsonSerializable(createFactory: false, includeIfNull: false)
class RtcIceCandidatePairStats extends RtcStat {
  RtcIceCandidatePairStats({
    this.transportId,
    this.localCandidateId,
    this.remoteCandidateId,
    this.state,
    this.nominated,
    this.priority,
    this.packetsSent,
    this.packetsReceived,
    this.bytesSent,
    this.bytesReceived,
    this.lastPacketSentTimestamp,
    this.lastPacketReceivedTimestamp,
    this.totalRoundTripTime,
    this.currentRoundTripTime,
    this.availableOutgoingBitrate,
    this.availableIncomingBitrate,
    this.requestsReceived,
    this.requestsSent,
    this.responsesReceived,
    this.responsesSent,
    this.consentRequestsSent,
    this.packetsDiscardedOnSend,
    this.bytesDiscardedOnSend,
  });

  /// Creates [RtcIceCandidatePairStats] basing on the
  /// [ffi.RtcStatsType_RtcIceCandidatePairStats] received from the native side.
  static RtcIceCandidatePairStats fromFFI(
    ffi.RtcStatsType_RtcIceCandidatePairStats stats,
  ) {
    return RtcIceCandidatePairStats(
      state: RtcStatsIceCandidatePairState.values[stats.state.index],
      nominated: stats.nominated,
      bytesSent: stats.bytesSent?.toInt(),
      bytesReceived: stats.bytesReceived?.toInt(),
      totalRoundTripTime: stats.totalRoundTripTime,
      currentRoundTripTime: stats.currentRoundTripTime,
      availableOutgoingBitrate: stats.availableOutgoingBitrate,
    );
  }

  /// Creates [RtcIceCandidatePairStats] basing on the [Map] received from the
  /// native side.
  static RtcIceCandidatePairStats fromMap(dynamic stats) {
    return RtcIceCandidatePairStats(
      transportId: stats['transportId'],
      localCandidateId: stats['localCandidateId'],
      remoteCandidateId: stats['remoteCandidateId'],
      state: _$RtcStatsIceCandidatePairStateEnumMap.entries
          .firstWhereOrNull((entry) => entry.value == stats['state'])
          ?.key,
      nominated: stats['nominated'],
      priority: parseInt(stats['priority']),
      packetsSent: parseInt(stats['packetsSent']),
      packetsReceived: parseInt(stats['packetsReceived']),
      bytesSent: parseInt(stats['bytesSent']),
      bytesReceived: parseInt(stats['bytesReceived']),
      lastPacketSentTimestamp: stats['lastPacketSentTimestamp'],
      lastPacketReceivedTimestamp: stats['lastPacketReceivedTimestamp'],
      totalRoundTripTime: stats['totalRoundTripTime'],
      currentRoundTripTime: stats['currentRoundTripTime'],
      availableOutgoingBitrate: stats['availableOutgoingBitrate'],
      availableIncomingBitrate: stats['availableIncomingBitrate'],
      requestsReceived: parseInt(stats['requestsReceived']),
      requestsSent: parseInt(stats['requestsSent']),
      responsesReceived: parseInt(stats['responsesReceived']),
      responsesSent: parseInt(stats['responsesSent']),
      consentRequestsSent: parseInt(stats['consentRequestsSent']),
      packetsDiscardedOnSend: parseInt(stats['packetsDiscardedOnSend']),
      bytesDiscardedOnSend: parseInt(stats['bytesDiscardedOnSend']),
    );
  }

  @override
  Map<String, dynamic> toJson() => _$RtcIceCandidatePairStatsToJson(this);

  @override
  RtcStatsType type() => RtcStatsType.candidatePair;

  /// Unique identifier associated to the object that was inspected to produce
  /// the [RtcTransportStats] associated with this candidates pair.
  String? transportId;

  /// Unique identifier associated to the object that was inspected to produce
  /// the [RtcIceCandidateStats] for the local candidate associated with
  /// this candidates pair.
  String? localCandidateId;

  /// Unique identifier associated to the object that was inspected to produce
  /// the [RtcIceCandidateStats] for the remote candidate associated with
  /// this candidates pair.
  String? remoteCandidateId;

  /// State of the checklist for the local and remote candidates in a pair.
  RtcStatsIceCandidatePairState? state;

  /// Related to updating the nominated flag described in
  /// [Section 7.1.3.2.4 of RFC 5245][1].
  ///
  /// [1]: https://tools.ietf.org/html/rfc5245#section-7.1.3.2.4
  bool? nominated;

  /// Priority calculated as defined in [Section 15.1 of RFC 5245][1].
  ///
  /// [1]: https://tools.ietf.org/html/rfc5245#section-15.1
  int? priority;

  /// Total number of packets sent on this candidate pair.
  int? packetsSent;

  /// Total number of packets received on this candidate pair.
  int? packetsReceived;

  /// Total number of payload bytes sent on this candidate pair, i.e. not
  /// including headers, padding or [ICE] connectivity checks.
  ///
  /// [ICE]: https://datatracker.ietf.org/doc/html/rfc8445
  int? bytesSent;

  /// Total number of payload bytes received on this candidate pair, i.e. not
  /// including headers, padding or [ICE] connectivity checks.
  ///
  /// [ICE]: https://datatracker.ietf.org/doc/html/rfc8445
  int? bytesReceived;

  /// Timestamp at which the last packet was sent on this particular candidate
  /// pair, excluding [STUN] packets.
  ///
  /// [STUN]: https://webrtcglossary.com/stun
  double? lastPacketSentTimestamp;

  /// Timestamp at which the last packet was received on this particular
  /// candidate pair, excluding [STUN] packets.
  ///
  /// [STUN]: https://webrtcglossary.com/stun
  double? lastPacketReceivedTimestamp;

  /// Sum of all round trip time measurements in seconds since the beginning
  /// of the session, based on [STUN] connectivity check [STUN-PATH-CHAR]
  /// responses (`responsesReceived`), including those that reply to requests
  /// that are sent in order to verify consent [RFC7675].
  ///
  /// The average round trip time can be computed from
  /// [totalRoundTripTime][1] by dividing it by
  /// [responsesReceived][2].
  ///
  /// [RFC7675]: https://tools.ietf.org/html/rfc7675
  /// [STUN]: https://webrtcglossary.com/stun
  /// [STUN-PATH-CHAR]: https://w3.org/TR/webrtc-stats#bib-stun-path-char
  /// [1]: RtcIceCandidatePairStats.totalRoundTripTime
  /// [2]: RtcIceCandidatePairStats.responsesReceived
  double? totalRoundTripTime;

  /// Latest round trip time measured in seconds, computed from both [STUN]
  /// connectivity checks [STUN-PATH-CHAR], including those that are sent for
  /// consent verification [RFC7675].
  ///
  /// [RFC7675]: https://tools.ietf.org/html/rfc7675
  /// [STUN]: https://webrtcglossary.com/stun
  /// [STUN-PATH-CHAR]: https://w3.org/TR/webrtc-stats#bib-stun-path-char
  double? currentRoundTripTime;

  /// Bitrate calculated by the underlying congestion control by combining the
  /// available bitrate for all the outgoing [RTP stream]s using this
  /// candidate pair.
  ///
  /// The bitrate measurement doesn't count the size of the IP or other
  /// transport layers like TCP or UDP. It's similar to the TIAS defined in
  /// [RFC3890], i.e. it's measured in bits per second and the bitrate is
  /// calculated over a 1-second window. For candidate pairs in use, the
  /// estimate is normally no lower than the bitrate for the packets sent at
  /// [lastPacketSentTimestamp][1], but might be higher.
  ///
  /// [RTP stream]: https://w3.org/TR/webrtc-stats#dfn-rtp-stream
  /// [RFC3890]: https://rfc-editor.org/rfc/rfc3890
  /// [1]: RtcIceCandidatePairStats.lastPacketSentTimestamp
  double? availableOutgoingBitrate;

  /// Bitrate calculated by the underlying congestion control by combining the
  /// available bitrate for all the incoming [RTP stream]s using this
  /// candidate pair.
  ///
  /// The bitrate measurement doesn't count the size of the IP or other
  /// transport layers like TCP or UDP. It's similar to the TIAS defined in
  /// [RFC3890], i.e. it's measured in bits per second and the bitrate is
  /// calculated over a 1-second window. For candidate pairs in use, the
  /// estimate is normally no lower than the bitrate for the packets sent at
  /// [lastPacketReceivedTimestamp][1], but might be higher.
  ///
  /// [RTP stream]: https://w3.org/TR/webrtc-stats#dfn-rtp-stream
  /// [RFC3890]: https://rfc-editor.org/rfc/rfc3890
  /// [1]: RtcIceCandidatePairStats.lastPacketReceivedTimestamp
  double? availableIncomingBitrate;

  /// Total number of connectivity check requests received (including
  /// retransmissions).
  ///
  /// It's impossible for the receiver to tell whether the request was sent in
  /// order to check connectivity or check consent, so all connectivity checks
  /// requests are counted here.
  int? requestsReceived;

  /// Total number of connectivity check requests sent (not including
  /// retransmissions).
  int? requestsSent;

  /// Total number of connectivity check responses received.
  int? responsesReceived;

  /// Total number of connectivity check responses sent.
  ///
  /// Since we cannot distinguish connectivity check requests and consent
  /// requests, all responses are counted.
  int? responsesSent;

  /// Total number of consent requests sent.
  int? consentRequestsSent;

  /// Total number of packets for this candidate pair that have been discarded
  /// due to socket errors, i.e. a socket error occurred when
  /// handing the packets to the socket.
  ///
  /// This might happen due to various reasons, including full buffer or no
  /// available memory.
  int? packetsDiscardedOnSend;

  /// Total number of bytes for this candidate pair that have been discarded
  /// due to socket errors, i.e. a socket error occurred when handing the
  /// packets containing the bytes to the socket.
  ///
  /// This might happen due to various reasons, including full buffer or no
  /// available memory.
  ///
  /// Calculated as defined in [RFC3550 section 6.4.1][1].
  ///
  /// [1]: https://rfc-editor.org/rfc/rfc3550#section-6.4.1
  int? bytesDiscardedOnSend;
}

/// Transport statistics related to the [RTCPeerConnection] object.
///
/// [RTCPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
@JsonSerializable(createFactory: false, includeIfNull: false)
class RtcTransportStats extends RtcStat {
  RtcTransportStats({
    this.packetsSent,
    this.packetsReceived,
    this.bytesSent,
    this.bytesReceived,
    this.iceRole,
    this.iceLocalUsernameFragment,
    this.iceState,
    this.dtlsState,
    this.selectedCandidatePairId,
    this.localCertificateId,
    this.remoteCertificateId,
    this.tlsVersion,
    this.dtlsCipher,
    this.dtlsRole,
    this.srtpCipher,
    this.ccfbMessagesSent,
    this.ccfbMessagesReceived,
    this.selectedCandidatePairChanges,
  });

  /// Creates [RtcIceCandidatePairStats] basing on the
  /// [ffi.RtcStatsType_RtcIceCandidatePairStats] received from the native side.
  static RtcTransportStats fromFFI(ffi.RtcStatsType_RtcTransportStats stats) {
    RtcIceRole? role;
    if (stats.iceRole != null) {
      role = RtcIceRole.values[stats.iceRole!.index];
    }
    return RtcTransportStats(
      packetsSent: stats.packetsSent?.toInt(),
      packetsReceived: stats.packetsReceived?.toInt(),
      bytesSent: stats.bytesSent?.toInt(),
      bytesReceived: stats.bytesReceived?.toInt(),
      iceRole: role,
    );
  }

  /// Creates [RtcTransportStats] basing on the [Map] received from the native
  /// side.
  static RtcTransportStats fromMap(dynamic stats) {
    return RtcTransportStats(
      packetsSent: parseInt(stats['packetsSent']),
      packetsReceived: parseInt(stats['packetsReceived']),
      bytesSent: parseInt(stats['bytesSent']),
      bytesReceived: parseInt(stats['bytesReceived']),
      iceRole: _$RtcIceRoleEnumMap.entries
          .firstWhereOrNull((e) => e.value == stats['iceRole'])
          ?.key,
      iceLocalUsernameFragment: stats['iceLocalUsernameFragment'],
      iceState: _$RtcIceTransportStateEnumMap.entries
          .firstWhereOrNull((e) => e.value == stats['iceState'])
          ?.key,
      dtlsState: _$RtcDtlsTransportStateEnumMap.entries
          .firstWhereOrNull((e) => e.value == stats['dtlsState'])
          ?.key,
      selectedCandidatePairId: stats['selectedCandidatePairId'],
      localCertificateId: stats['localCertificateId'],
      remoteCertificateId: stats['remoteCertificateId'],
      tlsVersion: stats['tlsVersion'],
      dtlsCipher: stats['dtlsCipher'],
      dtlsRole: _$RtcDtlsRoleEnumMap.entries
          .firstWhereOrNull((e) => e.value == stats['dtlsRole'])
          ?.key,
      srtpCipher: stats['srtpCipher'],
      ccfbMessagesSent: parseInt(stats['ccfbMessagesSent']),
      ccfbMessagesReceived: parseInt(stats['ccfbMessagesReceived']),
      selectedCandidatePairChanges: parseInt(
        stats['selectedCandidatePairChanges'],
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => _$RtcTransportStatsToJson(this);

  @override
  RtcStatsType type() => RtcStatsType.transport;

  /// Total number of packets sent over the transport.
  int? packetsSent;

  /// Total number of packets received on the transport.
  int? packetsReceived;

  /// Total number of payload bytes sent on the underlying [RTCIceTransport],
  /// i.e. not including headers, padding or [ICE] connectivity checks.
  ///
  /// [ICE]: https://datatracker.ietf.org/doc/html/rfc8445
  /// [RTCIceTransport]: https://w3.org/TR/webrtc#dom-rtcicetransport
  int? bytesSent;

  /// Total number of payload bytes received on the underlying
  /// [RTCIceTransport], i.e. not including headers, padding or [ICE]
  /// connectivity checks.
  ///
  /// [ICE]: https://datatracker.ietf.org/doc/html/rfc8445
  /// [RTCIceTransport]: https://w3.org/TR/webrtc#dom-rtcicetransport
  int? bytesReceived;

  /// Current value of the [role` attribute][1] of the underlying
  /// [RTCIceTransport].
  ///
  /// [RTCIceTransport]: https://w3.org/TR/webrtc#dom-rtcicetransport
  /// [1]: https://w3.org/TR/webrtc#dom-icetransport-role
  RtcIceRole? iceRole;

  /// Current value of the local username fragment used in message validation
  /// procedures [RFC5245] for the underlying [RTCIceTransport].
  ///
  /// It may be updated on [setLocalDescription()][0] and on [ICE] restart.
  ///
  /// [ICE]: https://datatracker.ietf.org/doc/html/rfc8445
  /// [RFC5245]: https://rfc-editor.org/rfc/rfc5245
  /// [RTCIceTransport]: https://w3.org/TR/webrtc#dom-rtcicetransport
  /// [0]: https://w3.org/TR/webrtc#dom-peerconnection-setlocaldescription
  String? iceLocalUsernameFragment;

  /// Current value of the [state` attribute][1] of the underlying
  /// [RTCIceTransport].
  ///
  /// [RTCIceTransport]: https://w3.org/TR/webrtc#dom-rtcicetransport
  /// [1]: https://w3.org/TR/webrtc#dom-icetransport-state
  RtcIceTransportState? iceState;

  /// Current value of the [state` attribute][1] of the [RTCDtlsTransport].
  ///
  /// [RTCDtlsTransport]: https://w3.org/TR/webrtc#dom-rtcdtlstransport
  /// [1]: https://w3.org/TR/webrtc#dom-rtcdtlstransport-state
  RtcDtlsTransportState? dtlsState;

  /// Unique identifier that is associated to the object that was inspected to
  /// produce the [RtcIceCandidatePairStats] associated with the transport.
  String? selectedCandidatePairId;

  /// Identified of the local certificate for components where [DTLS] is
  /// negotiated.
  ///
  /// [DTLS]: https://webrtcglossary.com/dtls
  String? localCertificateId;

  /// Identified of the remote certificate for components where [DTLS] is
  /// negotiated.
  ///
  /// [DTLS]: https://webrtcglossary.com/dtls
  String? remoteCertificateId;

  /// Agreed [TLS] version for components where [DTLS] is negotiated.
  ///
  /// It's represented as four upper case hexadecimal digits representing the
  /// two bytes of the version.
  ///
  /// Only present after [DTLS] negotiation is complete.
  ///
  /// [DTLS]: https://webrtcglossary.com/dtls
  /// [TLS]: https://webrtcglossary.com/tls
  String? tlsVersion;

  /// Descriptive name of the cipher suite used for the [DTLS] transport, as
  /// defined in the
  /// ["Description" column of the IANA cipher suite registry][0].
  ///
  /// [DTLS]: https://webrtcglossary.com/dtls
  /// [0]: https://w3.org/TR/webrtc-stats#bib-iana-tls-ciphers
  String? dtlsCipher;

  /// [RtcDtlsRole.client] or [RtcDtlsRole.server] depending on the [DTLS] role.
  ///
  /// [RtcDtlsRole.unknown] before the [DTLS] negotiation starts.
  ///
  /// [DTLS]: https://webrtcglossary.com/dtls
  RtcDtlsRole? dtlsRole;

  /// Descriptive name of the protection profile used for the [SRTP]
  /// transport, as defined in the
  /// ["Profile" column of the IANA DTLS-SRTP protection profile registry][0]
  /// and described further in [RFC5764].
  ///
  /// [RFC5764]: https://rfc-editor.org/rfc/rfc5764
  /// [SRTP]: https://webrtcglossary.com/srtp
  /// [0]: https://iana.org/assignments/srtp-protection/srtp-protection.xhtml
  String? srtpCipher;

  /// Number of Transport-Layer Feedback Messages of type
  /// `CongestionControl Feedback Packet`, as described in
  /// [RFC8888 Section 3.1][0], sent on the transport.
  ///
  /// [0]: https://rfc-editor.org/rfc/rfc8888#section-3.1
  int? ccfbMessagesSent;

  /// Number of Transport-Layer Feedback Messages of type
  /// `CongestionControl Feedback Packet`, as described in
  /// [RFC8888 Section 3.1][0], received on the transport.
  ///
  /// [0]: https://rfc-editor.org/rfc/rfc8888#section-3.1
  int? ccfbMessagesReceived;

  /// Number of times that the selected candidate pair of the transport has
  /// changed.
  ///
  /// Going from not having a selected candidate pair to having a selected
  /// candidate pair, or the other way around, also increases this counter.
  /// It is initially zero and becomes one when an initial candidate pair is
  /// selected.
  int? selectedCandidatePairChanges;
}

/// Possible roles in the DTLS handshake for transport.
///
/// [DTLS]: https://webrtcglossary.com/dtls
@JsonEnum(fieldRename: FieldRename.kebab)
enum RtcDtlsRole {
  /// [RTCPeerConnection] is acting as a [DTLS] client as defined in
  /// [RFC6347].
  ///
  /// [DTLS]: https://webrtcglossary.com/dtls
  /// [RTCPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
  /// [RFC6347]: https://rfc-editor.org/rfc/rfc6347
  client,

  /// [RTCPeerConnection] is acting as a [DTLS] server as defined in
  /// [RFC6347].
  ///
  /// [DTLS]: https://webrtcglossary.com/dtls
  /// [RTCPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
  /// [RFC6347]: https://rfc-editor.org/rfc/rfc6347
  server,

  /// [DTLS] role of the [RTCPeerConnection] hasn't been determined yet.
  ///
  /// [DTLS]: https://webrtcglossary.com/dtls
  /// [RTCPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
  unknown,
}

/// Possible states of a [DTLS] transport.
///
/// [DTLS]: https://webrtcglossary.com/dtls
@JsonEnum(fieldRename: FieldRename.kebab)
enum RtcDtlsTransportState {
  /// [DTLS] has not started negotiating yet.
  ///
  /// [DTLS]: https://webrtcglossary.com/dtls
  new_,

  /// [DTLS] is in the process of negotiating a secure connection and
  /// verifying the remote fingerprint.
  ///
  /// [DTLS]: https://webrtcglossary.com/dtls
  connecting,

  /// [DTLS] has completed negotiation of a secure connection and verified the
  /// remote fingerprint.
  ///
  /// [DTLS]: https://webrtcglossary.com/dtls
  connected,

  /// [DTLS] transport has been closed intentionally as the result of receipt
  /// of a `close_notify` alert, or calling [close()].
  ///
  /// [close()]: https://w3.org/TR/webrtc#dom-rtcpeerconnection-close
  /// [DTLS]: https://webrtcglossary.com/dtls
  closed,

  /// [DTLS] transport has failed as the result of an error (such as receipt
  /// of an error alert or failure to validate the remote fingerprint).
  ///
  /// [DTLS]: https://webrtcglossary.com/dtls
  failed,
}

/// Possible states of the underlying [ICE] transport used by a
/// [RTCPeerConnection].
///
/// [ICE]: https://datatracker.ietf.org/doc/html/rfc8445
/// [RTCPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
@JsonEnum(fieldRename: FieldRename.kebab)
enum RtcIceTransportState {
  /// [RTCIceTransport] has shut down and is no longer responding to [STUN]
  /// requests.
  ///
  /// [RTCIceTransport]: https://w3.org/TR/webrtc#dom-rtcicetransport
  /// [STUN]: https://webrtcglossary.com/stun
  closed,

  /// [RTCIceTransport] has finished gathering, received an indication that
  /// there are no more remote candidates, finished checking all candidate
  /// pairs, and all pairs have either failed connectivity checks or lost
  /// consent, and either zero local candidates were gathered or the PAC timer
  /// has expired (see [RFC8863]).
  ///
  /// This is a terminal state until [ICE] is restarted. Since an [ICE]
  /// restart may cause connectivity to resume, entering the [Failed] state
  /// doesn't cause [DTLS] transports, [SCTP] associations or the data
  /// channels that run over them to close, or tracks to mute.
  ///
  /// [Failed]: RtcIceTransportState.Failed
  /// [DTLS]: https://webrtcglossary.com/dtls
  /// [ICE]: https://datatracker.ietf.org/doc/html/rfc8445
  /// [RTCIceTransport]: https://w3.org/TR/webrtc#dom-rtcicetransport
  /// [RFC8863]: https://rfc-editor.org/rfc/rfc8863
  /// [SCTP]: https://webrtcglossary.com/sctp
  failed,

  /// [ICE Agent] has determined that connectivity is currently lost for thw
  /// [RTCIceTransport].
  ///
  /// This is a transient state that may trigger intermittently (and resolve
  /// itself without action) on a flaky network. The way this state is
  /// determined is implementation dependent. Examples include:
  /// - Losing the network interface for the connection in use.
  /// - Repeatedly failing to receive a response to STUN requests.
  ///
  /// Alternatively, the [RTCIceTransport] has finished checking all existing
  /// candidates pairs and not found a connection (or consent checks [RFC7675]
  /// once successful, have now failed), but it is still gathering and/or
  /// waiting for additional remote candidates.
  ///
  /// [ICE Agent]: https://w3.org/TR/webrtc#dfn-ice-agent
  /// [RTCIceTransport]: https://w3.org/TR/webrtc#dom-rtcicetransport
  /// [RFC7675]: https://rfc-editor.org/rfc/rfc7675
  /// [STUN]: https://webrtcglossary.com/stun
  disconnected,

  /// [RTCIceTransport] is gathering candidates and/or waiting for remote
  /// candidates to be supplied, and has not yet started checking.
  ///
  /// [RTCIceTransport]: https://w3.org/TR/webrtc#dom-rtcicetransport
  new_,

  /// [RTCIceTransport] has received at least one remote candidate (by means
  /// of [addIceCandidate()][0] or discovered as a peer-reflexive
  /// candidate when receiving a [STUN] binding request) and is checking
  /// candidate pairs and has either not yet found a connection or consent
  /// checks [RFC7675] have failed on all previously successful candidate
  /// pairs.
  ///
  /// In addition to checking, it may also still be gathering.
  ///
  /// [RTCIceTransport]: https://w3.org/TR/webrtc#dom-rtcicetransport
  /// [RFC7675]: https://rfc-editor.org/rfc/rfc7675
  /// [STUN]: https://webrtcglossary.com/stun
  /// [0]: https://w3.org/TR/webrtc#dom-peerconnection-addicecandidate
  checking,

  /// [RTCIceTransport] has finished gathering, received an indication
  /// that there are no more remote candidates, finished checking all
  /// candidate pairs and found a connection.
  ///
  /// If consent checks [RFC7675] subsequently fail on all successful
  /// candidate pairs, the state transitions to [Failed].
  ///
  /// [Failed]: RtcIceTransportState.Failed
  /// [RTCIceTransport]: https://w3.org/TR/webrtc#dom-rtcicetransport
  /// [RFC7675]: https://rfc-editor.org/rfc/rfc7675
  completed,

  /// [RTCIceTransport] has found a usable connection, but is still checking
  /// other candidate pairs to see if there is a better connection.
  ///
  /// It may also still be gathering and/or waiting for additional remote
  /// candidates. If consent checks [RFC7675] fail on the connection in use,
  /// and there are no other successful candidate pairs available, then the
  /// state transitions to [Checking] (if there are candidate pairs
  /// remaining to be checked) or [Disconnected] (if there are no candidate
  /// pairs to check, but the peer is still gathering and/or waiting for
  /// additional remote candidates).
  ///
  /// [Checking]: RtcIceTransportState.Checking
  /// [Disconnected]: RtcIceTransportState.Disconnected
  /// [RTCIceTransport]: https://w3.org/TR/webrtc#dom-rtcicetransport
  /// [RFC7675]: https://rfc-editor.org/rfc/rfc7675
  connected,
}

/// Statistics for the remote endpoint's inbound [RTP] stream corresponding to
/// an outbound stream that is currently sent with [RTCPeerConnection] object.
///
/// It is measured at the remote endpoint and reported in a RTCP Receiver Report
/// (RR) or RTCP Extended Report (XR).
///
/// [RTP]: https://en.wikipedia.org/wiki/Real-time_Transport_Protocol
/// [RTCPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
@JsonSerializable(createFactory: false, includeIfNull: false)
class RtcRemoteInboundRtpStreamStats extends RtcReceivedRtpStreamStats {
  RtcRemoteInboundRtpStreamStats({
    super.ssrc,
    super.kind,
    super.transportId,
    super.codecId,
    super.packetsReceived,
    super.packetsReceivedWithEct1,
    super.packetsReceivedWithCe,
    super.packetsReportedAsLost,
    super.packetsReportedAsLostButRecovered,
    super.packetsLost,
    super.jitter,
    this.localId,
    this.roundTripTime,
    this.totalRoundTripTime,
    this.fractionLost,
    this.roundTripTimeMeasurements,
    this.packetsWithBleachedEct1Marking,
  });

  /// Creates [RtcRemoteInboundRtpStreamStats] basing on the
  /// [ffi.RtcStatsType_RtcRemoteInboundRtpStreamStats] received from the native
  /// side.
  static RtcRemoteInboundRtpStreamStats fromFFI(
    ffi.RtcStatsType_RtcRemoteInboundRtpStreamStats stats,
  ) {
    return RtcRemoteInboundRtpStreamStats(
      ssrc: stats.ssrc,
      kind: stats.kind,
      jitter: stats.jitter,
      localId: stats.localId,
      roundTripTime: stats.roundTripTime,
      fractionLost: stats.fractionLost,
      roundTripTimeMeasurements: stats.roundTripTimeMeasurements,
    );
  }

  /// Creates [RtcRemoteInboundRtpStreamStats] basing on the [Map] received from
  /// the native side.
  static RtcRemoteInboundRtpStreamStats fromMap(dynamic stats) {
    return RtcRemoteInboundRtpStreamStats(
      ssrc: parseInt(stats['ssrc']),
      kind: stats['kind'],
      transportId: stats['transportId'],
      codecId: stats['codecId'],
      packetsReceived: parseInt(stats['packetsReceived']),
      packetsReceivedWithEct1: parseInt(stats['packetsReceivedWithEct1']),
      packetsReceivedWithCe: parseInt(stats['packetsReceivedWithCe']),
      packetsReportedAsLost: parseInt(stats['packetsReportedAsLost']),
      packetsReportedAsLostButRecovered: parseInt(
        stats['packetsReportedAsLostButRecovered'],
      ),
      packetsLost: parseInt(stats['packetsLost']),
      jitter: stats['jitter'],
      localId: stats['localId'],
      roundTripTime: stats['roundTripTime'],
      totalRoundTripTime: stats['totalRoundTripTime'],
      fractionLost: stats['fractionLost'],
      roundTripTimeMeasurements: parseInt(stats['roundTripTimeMeasurements']),
      packetsWithBleachedEct1Marking: parseInt(
        stats['packetsWithBleachedEct1Marking'],
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => _$RtcRemoteInboundRtpStreamStatsToJson(this);

  @override
  RtcStatsType type() => RtcStatsType.remoteInboundRtp;

  /// Identifier of the local [RtcOutboundRtpStreamStats] object for the
  /// same [SSRC].
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  String? localId;

  /// Estimated round trip time for this [SSRC] based on the [RTCP] timestamps
  /// in the [RTCP Receiver Report][0] (RR) and measured in seconds.
  ///
  /// Calculated as defined in [Section 6.4.1 of RFC3550][1].
  ///
  /// MUST NOT exist until a [RTCP Receiver Report][0] is received with a
  /// DLSR value other than `0` has been received.
  ///
  /// [RTCP]: https://webrtcglossary.com/rtcp
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  /// [0]: https://w3.org/TR/webrtc-stats#dfn-receiver-report
  /// [1]: https://rfc-editor.org/rfc/rfc3550#section-6.4.1
  double? roundTripTime;

  /// Cumulative sum of all round trip time measurements in seconds since the
  /// beginning of the session.
  ///
  /// The individual round trip time is calculated based on the [RTCP]
  /// timestamps in the [RTCP Receiver Report][0] (RR) [RFC3550], hence
  /// requires a DLSR value other than `0`.
  ///
  /// The average round trip time can be computed from the
  /// [totalRoundTripTime][1] by dividing it by
  /// [roundTripTimeMeasurements][2].
  ///
  /// [RFC3550]: https://rfc-editor.org/rfc/rfc3550
  /// [RTCP]: https://webrtcglossary.com/rtcp
  /// [0]: https://w3.org/TR/webrtc-stats#dfn-receiver-report
  /// [1]: RtcRemoteInboundRtpStreamStats.totalRoundTripTime
  /// [2]: RtcRemoteInboundRtpStreamStats.roundTripTimeMeasurements
  double? totalRoundTripTime;

  /// Fraction packet loss reported for this [SSRC].
  ///
  /// Calculated as defined in [RFC3550 Section 6.4.1][1] and
  /// [Appendix A.3][2].
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  /// [1]: https://rfc-editor.org/rfc/rfc3550#section-6.4.1
  /// [2]: https://rfc-editor.org/rfc/rfc3550#appendix-A.3
  double? fractionLost;

  /// Total number of [RTCP RR] blocks received for this [SSRC] that contain a
  /// valid round trip time.
  ///
  /// This counter will not increment if the [roundTripTime][1] can not be
  /// calculated because no [RTCP Receiver Report][0] with a DLSR value other
  /// than `0` has been received.
  ///
  /// [RTCP RR]: https://w3.org/TR/webrtc-stats#dfn-receiver-report
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  /// [0]: https://w3.org/TR/webrtc-stats#dfn-receiver-report
  /// [1]: RtcRemoteInboundRtpStreamStats.roundTripTime
  int? roundTripTimeMeasurements;

  /// Number of packets that were sent with [ECT(1)][2] markings per
  /// [RFC3168 Section 3][1], but where an [RFC8888] report gave information
  /// that the packet was received with a marking of "not-ECT".
  ///
  /// [RFC8888]: https://rfc-editor.org/rfc/rfc8888
  /// [1]: https://rfc-editor.org/rfc/rfc3168#section-3
  /// [2]: https://rfc-editor.org/rfc/rfc3168#section-5
  int? packetsWithBleachedEct1Marking;
}

/// Statistics for the remote endpoint's outbound [RTP] stream corresponding to
/// an inbound stream that is currently received with [RTCPeerConnection]
/// object.
///
/// It is measured at the remote endpoint and reported in an RTCP Sender Report
/// (SR).
///
/// [RTP]: https://en.wikipedia.org/wiki/Real-time_Transport_Protocol
/// [RTCPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
@JsonSerializable(createFactory: false, includeIfNull: false)
class RtcRemoteOutboundRtpStreamStats extends RtcSentRtpStreamStats {
  RtcRemoteOutboundRtpStreamStats({
    super.ssrc,
    super.kind,
    super.transportId,
    super.codecId,
    super.packetsSent,
    super.bytesSent,
    this.localId,
    this.remoteTimestamp,
    this.reportsSent,
    this.roundTripTime,
    this.totalRoundTripTime,
    this.roundTripTimeMeasurements,
  });

  /// Creates [RtcRemoteOutboundRtpStreamStats] basing on the
  /// [ffi.RtcStatsType_RtcRemoteOutboundRtpStreamStats] received from the
  /// native side.
  static RtcRemoteOutboundRtpStreamStats fromFFI(
    ffi.RtcStatsType_RtcRemoteOutboundRtpStreamStats stats,
  ) {
    return RtcRemoteOutboundRtpStreamStats(
      ssrc: stats.ssrc,
      kind: stats.kind,
      localId: stats.localId,
      remoteTimestamp: stats.remoteTimestamp,
      reportsSent: stats.reportsSent?.toInt(),
    );
  }

  /// Creates [RtcRemoteOutboundRtpStreamStats] basing on the [Map] received
  /// from the native side.
  static RtcRemoteOutboundRtpStreamStats fromMap(dynamic stats) {
    return RtcRemoteOutboundRtpStreamStats(
      ssrc: parseInt(stats['ssrc']),
      kind: stats['kind'],
      transportId: stats['transportId'],
      codecId: stats['codecId'],
      packetsSent: parseInt(stats['packetsSent']),
      bytesSent: parseInt(stats['bytesSent']),
      localId: stats['localId'],
      remoteTimestamp: stats['remoteTimestamp'],
      reportsSent: parseInt(stats['reportsSent']),
      roundTripTime: stats['roundTripTime'],
      totalRoundTripTime: stats['totalRoundTripTime'],
      roundTripTimeMeasurements: parseInt(stats['roundTripTimeMeasurements']),
    );
  }

  @override
  Map<String, dynamic> toJson() =>
      _$RtcRemoteOutboundRtpStreamStatsToJson(this);

  @override
  RtcStatsType type() => RtcStatsType.remoteOutboundRtp;

  /// Identifier of the local [RtcInboundRtpStreamStats] object for the same
  /// [SSRC].
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  String? localId;

  /// Remote timestamp at which these statistics were sent by the remote
  /// endpoint.
  ///
  /// This differs from the [RtcStat.timestamp], which represents the time
  /// at which the statistics were generated or received by the local
  /// endpoint.
  ///
  /// The remote timestamp, if present, is derived from the [NTP] timestamp in
  /// an [RTCP Sender Report] (SR) block, which reflects the remote endpoint's
  /// clock. That clock may not be synchronized with the local clock.
  ///
  /// [NTP]: https://en.wikipedia.org/wiki/Network_Time_Protocol
  /// [RTCP Sender Report]: https://w3.org/TR/webrtc-stats#dfn-sender-report
  double? remoteTimestamp;

  /// Total number of [RTCP Sender Report] (SR) blocks sent for this [SSRC].
  ///
  /// [RTCP Sender Report]: https://w3.org/TR/webrtc-stats#dfn-sender-report
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  int? reportsSent;

  /// Estimated round trip time for this [SSRC] based on the latest
  /// [RTCP Sender Report] (SR) that contains a [DLRR report block][1] as
  /// defined in [RFC3611].
  ///
  /// The calculation of the round trip time is defined in
  /// [Section 4.5 of RFC3611][1].
  ///
  /// MUST NOT exist if the latest SR does not contain the
  /// [DLRR report block][1], or if the last RR timestamp in the
  /// [DLRR report block][1] is zero, or if the delay since last RR value in
  /// the [DLRR report block][1] is zero.
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  /// [RFC3611]: https://rfc-editor.org/rfc/rfc3611
  /// [RTCP Sender Report]: https://w3.org/TR/webrtc-stats#dfn-sender-report
  /// [1]: https://www.rfc-editor.org/rfc/rfc3611#section-4.5
  double? roundTripTime;

  /// Cumulative sum of all round trip time measurements in seconds since the
  /// beginning of the session.
  ///
  /// The individual round trip time is calculated based on the
  /// [DLRR report block][1] in the [RTCP Sender Report] (SR) [RFC3611].
  ///
  /// This counter will not increment if the [roundTripTime][2] can not be
  /// calculated. The average round trip time can be computed from the
  /// [totalRoundTripTime][3] by dividing it by
  /// [roundTripTimeMeasurements][4].
  ///
  /// [RFC3611]: https://rfc-editor.org/rfc/rfc3611
  /// [RTCP Sender Report]: https://w3.org/TR/webrtc-stats#dfn-sender-report
  /// [1]: https://www.rfc-editor.org/rfc/rfc3611#section-4.5
  /// [2]: RtcRemoteOutboundRtpStreamStats.roundTripTime
  /// [3]: RtcRemoteOutboundRtpStreamStats.totalRoundTripTime
  /// [4]: RtcRemoteOutboundRtpStreamStats.roundTripTimeMeasurements
  double? totalRoundTripTime;

  /// Total number of [RTCP Sender Report] (SR) blocks received for this
  /// [SSRC] that contain a [DLRR report block][1] that can derive a valid
  /// round trip time according to [RFC3611].
  ///
  /// This counter will not increment if the [roundTripTime][2] can not be
  /// calculated.
  ///
  /// [RFC3611]: https://rfc-editor.org/rfc/rfc3611
  /// [RTCP Sender Report]: https://w3.org/TR/webrtc-stats#dfn-sender-report
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  /// [1]: https://www.rfc-editor.org/rfc/rfc3611#section-4.5
  /// [2]: RtcRemoteOutboundRtpStreamStats.roundTripTime
  int? roundTripTimeMeasurements;
}

/// Tries to parse the provided [value] as [int].
///
/// If the provided [value] is a [String] then parses it as hexadecimal.
int? parseInt(dynamic value) {
  switch (value.runtimeType) {
    case const (int):
      {
        return value;
      }
    case const (String):
      {
        return int.tryParse(value, radix: 16);
      }
    default:
      {
        return null;
      }
  }
}

/// Tries to parse the provided [value] as `Map<String, double>`.
Map<String, double>? parseMapStringDouble(dynamic input) {
  if (input is! Map) return null;

  final result = <String, double>{};

  for (final entry in input.entries) {
    final key = entry.key;
    final value = entry.value;

    if (key is! String) return null;

    double? numValue;
    if (value is double) {
      numValue = value;
    } else if (value is int) {
      numValue = value.toDouble();
    } else if (value is String) {
      numValue = double.tryParse(value);
      if (numValue == null) return null;
    } else {
      return null;
    }

    result[key] = numValue;
  }

  return result;
}
