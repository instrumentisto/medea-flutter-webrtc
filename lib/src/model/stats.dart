import '../api/bridge.g.dart' as bridge;

enum RTCStatsIceCandidatePairState {
  Frozen,
  Waiting,
  InProgress,
  Failed,
  Succeeded,
}

enum TrackKind {
  Audio,
  Video,
}

enum CandidateType {
  Host,
  Srflx,
  Prflx,
  Relay,
}

abstract class RTCStatsType {
  RTCStatsType();
  static RTCStatsType? ffiFactory(bridge.RTCStatsType stats) {
    var type = stats.runtimeType.toString();
    switch (type) {
      case '_\$RTCStatsType_RTCMediaSourceStats':
        {
          var source = (stats as bridge.RTCStatsType_RTCMediaSourceStats);
          if (source.kind
              is bridge.RTCMediaSourceStatsType_RTCAudioSourceStats) {
            return RTCAudioSourceStats.ffiFactory(stats.kind
                as bridge.RTCMediaSourceStatsType_RTCAudioSourceStats);
          } else {
            return RTCVideoSourceStats.ffiFactory(stats.kind
                as bridge.RTCMediaSourceStatsType_RTCVideoSourceStats);
          }
        }

      case '_\$RTCStatsType_RTCIceCandidateStats':
        {
          return RTCIceCandidateStats.ffiFactory(
              stats as bridge.RTCStatsType_RTCIceCandidateStats);
        }

      case '_\$RTCStatsType_RTCOutboundRTPStreamStats':
        {
          return RTCOutboundRTPStreamStats.ffiFactory(
              stats as bridge.RTCStatsType_RTCOutboundRTPStreamStats);
        }

      case '_\$RTCStatsType_RTCInboundRTPStreamStats':
        {
          return RTCInboundRTPStreamStats.ffiFactory(
              stats as bridge.RTCStatsType_RTCInboundRTPStreamStats);
        }
      case '_\$RTCStatsType_RTCTransportStats':
        {
          return RTCTransportStats.ffiFactory(
              stats as bridge.RTCStatsType_RTCTransportStats);
        }
      case '_\$RTCStatsType_RTCRemoteInboundRtpStreamStats':
        {
          return RTCRemoteInboundRtpStreamStats.ffiFactory(
              stats as bridge.RTCStatsType_RTCRemoteInboundRtpStreamStats);
        }
      case '_\$RTCStatsType_RTCRemoteOutboundRtpStreamStats':
        {
          return RTCRemoteOutboundRtpStreamStats.ffiFactory(
              stats as bridge.RTCStatsType_RTCRemoteOutboundRtpStreamStats);
        }
      case '_\$RTCStatsType_RTCIceCandidatePairStats':
        {
          return RTCIceCandidatePairStats.ffiFactory(
              stats as bridge.RTCStatsType_RTCIceCandidatePairStats);
        }
      default:
        {
          return UnimplenentedStats();
        }
    }
  }
}

class RTCMediaSourceStats extends RTCStatsType {}

class RTCAudioSourceStats extends RTCMediaSourceStats {
  RTCAudioSourceStats(
    this.audioLevel,
    this.totalAudioEnergy,
    this.totalSamplesDuration,
    this.echoReturnLoss,
    this.echoReturnLossEnhancement,
  );

  RTCAudioSourceStats.ffiFactory(
      bridge.RTCMediaSourceStatsType_RTCAudioSourceStats stats) {
    RTCAudioSourceStats(
      stats.audioLevel,
      stats.totalAudioEnergy,
      stats.totalSamplesDuration,
      stats.echoReturnLoss,
      stats.echoReturnLossEnhancement,
    );
  }

  RTCAudioSourceStats.channelFactory(dynamic stats) {
    RTCAudioSourceStats(
      stats['audioLevel'],
      stats['totalAudioEnergy'],
      stats['totalSamplesDuration'],
      stats['echoReturnLoss'],
      stats['echoReturnLossEnhancement'],
    );
  }

