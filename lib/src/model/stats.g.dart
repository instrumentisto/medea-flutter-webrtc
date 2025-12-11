// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$RtcStatsToJson(RtcStats instance) => <String, dynamic>{
  'id': instance.id,
  'timestamp': instance.timestamp,
  'type': _$RtcStatsTypeEnumMap[instance.type]!,
};

const _$RtcStatsTypeEnumMap = {
  RtcStatsType.codec: 'codec',
  RtcStatsType.inboundRtp: 'inbound-rtp',
  RtcStatsType.outboundRtp: 'outbound-rtp',
  RtcStatsType.remoteInboundRtp: 'remote-inbound-rtp',
  RtcStatsType.remoteOutboundRtp: 'remote-outbound-rtp',
  RtcStatsType.mediaSource: 'media-source',
  RtcStatsType.mediaPlayout: 'media-playout',
  RtcStatsType.peerConnection: 'peer-connection',
  RtcStatsType.dataChannel: 'data-channel',
  RtcStatsType.transport: 'transport',
  RtcStatsType.candidatePair: 'candidate-pair',
  RtcStatsType.localCandidate: 'local-candidate',
  RtcStatsType.remoteCandidate: 'remote-candidate',
  RtcStatsType.certificate: 'certificate',
};

Map<String, dynamic> _$RtcSentRtpStreamStatsToJson(
  RtcSentRtpStreamStats instance,
) => <String, dynamic>{
  'ssrc': ?instance.ssrc,
  'kind': ?instance.kind,
  'transportId': ?instance.transportId,
  'codecId': ?instance.codecId,
  'packetsSent': ?instance.packetsSent,
  'bytesSent': ?instance.bytesSent,
};

Map<String, dynamic> _$RtcAudioSourceStatsToJson(
  RtcAudioSourceStats instance,
) => <String, dynamic>{
  'kind': ?instance.kind,
  'trackIdentifier': ?instance.trackIdentifier,
  'audioLevel': ?instance.audioLevel,
  'totalAudioEnergy': ?instance.totalAudioEnergy,
  'totalSamplesDuration': ?instance.totalSamplesDuration,
  'echoReturnLoss': ?instance.echoReturnLoss,
  'echoReturnLossEnhancement': ?instance.echoReturnLossEnhancement,
};

Map<String, dynamic> _$RtcVideoSourceStatsToJson(
  RtcVideoSourceStats instance,
) => <String, dynamic>{
  'kind': ?instance.kind,
  'trackIdentifier': ?instance.trackIdentifier,
  'width': ?instance.width,
  'height': ?instance.height,
  'frames': ?instance.frames,
  'framesPerSecond': ?instance.framesPerSecond,
};

Map<String, dynamic> _$RtcAudioPlayoutStatsToJson(
  RtcAudioPlayoutStats instance,
) => <String, dynamic>{
  'kind': ?instance.kind,
  'synthesizedSamplesDuration': ?instance.synthesizedSamplesDuration,
  'synthesizedSamplesEvents': ?instance.synthesizedSamplesEvents,
  'totalSamplesDuration': ?instance.totalSamplesDuration,
  'totalPlayoutDelay': ?instance.totalPlayoutDelay,
  'totalSamplesCount': ?instance.totalSamplesCount,
};

Map<String, dynamic> _$RtcPeerConnectionStatsToJson(
  RtcPeerConnectionStats instance,
) => <String, dynamic>{
  'dataChannelsOpened': ?instance.dataChannelsOpened,
  'dataChannelsClosed': ?instance.dataChannelsClosed,
};

Map<String, dynamic> _$RtcDataChannelStatsToJson(
  RtcDataChannelStats instance,
) => <String, dynamic>{
  'label': ?instance.label,
  'protocol': ?instance.protocol,
  'dataChannelIdentifier': ?instance.dataChannelIdentifier,
  'state': ?_$RtcDataChannelStateEnumMap[instance.state],
  'messagesSent': ?instance.messagesSent,
  'bytesSent': ?instance.bytesSent,
  'messagesReceived': ?instance.messagesReceived,
  'bytesReceived': ?instance.bytesReceived,
};

const _$RtcDataChannelStateEnumMap = {
  RtcDataChannelState.connecting: 'connecting',
  RtcDataChannelState.open: 'open',
  RtcDataChannelState.closing: 'closing',
  RtcDataChannelState.closed: 'closed',
};

