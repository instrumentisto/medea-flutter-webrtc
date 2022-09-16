import '../api/bridge.g.dart' as bridge;

class RTCStats {
  RTCStats(
    this.id,
    this.timestampUs,
    this.type,
  );
  static RTCStats fromFFI(bridge.RTCStats stats) {
    return RTCStats(
      stats.id,
      stats.timestampUs,
      RTCStatsType.fromFFI(stats.kind),
    );
  }

  String id;
  int timestampUs;
  RTCStatsType type;
}

enum RTCStatsIceCandidatePairState {
  frozen,
  waiting,
  inProgress,
  failed,
  succeeded,
}

enum TrackKind {
  audio,
  video,
}

enum CandidateType {
  host,
  srflx,
  prflx,
  relay,
}

abstract class RTCStatsType {
  RTCStatsType();
  static RTCStatsType fromFFI(bridge.RTCStatsType stats) {
    var type = stats.runtimeType.toString();
    switch (type) {
      case '_\$RTCStatsType_RTCMediaSourceStats':
        {
          var source = (stats as bridge.RTCStatsType_RTCMediaSourceStats);
          if (source.kind
              is bridge.RTCMediaSourceStatsType_RTCAudioSourceStats) {
            return RTCAudioSourceStats.fromFFI(
                stats.kind
                    as bridge.RTCMediaSourceStatsType_RTCAudioSourceStats,
                stats.trackIdentifier);
          } else {
            return RTCVideoSourceStats.fromFFI(
                stats.kind
                    as bridge.RTCMediaSourceStatsType_RTCVideoSourceStats,
                stats.trackIdentifier);
          }
        }

      case '_\$RTCStatsType_RTCIceCandidateStats':
        {
          return RTCIceCandidateStats.fromFFI(
              stats as bridge.RTCStatsType_RTCIceCandidateStats);
        }

      case '_\$RTCStatsType_RTCOutboundRTPStreamStats':
        {
          return RTCOutboundRTPStreamStats.fromFFI(
              stats as bridge.RTCStatsType_RTCOutboundRTPStreamStats);
        }

      case '_\$RTCStatsType_RTCInboundRTPStreamStats':
        {
          return RTCInboundRTPStreamStats.fromFFI(
              stats as bridge.RTCStatsType_RTCInboundRTPStreamStats);
        }
      case '_\$RTCStatsType_RTCTransportStats':
        {
          return RTCTransportStats.fromFFI(
              stats as bridge.RTCStatsType_RTCTransportStats);
        }
      case '_\$RTCStatsType_RTCRemoteInboundRtpStreamStats':
        {
          return RTCRemoteInboundRtpStreamStats.fromFFI(
              stats as bridge.RTCStatsType_RTCRemoteInboundRtpStreamStats);
        }
      case '_\$RTCStatsType_RTCRemoteOutboundRtpStreamStats':
        {
          return RTCRemoteOutboundRtpStreamStats.fromFFI(
              stats as bridge.RTCStatsType_RTCRemoteOutboundRtpStreamStats);
        }
      case '_\$RTCStatsType_RTCIceCandidatePairStats':
        {
          return RTCIceCandidatePairStats.fromFFI(
              stats as bridge.RTCStatsType_RTCIceCandidatePairStats);
        }
      default:
        {
          return UnimplenentedStats();
        }
    }
  }
}

class RTCMediaSourceStats extends RTCStatsType {
  RTCMediaSourceStats(this.trackIdentifier);
  String? trackIdentifier;
}

class RTCAudioSourceStats extends RTCMediaSourceStats {
  RTCAudioSourceStats(
      this.audioLevel,
      this.totalAudioEnergy,
      this.totalSamplesDuration,
      this.echoReturnLoss,
      this.echoReturnLossEnhancement,
      String? trackIdentifier)
      : super(trackIdentifier);

  static RTCAudioSourceStats fromFFI(
      bridge.RTCMediaSourceStatsType_RTCAudioSourceStats stats,
      String? trackIdentifier) {
    return RTCAudioSourceStats(
      stats.audioLevel,
      stats.totalAudioEnergy,
      stats.totalSamplesDuration,
      stats.echoReturnLoss,
      stats.echoReturnLossEnhancement,
      trackIdentifier,
    );
  }

  double? audioLevel;
  double? totalAudioEnergy;
  double? totalSamplesDuration;
  double? echoReturnLoss;
  double? echoReturnLossEnhancement;
}

class RTCVideoSourceStats extends RTCMediaSourceStats {
  RTCVideoSourceStats(this.width, this.height, this.frames,
      this.framesPerSecond, String? trackIdentifier)
      : super(trackIdentifier);