  double? audioLevel;
  double? totalAudioEnergy;
  double? totalSamplesDuration;
  double? echoReturnLoss;
  double? echoReturnLossEnhancement;
}

class RTCVideoSourceStats extends RTCMediaSourceStats {
  RTCVideoSourceStats(
    this.width,
    this.height,
    this.frames,
    this.framesPerSecond,
  );

  RTCVideoSourceStats.ffiFactory(
      bridge.RTCMediaSourceStatsType_RTCVideoSourceStats stats) {
    RTCVideoSourceStats(
      stats.width,
      stats.height,
      stats.frames,
      stats.framesPerSecond,
    );
  }

  RTCVideoSourceStats.channelFactory(dynamic stats) {
    RTCVideoSourceStats(
      stats['width'],
      stats['height'],
      stats['frames'],
      stats['framesPerSecond'],
    );
  }

  int? width;
  int? height;
  int? frames;
  double? framesPerSecond;
}

class RTCIceCandidateStats extends RTCStatsType {
  RTCIceCandidateStats(
    this.transportId,
    this.address,
    this.port,
    this.protocol,
    this.candidateType,
    this.priority,
    this.url,
  );

  RTCIceCandidateStats.ffiFactory(
      bridge.RTCStatsType_RTCIceCandidateStats stats) {
    RTCIceCandidateStats(
      stats.transportId,
      stats.address,
      stats.port,
      stats.protocol,
      CandidateType.values[stats.candidateType.index],
      stats.priority,
      stats.url,
    );
  }

  RTCIceCandidateStats.channelFactory(dynamic stats) {
    RTCIceCandidateStats(
      stats['transportId'],
      stats['address'],
      stats['port'],
      stats['protocol'],
      CandidateType.values[stats['candidateType']],
      stats['priority'],
      stats['url'],
    );
  }

  String? transportId;
  String? address;
  int? port;
  String? protocol;
  late CandidateType candidateType;
  int? priority;
  String? url;
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