Map<String, dynamic> _$RtcLocalIceCandidateStatsToJson(
  RtcLocalIceCandidateStats instance,
) => <String, dynamic>{
  'transportId': ?instance.transportId,
  'address': ?instance.address,
  'port': ?instance.port,
  'protocol': ?instance.protocol,
  'candidateType': ?_$RtcIceCandidateTypeEnumMap[instance.candidateType],
  'priority': ?instance.priority,
  'url': ?instance.url,
  'relayProtocol': ?_$IceServerTransportProtocolEnumMap[instance.relayProtocol],
  'foundation': ?instance.foundation,
  'relatedAddress': ?instance.relatedAddress,
  'relatedPort': ?instance.relatedPort,
  'usernameFragment': ?instance.usernameFragment,
  'tcpType': ?_$RtcIceTcpCandidateTypeEnumMap[instance.tcpType],
  'networkType': ?instance.networkType,
};

const _$RtcIceCandidateTypeEnumMap = {
  RtcIceCandidateType.host: 'host',
  RtcIceCandidateType.srflx: 'srflx',
  RtcIceCandidateType.prflx: 'prflx',
  RtcIceCandidateType.relay: 'relay',
};

const _$IceServerTransportProtocolEnumMap = {
  IceServerTransportProtocol.udp: 'udp',
  IceServerTransportProtocol.tcp: 'tcp',
  IceServerTransportProtocol.tls: 'tls',
};

const _$RtcIceTcpCandidateTypeEnumMap = {
  RtcIceTcpCandidateType.active: 'active',
  RtcIceTcpCandidateType.passive: 'passive',
  RtcIceTcpCandidateType.so: 'so',
};

Map<String, dynamic> _$RtcRemoteIceCandidateStatsToJson(
  RtcRemoteIceCandidateStats instance,
) => <String, dynamic>{
  'transportId': ?instance.transportId,
  'address': ?instance.address,
  'port': ?instance.port,
  'protocol': ?instance.protocol,
  'candidateType': ?_$RtcIceCandidateTypeEnumMap[instance.candidateType],
  'priority': ?instance.priority,
  'url': ?instance.url,
  'relayProtocol': ?_$IceServerTransportProtocolEnumMap[instance.relayProtocol],
  'foundation': ?instance.foundation,
  'relatedAddress': ?instance.relatedAddress,
  'relatedPort': ?instance.relatedPort,
  'usernameFragment': ?instance.usernameFragment,
  'tcpType': ?_$RtcIceTcpCandidateTypeEnumMap[instance.tcpType],
  'networkType': ?instance.networkType,
};

Map<String, dynamic> _$RtcCertificateStatsToJson(
  RtcCertificateStats instance,
) => <String, dynamic>{
  'fingerprint': ?instance.fingerprint,
  'fingerprintAlgorithm': ?instance.fingerprintAlgorithm,
  'base64Certificate': ?instance.base64Certificate,
  'issuerCertificateId': ?instance.issuerCertificateId,
};

Map<String, dynamic> _$RtcOutboundRtpStreamAudioToJson(
  RtcOutboundRtpStreamAudio instance,
) => <String, dynamic>{
  'totalSamplesSent': ?instance.totalSamplesSent,
  'voiceActivityFlag': ?instance.voiceActivityFlag,
};

Map<String, dynamic> _$RtcOutboundRtpStreamVideoToJson(
  RtcOutboundRtpStreamVideo instance,
) => <String, dynamic>{
  'rid': ?instance.rid,
  'encodingIndex': ?instance.encodingIndex,
  'totalEncodedBytesTarget': ?instance.totalEncodedBytesTarget,
  'frameWidth': ?instance.frameWidth,
  'frameHeight': ?instance.frameHeight,
  'framesPerSecond': ?instance.framesPerSecond,
  'framesSent': ?instance.framesSent,
  'hugeFramesSent': ?instance.hugeFramesSent,
  'framesEncoded': ?instance.framesEncoded,
  'keyFramesEncoded': ?instance.keyFramesEncoded,
  'qpSum': ?instance.qpSum,
  'psnrSum': ?instance.psnrSum,
  'psnrMeasurements': ?instance.psnrMeasurements,
  'totalEncodeTime': ?instance.totalEncodeTime,
  'firCount': ?instance.firCount,
  'pliCount': ?instance.pliCount,
  'encoderImplementation': ?instance.encoderImplementation,
  'powerEfficientEncoder': ?instance.powerEfficientEncoder,
  'qualityLimitationReason':
      ?_$RtcQualityLimitationReasonEnumMap[instance.qualityLimitationReason],
  'qualityLimitationDurations': ?instance.qualityLimitationDurations,
  'qualityLimitationResolutionChanges':
      ?instance.qualityLimitationResolutionChanges,
  'scalabilityMode': ?instance.scalabilityMode,
};