  static RTCVideoSourceStats fromFFI(
      bridge.RTCMediaSourceStatsType_RTCVideoSourceStats stats,
      String? trackIdentifier) {
    return RTCVideoSourceStats(stats.width, stats.height, stats.frames,
        stats.framesPerSecond, trackIdentifier);
  }

  int? width;
  int? height;
  int? frames;
  double? framesPerSecond;
}

abstract class RTCIceCandidateStats extends RTCStatsType {
  RTCIceCandidateStats(this.transportId, this.address, this.port, this.protocol,
      this.candidateType, this.priority, this.url);

  static RTCIceCandidateStats fromFFI(
      bridge.RTCStatsType_RTCIceCandidateStats stats) {
    if (stats.field0 is bridge.RTCIceCandidateStats_RTCLocalIceCandidateStats) {
      var local =
          stats.field0 as bridge.RTCIceCandidateStats_RTCLocalIceCandidateStats;
      return RTCLocalIceCandidateStats(
          local.field0.transportId,
          local.field0.address,
          local.field0.port,
          local.field0.protocol,
          CandidateType.values[local.field0.candidateType.index],
          local.field0.priority,
          local.field0.url);
    } else {
      var remote = stats.field0
          as bridge.RTCIceCandidateStats_RTCRemoteIceCandidateStats;
      return RTCRemoteIceCandidateStats(
          remote.field0.transportId,
          remote.field0.address,
          remote.field0.port,
          remote.field0.protocol,
          CandidateType.values[remote.field0.candidateType.index],
          remote.field0.priority,
          remote.field0.url);
    }
  }

  String? transportId;
  String? address;
  int? port;
  String? protocol;
  CandidateType candidateType;
  int? priority;
  String? url;
}

class RTCLocalIceCandidateStats extends RTCIceCandidateStats {
  RTCLocalIceCandidateStats(
    String? transportId,
    String? address,
    int? port,
    String? protocol,
    CandidateType candidateType,
    int? priority,
    String? url,
  ) : super(transportId, address, port, protocol, candidateType, priority, url);
}

class RTCRemoteIceCandidateStats extends RTCIceCandidateStats {
  RTCRemoteIceCandidateStats(
    String? transportId,
    String? address,
    int? port,
    String? protocol,
    CandidateType candidateType,
    int? priority,
    String? url,
  ) : super(transportId, address, port, protocol, candidateType, priority, url);
}

class RTCOutboundRTPStreamStats extends RTCStatsType {
  RTCOutboundRTPStreamStats(
    this.trackId,
    this.kind,
    this.frameWidth,
    this.frameHeight,
    this.framesPerSecond,
    this.bytesSent,
    this.packetsSent,
    this.mediaSourceId,
  );

  static RTCOutboundRTPStreamStats fromFFI(
      bridge.RTCStatsType_RTCOutboundRTPStreamStats stats) {
    return RTCOutboundRTPStreamStats(
      stats.trackId,
      TrackKind.values[stats.kind.index],
      stats.frameWidth,
      stats.frameHeight,
      stats.framesPerSecond,
      stats.bytesSent,
      stats.packetsSent,
      stats.mediaSourceId,
    );
  }

  String? trackId;
  late TrackKind kind;
  int? frameWidth;
  int? frameHeight;
  double? framesPerSecond;
  int? bytesSent;
  int? packetsSent;
  String? mediaSourceId;
}

abstract class RTCInboundRTPStreamMediaType {}

class RTCInboundRTPStreamAudio extends RTCInboundRTPStreamMediaType {
  RTCInboundRTPStreamAudio(
    this.totalSamplesReceived,
    this.concealedSamples,
    this.silentConcealedSamples,
    this.audioLevel,
    this.totalAudioEnergy,
    this.totalSamplesDuration,
  );

  int? totalSamplesReceived;
  int? concealedSamples;
  int? silentConcealedSamples;
  double? audioLevel;
  double? totalAudioEnergy;
  double? totalSamplesDuration;
}

class RTCInboundRTPStreamVideo extends RTCInboundRTPStreamMediaType {
  RTCInboundRTPStreamVideo(
    this.framesDecoded,
    this.keyFramesDecoded,
    this.frameWidth,
    this.frameHeight,
    this.totalInterFrameDelay,
    this.framesPerSecond,
    this.frameBitDepth,
    this.firCount,
    this.pliCount,
    this.concealmentEvents,
    this.framesReceived,
  );

  int? framesDecoded;
  int? keyFramesDecoded;
  int? frameWidth;
  int? frameHeight;
  double? totalInterFrameDelay;
  double? framesPerSecond;
  int? frameBitDepth;
  int? firCount;
  int? pliCount;
  int? concealmentEvents;
  int? framesReceived;
}

class RTCInboundRTPStreamStats extends RTCStatsType {
  RTCInboundRTPStreamStats(
    this.remoteId,
    this.bytesReceived,
    this.packetsReceived,
    this.totalDecodeTime,
    this.jitterBufferEmittedCount,
    this.mediaType,
  );