  RTCOutboundRTPStreamStats.ffiFactory(
      bridge.RTCStatsType_RTCOutboundRTPStreamStats stats) {
    RTCOutboundRTPStreamStats(
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

  RTCOutboundRTPStreamStats.channelFactory(dynamic stats) {
    RTCOutboundRTPStreamStats(
      stats['trackId'],
      TrackKind.values[stats['kind']],
      stats['frameWidth'],
      stats['frameHeight'],
      stats['framesPerSecond'],
      stats['bytesSent'],
      stats['packetsSent'],
      stats['mediaSourceId'],
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

class RTCInboundRTPStreamStats extends RTCStatsType {
  RTCInboundRTPStreamStats(
    this.remoteId,
    this.bytesReceived,
    this.packetsReceived,
    this.totalDecodeTime,
    this.jitterBufferEmittedCount,
    this.totalSamplesReceived,
    this.concealedSamples,
    this.silentConcealedSamples,
    this.audioLevel,
    this.totalAudioEnergy,
    this.totalSamplesDuration,
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

  RTCInboundRTPStreamStats.ffiFactory(
      bridge.RTCStatsType_RTCInboundRTPStreamStats stats) {
    RTCInboundRTPStreamStats(
      stats.remoteId,
      stats.bytesReceived,
      stats.packetsReceived,
      stats.totalDecodeTime,
      stats.jitterBufferEmittedCount,
      stats.totalSamplesReceived,
      stats.concealedSamples,
      stats.silentConcealedSamples,
      stats.audioLevel,
      stats.totalAudioEnergy,
      stats.totalSamplesDuration,
      stats.framesDecoded,
      stats.keyFramesDecoded,
      stats.frameWidth,
      stats.frameHeight,
      stats.totalInterFrameDelay,
      stats.framesPerSecond,
      stats.frameBitDepth,
      stats.firCount,
      stats.pliCount,
      stats.concealmentEvents,
      stats.framesReceived,
    );
  }

  RTCInboundRTPStreamStats.channelFactory(dynamic stats) {
    RTCInboundRTPStreamStats(
      stats['remoteId'],
      stats['bytesReceived'],
      stats['packetsReceived'],
      stats['totalDecodeTime'],
      stats['jitterBufferEmittedCount'],
      stats['totalSamplesReceived'],
      stats['concealedSamples'],
      stats['silentConcealedSamples'],
      stats['audioLevel'],
      stats['totalAudioEnergy'],
      stats['totalSamplesDuration'],
      stats['framesDecoded'],
      stats['keyFramesDecoded'],
      stats['frameWidth'],
      stats['frameHeight'],
      stats['totalInterFrameDelay'],
      stats['framesPerSecond'],
      stats['frameBitDepth'],
      stats['firCount'],
      stats['pliCount'],
      stats['concealmentEvents'],
      stats['framesReceived'],
    );
  }

  String? remoteId;
  int? bytesReceived;
  int? packetsReceived;
  double? totalDecodeTime;
  int? jitterBufferEmittedCount;
  int? totalSamplesReceived;
  int? concealedSamples;
  int? silentConcealedSamples;
  double? audioLevel;
  double? totalAudioEnergy;
  double? totalSamplesDuration;
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

  RTCIceCandidatePairStats.ffiFactory(
      bridge.RTCStatsType_RTCIceCandidatePairStats stats) {
    RTCIceCandidatePairStats(
      RTCStatsIceCandidatePairState.values[stats.state.index],
      stats.nominated,
      stats.bytesSent,
      stats.bytesReceived,
      stats.totalRoundTripTime,
      stats.currentRoundTripTime,
      stats.availableOutgoingBitrate,
    );
  }

  RTCIceCandidatePairStats.channelFactory(dynamic stats) {
    RTCIceCandidatePairStats(
      RTCStatsIceCandidatePairState.values[stats['state']],
      stats['nominated'],
      stats['bytesSent'],
      stats['bytesReceived'],
      stats['totalRoundTripTime'],
      stats['currentRoundTripTime'],
      stats['availableOutgoingBitrate'],
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

  RTCTransportStats.ffiFactory(bridge.RTCStatsType_RTCTransportStats stats) {
    RTCTransportStats(
      stats.packetsSent,
      stats.packetsReceived,
      stats.bytesSent,
      stats.bytesReceived,
    );
  }

  RTCTransportStats.channelFactory(dynamic stats) {
    RTCTransportStats(
      stats['packetsSent'],
      stats['packetsReceived'],
      stats['bytesSent'],
      stats['bytesReceived'],
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

  RTCRemoteInboundRtpStreamStats.ffiFactory(
      bridge.RTCStatsType_RTCRemoteInboundRtpStreamStats stats) {
    RTCRemoteInboundRtpStreamStats(
      stats.localId,
      stats.roundTripTime,
      stats.fractionLost,
      stats.roundTripTimeMeasurements,
    );
  }

  RTCRemoteInboundRtpStreamStats.channelFactory(dynamic stats) {
    RTCRemoteInboundRtpStreamStats(
      stats['localId'],
      stats['roundTripTime'],
      stats['fractionLost'],
      stats['roundTripTimeMeasurements'],
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

  RTCRemoteOutboundRtpStreamStats.ffiFactory(
      bridge.RTCStatsType_RTCRemoteOutboundRtpStreamStats stats) {
    RTCRemoteOutboundRtpStreamStats(
      stats.localId,
      stats.remoteTimestamp,
      stats.reportsSent,
    );
  }

  RTCRemoteOutboundRtpStreamStats.channelFactory(dynamic stats) {
    RTCRemoteOutboundRtpStreamStats(
      stats['localId'],
      stats['remoteTimestamp'],
      stats['reportsSent'],
    );
  }

  String? localId;
  double? remoteTimestamp;
  int? reportsSent;
}

class UnimplenentedStats extends RTCStatsType {}