const _$RtcQualityLimitationReasonEnumMap = {
  RtcQualityLimitationReason.none: 'none',
  RtcQualityLimitationReason.cpu: 'cpu',
  RtcQualityLimitationReason.bandwidth: 'bandwidth',
  RtcQualityLimitationReason.other: 'other',
};

Map<String, dynamic> _$RtcOutboundRtpStreamStatsToJson(
  RtcOutboundRtpStreamStats instance,
) => <String, dynamic>{
  'ssrc': ?instance.ssrc,
  'kind': ?instance.kind,
  'transportId': ?instance.transportId,
  'codecId': ?instance.codecId,
  'packetsSent': ?instance.packetsSent,
  'bytesSent': ?instance.bytesSent,
  'mid': ?instance.mid,
  'mediaSourceId': ?instance.mediaSourceId,
  'remoteId': ?instance.remoteId,
  'headerBytesSent': ?instance.headerBytesSent,
  'retransmittedPacketsSent': ?instance.retransmittedPacketsSent,
  'retransmittedBytesSent': ?instance.retransmittedBytesSent,
  'rtxSsrc': ?instance.rtxSsrc,
  'targetBitrate': ?instance.targetBitrate,
  'totalPacketSendDelay': ?instance.totalPacketSendDelay,
  'nackCount': ?instance.nackCount,
  'active': ?instance.active,
  'packetsSentWithEct1': ?instance.packetsSentWithEct1,
};

Map<String, dynamic> _$RtcInboundRtpStreamMediaTypeToJson(
  RtcInboundRtpStreamMediaType instance,
) => <String, dynamic>{};

Map<String, dynamic> _$RtcInboundRtpStreamAudioToJson(
  RtcInboundRtpStreamAudio instance,
) => <String, dynamic>{
  'totalSamplesReceived': ?instance.totalSamplesReceived,
  'concealedSamples': ?instance.concealedSamples,
  'silentConcealedSamples': ?instance.silentConcealedSamples,
  'concealmentEvents': ?instance.concealmentEvents,
  'insertedSamplesForDeceleration': ?instance.insertedSamplesForDeceleration,
  'removedSamplesForAcceleration': ?instance.removedSamplesForAcceleration,
  'audioLevel': ?instance.audioLevel,
  'totalAudioEnergy': ?instance.totalAudioEnergy,
  'totalSamplesDuration': ?instance.totalSamplesDuration,
  'playoutId': ?instance.playoutId,
};

Map<String, dynamic> _$RtcInboundRtpStreamVideoToJson(
  RtcInboundRtpStreamVideo instance,
) => <String, dynamic>{
  'framesDecoded': ?instance.framesDecoded,
  'keyFramesDecoded': ?instance.keyFramesDecoded,
  'framesRendered': ?instance.framesRendered,
  'framesDropped': ?instance.framesDropped,
  'frameWidth': ?instance.frameWidth,
  'frameHeight': ?instance.frameHeight,
  'framesPerSecond': ?instance.framesPerSecond,
  'qpSum': ?instance.qpSum,
  'totalDecodeTime': ?instance.totalDecodeTime,
  'totalInterFrameDelay': ?instance.totalInterFrameDelay,
  'totalSquaredInterFrameDelay': ?instance.totalSquaredInterFrameDelay,
  'pauseCount': ?instance.pauseCount,
  'totalPausesDuration': ?instance.totalPausesDuration,
  'freezeCount': ?instance.freezeCount,
  'totalFreezesDuration': ?instance.totalFreezesDuration,
  'firCount': ?instance.firCount,
  'pliCount': ?instance.pliCount,
  'framesReceived': ?instance.framesReceived,
  'decoderImplementation': ?instance.decoderImplementation,
  'powerEfficientDecoder': ?instance.powerEfficientDecoder,
  'framesAssembledFromMultiplePackets':
      ?instance.framesAssembledFromMultiplePackets,
  'totalAssemblyTime': ?instance.totalAssemblyTime,
  'totalCorruptionProbability': ?instance.totalCorruptionProbability,
  'totalSquaredCorruptionProbability':
      ?instance.totalSquaredCorruptionProbability,
  'corruptionMeasurements': ?instance.corruptionMeasurements,
};

Map<String, dynamic> _$RtcCodecStatsToJson(RtcCodecStats instance) =>
    <String, dynamic>{
      'payloadType': ?instance.payloadType,
      'transportId': ?instance.transportId,
      'mimeType': ?instance.mimeType,
      'clockRate': ?instance.clockRate,
      'channels': ?instance.channels,
      'sdpFmtpLine': ?instance.sdpFmtpLine,
    };