  static RTCInboundRTPStreamStats fromFFI(
      bridge.RTCStatsType_RTCInboundRTPStreamStats stats) {
    RTCInboundRTPStreamMediaType? mediaType;
    var type = stats.mediaType.runtimeType.toString();
    if (type == '_\$RTCInboundRtpStreamMediaType_Audio') {
      var cast = stats.mediaType as bridge.RTCInboundRtpStreamMediaType_Audio;
      mediaType = RTCInboundRTPStreamAudio(
        cast.totalSamplesReceived,
        cast.concealedSamples,
        cast.silentConcealedSamples,
        cast.audioLevel,
        cast.totalAudioEnergy,
        cast.totalSamplesDuration,
      );
    } else if (type == '_\$RTCInboundRtpStreamMediaType_Video') {
      var cast = stats.mediaType as bridge.RTCInboundRtpStreamMediaType_Video;
      mediaType = RTCInboundRTPStreamVideo(
        cast.framesDecoded,
        cast.keyFramesDecoded,
        cast.frameWidth,
        cast.frameHeight,
        cast.totalInterFrameDelay,
        cast.framesPerSecond,
        cast.frameBitDepth,
        cast.firCount,
        cast.pliCount,
        cast.concealmentEvents,
        cast.framesReceived,
      );
    }
    return RTCInboundRTPStreamStats(
        stats.remoteId,
        stats.bytesReceived,
        stats.packetsReceived,
        stats.totalDecodeTime,
        stats.jitterBufferEmittedCount,
        mediaType);
  }

  String? remoteId;
  int? bytesReceived;
  int? packetsReceived;
  double? totalDecodeTime;
  int? jitterBufferEmittedCount;
  RTCInboundRTPStreamMediaType? mediaType;
}

class RTCIceCandidatePairStats extends RTCStatsType {
  RTCIceCandidatePairStats(
    this.state,
    this.nominated,
    this.bytesSent,
    this.bytesReceived,
    this.totalRoundTripTime,
    this.currentRoundTripTime,
    this.availableOutgoingBitrate,
  );

  static RTCIceCandidatePairStats fromFFI(
      bridge.RTCStatsType_RTCIceCandidatePairStats stats) {
    return RTCIceCandidatePairStats(
      RTCStatsIceCandidatePairState.values[stats.state.index],
      stats.nominated,
      stats.bytesSent,
      stats.bytesReceived,
      stats.totalRoundTripTime,
      stats.currentRoundTripTime,
      stats.availableOutgoingBitrate,
    );
  }

  late RTCStatsIceCandidatePairState state;
  bool? nominated;
  int? bytesSent;
  int? bytesReceived;
  double? totalRoundTripTime;
  double? currentRoundTripTime;
  double? availableOutgoingBitrate;
}

class RTCTransportStats extends RTCStatsType {
  RTCTransportStats(
    this.packetsSent,
    this.packetsReceived,
    this.bytesSent,
    this.bytesReceived,
  );

  static RTCTransportStats fromFFI(
      bridge.RTCStatsType_RTCTransportStats stats) {
    return RTCTransportStats(
      stats.packetsSent,
      stats.packetsReceived,
      stats.bytesSent,
      stats.bytesReceived,
    );
  }

  int? packetsSent;
  int? packetsReceived;
  int? bytesSent;
  int? bytesReceived;
}

class RTCRemoteInboundRtpStreamStats extends RTCStatsType {
  RTCRemoteInboundRtpStreamStats(
    this.localId,
    this.roundTripTime,
    this.fractionLost,
    this.roundTripTimeMeasurements,
  );

  static RTCRemoteInboundRtpStreamStats fromFFI(
      bridge.RTCStatsType_RTCRemoteInboundRtpStreamStats stats) {
    return RTCRemoteInboundRtpStreamStats(
      stats.localId,
      stats.roundTripTime,
      stats.fractionLost,
      stats.roundTripTimeMeasurements,
    );
  }

  String? localId;
  double? roundTripTime;
  double? fractionLost;
  int? roundTripTimeMeasurements;
}

class RTCRemoteOutboundRtpStreamStats extends RTCStatsType {
  RTCRemoteOutboundRtpStreamStats(
    this.localId,
    this.remoteTimestamp,
    this.reportsSent,
  );

  static RTCRemoteOutboundRtpStreamStats fromFFI(
      bridge.RTCStatsType_RTCRemoteOutboundRtpStreamStats stats) {
    return RTCRemoteOutboundRtpStreamStats(
      stats.localId,
      stats.remoteTimestamp,
      stats.reportsSent,
    );
  }

  String? localId;
  double? remoteTimestamp;
  int? reportsSent;
}

class UnimplenentedStats extends RTCStatsType {}