Map<String, dynamic> _$RtcInboundRtpStreamStatsToJson(
  RtcInboundRtpStreamStats instance,
) => <String, dynamic>{
  'ssrc': ?instance.ssrc,
  'kind': ?instance.kind,
  'transportId': ?instance.transportId,
  'codecId': ?instance.codecId,
  'packetsReceived': ?instance.packetsReceived,
  'packetsReceivedWithEct1': ?instance.packetsReceivedWithEct1,
  'packetsReceivedWithCe': ?instance.packetsReceivedWithCe,
  'packetsReportedAsLost': ?instance.packetsReportedAsLost,
  'packetsReportedAsLostButRecovered':
      ?instance.packetsReportedAsLostButRecovered,
  'packetsLost': ?instance.packetsLost,
  'jitter': ?instance.jitter,
  'trackIdentifier': ?instance.trackIdentifier,
  'mid': ?instance.mid,
  'remoteId': ?instance.remoteId,
  'bytesReceived': ?instance.bytesReceived,
  'jitterBufferEmittedCount': ?instance.jitterBufferEmittedCount,
  'jitterBufferDelay': ?instance.jitterBufferDelay,
  'jitterBufferTargetDelay': ?instance.jitterBufferTargetDelay,
  'jitterBufferMinimumDelay': ?instance.jitterBufferMinimumDelay,
  'headerBytesReceived': ?instance.headerBytesReceived,
  'packetsDiscarded': ?instance.packetsDiscarded,
  'lastPacketReceivedTimestamp': ?instance.lastPacketReceivedTimestamp,
  'estimatedPlayoutTimestamp': ?instance.estimatedPlayoutTimestamp,
  'fecBytesReceived': ?instance.fecBytesReceived,
  'fecPacketsReceived': ?instance.fecPacketsReceived,
  'fecPacketsDiscarded': ?instance.fecPacketsDiscarded,
  'totalProcessingDelay': ?instance.totalProcessingDelay,
  'nackCount': ?instance.nackCount,
  'retransmittedPacketsReceived': ?instance.retransmittedPacketsReceived,
  'retransmittedBytesReceived': ?instance.retransmittedBytesReceived,
  'rtxSsrc': ?instance.rtxSsrc,
  'fecSsrc': ?instance.fecSsrc,
};

Map<String, dynamic> _$RtcIceCandidatePairStatsToJson(
  RtcIceCandidatePairStats instance,
) => <String, dynamic>{
  'transportId': ?instance.transportId,
  'localCandidateId': ?instance.localCandidateId,
  'remoteCandidateId': ?instance.remoteCandidateId,
  'state': ?_$RtcStatsIceCandidatePairStateEnumMap[instance.state],
  'nominated': ?instance.nominated,
  'priority': ?instance.priority,
  'packetsSent': ?instance.packetsSent,
  'packetsReceived': ?instance.packetsReceived,
  'bytesSent': ?instance.bytesSent,
  'bytesReceived': ?instance.bytesReceived,
  'lastPacketSentTimestamp': ?instance.lastPacketSentTimestamp,
  'lastPacketReceivedTimestamp': ?instance.lastPacketReceivedTimestamp,
  'totalRoundTripTime': ?instance.totalRoundTripTime,
  'currentRoundTripTime': ?instance.currentRoundTripTime,
  'availableOutgoingBitrate': ?instance.availableOutgoingBitrate,
  'availableIncomingBitrate': ?instance.availableIncomingBitrate,
  'requestsReceived': ?instance.requestsReceived,
  'requestsSent': ?instance.requestsSent,
  'responsesReceived': ?instance.responsesReceived,
  'responsesSent': ?instance.responsesSent,
  'consentRequestsSent': ?instance.consentRequestsSent,
  'packetsDiscardedOnSend': ?instance.packetsDiscardedOnSend,
  'bytesDiscardedOnSend': ?instance.bytesDiscardedOnSend,
};

const _$RtcStatsIceCandidatePairStateEnumMap = {
  RtcStatsIceCandidatePairState.frozen: 'frozen',
  RtcStatsIceCandidatePairState.waiting: 'waiting',
  RtcStatsIceCandidatePairState.inProgress: 'in-progress',
  RtcStatsIceCandidatePairState.failed: 'failed',
  RtcStatsIceCandidatePairState.succeeded: 'succeeded',
  RtcStatsIceCandidatePairState.cancelled: 'cancelled',
};

Map<String, dynamic> _$RtcTransportStatsToJson(RtcTransportStats instance) =>
    <String, dynamic>{
      'packetsSent': ?instance.packetsSent,
      'packetsReceived': ?instance.packetsReceived,
      'bytesSent': ?instance.bytesSent,
      'bytesReceived': ?instance.bytesReceived,
      'iceRole': ?_$RtcIceRoleEnumMap[instance.iceRole],
      'iceLocalUsernameFragment': ?instance.iceLocalUsernameFragment,
      'iceState': ?_$RtcIceTransportStateEnumMap[instance.iceState],
      'dtlsState': ?_$RtcDtlsTransportStateEnumMap[instance.dtlsState],
      'selectedCandidatePairId': ?instance.selectedCandidatePairId,
      'localCertificateId': ?instance.localCertificateId,
      'remoteCertificateId': ?instance.remoteCertificateId,
      'tlsVersion': ?instance.tlsVersion,
      'dtlsCipher': ?instance.dtlsCipher,
      'dtlsRole': ?_$RtcDtlsRoleEnumMap[instance.dtlsRole],
      'srtpCipher': ?instance.srtpCipher,
      'ccfbMessagesSent': ?instance.ccfbMessagesSent,
      'ccfbMessagesReceived': ?instance.ccfbMessagesReceived,
      'selectedCandidatePairChanges': ?instance.selectedCandidatePairChanges,
    };

const _$RtcIceRoleEnumMap = {
  RtcIceRole.unknown: 'unknown',
  RtcIceRole.controlling: 'controlling',
  RtcIceRole.controlled: 'controlled',
};

const _$RtcIceTransportStateEnumMap = {
  RtcIceTransportState.closed: 'closed',
  RtcIceTransportState.failed: 'failed',
  RtcIceTransportState.disconnected: 'disconnected',
  RtcIceTransportState.new_: 'new_',
  RtcIceTransportState.checking: 'checking',
  RtcIceTransportState.completed: 'completed',
  RtcIceTransportState.connected: 'connected',
};

const _$RtcDtlsTransportStateEnumMap = {
  RtcDtlsTransportState.new_: 'new_',
  RtcDtlsTransportState.connecting: 'connecting',
  RtcDtlsTransportState.connected: 'connected',
  RtcDtlsTransportState.closed: 'closed',
  RtcDtlsTransportState.failed: 'failed',
};

const _$RtcDtlsRoleEnumMap = {
  RtcDtlsRole.client: 'client',
  RtcDtlsRole.server: 'server',
  RtcDtlsRole.unknown: 'unknown',
};

Map<String, dynamic> _$RtcRemoteInboundRtpStreamStatsToJson(
  RtcRemoteInboundRtpStreamStats instance,
) => <String, dynamic>{
  'ssrc': ?instance.ssrc,
  'kind': ?instance.kind,
  'transportId': ?instance.transportId,
  'codecId': ?instance.codecId,
  'packetsReceived': ?instance.packetsReceived,
  'packetsReceivedWithEct1': ?instance.packetsReceivedWithEct1,
  'packetsReceivedWithCe': ?instance.packetsReceivedWithCe,
  'packetsReportedAsLost': ?instance.packetsReportedAsLost,
  'packetsReportedAsLostButRecovered':
      ?instance.packetsReportedAsLostButRecovered,
  'packetsLost': ?instance.packetsLost,
  'jitter': ?instance.jitter,
  'localId': ?instance.localId,
  'roundTripTime': ?instance.roundTripTime,
  'totalRoundTripTime': ?instance.totalRoundTripTime,
  'fractionLost': ?instance.fractionLost,
  'roundTripTimeMeasurements': ?instance.roundTripTimeMeasurements,
  'packetsWithBleachedEct1Marking': ?instance.packetsWithBleachedEct1Marking,
};

Map<String, dynamic> _$RtcRemoteOutboundRtpStreamStatsToJson(
  RtcRemoteOutboundRtpStreamStats instance,
) => <String, dynamic>{
  'ssrc': ?instance.ssrc,
  'kind': ?instance.kind,
  'transportId': ?instance.transportId,
  'codecId': ?instance.codecId,
  'packetsSent': ?instance.packetsSent,
  'bytesSent': ?instance.bytesSent,
  'localId': ?instance.localId,
  'remoteTimestamp': ?instance.remoteTimestamp,
  'reportsSent': ?instance.reportsSent,
  'roundTripTime': ?instance.roundTripTime,
  'totalRoundTripTime': ?instance.totalRoundTripTime,
  'roundTripTimeMeasurements': ?instance.roundTripTimeMeasurements,
};
