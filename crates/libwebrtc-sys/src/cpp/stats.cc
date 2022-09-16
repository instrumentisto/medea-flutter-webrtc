#include "stats.h"
#include "libwebrtc-sys/src/bridge.rs.h"
#include <stdexcept>

namespace bridge {

// Returns the `is_defined` of the provided `RTCStatsMemberString`.
bool rtc_stats_member_string_is_defined(const RTCStatsMemberString& stats_member) {
  return stats_member.is_defined();
}
// Returns the `is_defined` of the provided `RTCStatsMemberf64`.
bool rtc_stats_member_f64_is_defined(const RTCStatsMemberf64& stats_member) {
  return stats_member.is_defined();
}
// Returns the `is_defined` of the provided `RTCStatsMemberi32`.
bool rtc_stats_member_i32_is_defined(const RTCStatsMemberi32& stats_member) {
  return stats_member.is_defined();
}
// Returns the `is_defined` of the provided `RTCStatsMemberu32`.
bool rtc_stats_member_u32_is_defined(const RTCStatsMemberu32& stats_member) {
  return stats_member.is_defined();
}
// Returns the `is_defined` of the provided `RTCStatsMemberu64`.
bool rtc_stats_member_u64_is_defined(const RTCStatsMemberu64& stats_member) {
  return stats_member.is_defined();
}
// Returns the `is_defined` of the provided `RTCStatsMemberbool`.
bool rtc_stats_member_bool_is_defined(const RTCStatsMemberbool& stats_member) {
  return stats_member.is_defined();
}

// Returns the `value` of the provided `RTCStatsMemberString`.
std::unique_ptr<std::string> rtc_stats_member_string_value(const RTCStatsMemberString& stats_member) {
  return std::make_unique<std::string>(*stats_member);
}
// Returns the `value` of the provided `RTCStatsMemberf64`.
double rtc_stats_member_f64_value(const RTCStatsMemberf64& stats_member) {
  return *stats_member;
}
// Returns the `value` of the provided `RTCStatsMemberi32`.
int32_t rtc_stats_member_i32_value(const RTCStatsMemberi32& stats_member) {
  return *stats_member;
}
// Returns the `value` of the provided `RTCStatsMemberu32`.
uint32_t rtc_stats_member_u32_value(const RTCStatsMemberu32& stats_member) {
  return *stats_member;
}
// Returns the `value` of the provided `RTCStatsMemberu64`.
uint64_t rtc_stats_member_u64_value(const RTCStatsMemberu64& stats_member) {
  return *stats_member;
}
// Returns the `value` of the provided `RTCStatsMemberbool`.
bool rtc_stats_member_bool_value(const RTCStatsMemberbool& stats_member) {
  return *stats_member;
}


// Returns the `id` of the provided `RTCStats`.
std::unique_ptr<std::string> rtc_stats_id(const RTCStats& stats) {
  return std::make_unique<std::string>(stats.id());
}
// Returns the `timestamp_us` of the provided `RTCStats`.
int64_t rtc_stats_timestamp_us(const RTCStats& stats) {
  return stats.timestamp_us();
}
// Returns the `type` of the provided `RTCStats`.
std::unique_ptr<std::string> rtc_stats_type(const RTCStats& stats) {
    std::string str = std::string(stats.type());
    return std::make_unique<std::string>(str);
}


// Try cast a `RTCStats` to the `RTCMediaSourceStats`.
std::unique_ptr<RTCMediaSourceStats> rtc_stats_cast_to_rtc_media_source_stats(std::unique_ptr<RTCStats> stats) {
  auto type = std::string(stats->type());
  if (type == "media-source") {
    return std::unique_ptr<RTCMediaSourceStats>(static_cast<RTCMediaSourceStats*>(stats.release()));
  }
  throw std::invalid_argument( "Invalid type. Expected `ice-candidate` but found " + type );
}
// Try cast a `RTCStats` to the `RTCIceCandidateStats`.
std::unique_ptr<RTCIceCandidateStats> rtc_stats_cast_to_rtc_ice_candidate_stats(std::unique_ptr<RTCStats> stats) {
  auto type = std::string(stats->type());
  if (type == "remote-candidate" || type == "local-candidate") {
    return std::unique_ptr<RTCIceCandidateStats>(static_cast<RTCIceCandidateStats*>(stats.release()));
  }
  throw std::invalid_argument( "Invalid type. Expected `local-candidate` or `remote-candidate` but found " + type );
}
// Try cast a `RTCStats` to the `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCOutboundRTPStreamStats> rtc_stats_cast_to_rtc_outbound_rtp_stream_stats(std::unique_ptr<RTCStats> stats) {
  auto type = std::string(stats->type());
  if (type == "outbound-rtp") {
    return std::unique_ptr<RTCOutboundRTPStreamStats>(static_cast<RTCOutboundRTPStreamStats*>(stats.release()));
  }
  throw std::invalid_argument( "Invalid type. Expected `outbound-rtp` but found " + type );
}
// Try cast a `RTCStats` to the `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCInboundRTPStreamStats> rtc_stats_cast_to_rtc_inbound_rtp_stream_stats(std::unique_ptr<RTCStats> stats) {
  auto type = std::string(stats->type());
  if (type == "inbound-rtp") {
    return std::unique_ptr<RTCInboundRTPStreamStats>(static_cast<RTCInboundRTPStreamStats*>(stats.release()));
  }
  throw std::invalid_argument( "Invalid type. Expected `inbound-rtp` but found " + type );
}
// Try cast a `RTCStats` to the `RTCIceCandidatePairStats`.
std::unique_ptr<RTCIceCandidatePairStats> rtc_stats_cast_to_rtc_ice_candidate_pair_stats(std::unique_ptr<RTCStats> stats) {
  auto type = std::string(stats->type());
  if (type == "candidate-pair") {
    return std::unique_ptr<RTCIceCandidatePairStats>(static_cast<RTCIceCandidatePairStats*>(stats.release()));
  }
  throw std::invalid_argument( "Invalid type. Expected `candidate-pair` but found " + type );
}
// Try cast a `RTCStats` to the `RTCTransportStats`.
std::unique_ptr<RTCTransportStats> rtc_stats_cast_to_rtc_transport_stats(std::unique_ptr<RTCStats> stats) {
  auto type = std::string(stats->type());
  if (type == "transport") {
    return std::unique_ptr<RTCTransportStats>(static_cast<RTCTransportStats*>(stats.release()));
  }
  throw std::invalid_argument( "Invalid type. Expected `transport` but found " + type );
}
// Try cast a `RTCStats` to the `RTCRemoteInboundRtpStreamStats`.
std::unique_ptr<RTCRemoteInboundRtpStreamStats> rtc_stats_cast_to_rtc_remote_inbound_rtp_stream_stats(std::unique_ptr<RTCStats> stats) {
  auto type = std::string(stats->type());
  if (type == "remote-inbound-rtp") {
    return std::unique_ptr<RTCRemoteInboundRtpStreamStats>(static_cast<RTCRemoteInboundRtpStreamStats*>(stats.release()));
  }
  throw std::invalid_argument( "Invalid type. Expected `remote-inbound-rtp` but found " + type );
}
// Try cast a `RTCStats` to the `RTCRemoteOutboundRtpStreamStats`.
std::unique_ptr<RTCRemoteOutboundRtpStreamStats> rtc_stats_cast_to_rtc_remote_outbound_rtp_stream_stats(std::unique_ptr<RTCStats> stats) {
  auto type = std::string(stats->type());
  if (type == "remote-outbound-rtp") {
    return std::unique_ptr<RTCRemoteOutboundRtpStreamStats>(static_cast<RTCRemoteOutboundRtpStreamStats*>(stats.release()));
  }
  throw std::invalid_argument( "Invalid type. Expected `remote-outbound-rtp` but found " + type );
}
// Try cast a `RTCStats` to the `RTCVideoSourceStats`.
std::unique_ptr<RTCVideoSourceStats> rtc_media_source_stats_cast_to_rtc_video_source_stats(std::unique_ptr<RTCMediaSourceStats> stats) {
  auto kind = *stats->kind;
  if (kind == "video") {
    return std::unique_ptr<RTCVideoSourceStats>(static_cast<RTCVideoSourceStats*>(stats.release()));
  }
  throw std::invalid_argument( "Invalid kind. Expected `video` but found " + kind );
}
// Try cast a `RTCStats` to the `RTCAudioSourceStats`.
std::unique_ptr<RTCAudioSourceStats> rtc_media_source_stats_cast_to_rtc_audio_source_stats(std::unique_ptr<RTCMediaSourceStats> stats) {
  auto kind = *stats->kind;
  if (kind == "audio") {
    return std::unique_ptr<RTCAudioSourceStats>(static_cast<RTCAudioSourceStats*>(stats.release()));
  }
  throw std::invalid_argument( "Invalid kind. Expected `audio` but found " + kind );
}

// RTCMediaSourceStats
// Returns the `track_identifier` of the provided `RTCMediaSourceStats`.
std::unique_ptr<RTCStatsMemberString> rtc_media_source_stats_track_identifier(
    const RTCMediaSourceStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.track_identifier);
}
// Returns the `kind` of the provided `RTCMediaSourceStats`.
std::unique_ptr<RTCStatsMemberString> rtc_media_source_stats_kind(
    const RTCMediaSourceStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.kind);
}
/// RTCMediaSourceStats

//RTCVideoSourceStats
// Returns the `width` of the provided `RTCVideoSourceStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_video_source_stats_width(
    const RTCVideoSourceStats& stats) {
      return std::make_unique<RTCStatsMemberu32>(stats.width);
    }
// Returns the `height` of the provided `RTCVideoSourceStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_video_source_stats_height(
    const RTCVideoSourceStats& stats) {
      return std::make_unique<RTCStatsMemberu32>(stats.height);
    }
// Returns the `frames` of the provided `RTCVideoSourceStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_video_source_stats_frames(
    const RTCVideoSourceStats& stats) {
      return std::make_unique<RTCStatsMemberu32>(stats.frames);
    }
// Returns the `frames_per_second` of the provided `RTCVideoSourceStats`.
std::unique_ptr<RTCStatsMemberf64> rtc_video_source_stats_frames_per_second(
    const RTCVideoSourceStats& stats) {
      return std::make_unique<RTCStatsMemberf64>(stats.frames_per_second);
    }
/// RTCMediaSourceStats 

// RTCAudioSourceStats
// Returns the `audio_level` of the provided `RTCAudioSourceStats`.
std::unique_ptr<RTCStatsMemberf64> rtc_audio_source_stats_audio_level(
    const RTCAudioSourceStats& stats) {
      return std::make_unique<RTCStatsMemberf64>(stats.audio_level);
    }
// Returns the `total_audio_energy` of the provided `RTCAudioSourceStats`.
std::unique_ptr<RTCStatsMemberf64> rtc_audio_source_stats_total_audio_energy(
    const RTCAudioSourceStats& stats) {
      return std::make_unique<RTCStatsMemberf64>(stats.total_audio_energy);
    }
// Returns the `total_samples_duration` of the provided `RTCAudioSourceStats`.
std::unique_ptr<RTCStatsMemberf64> rtc_audio_source_stats_total_samples_duration(
    const RTCAudioSourceStats& stats) {
      return std::make_unique<RTCStatsMemberf64>(stats.total_samples_duration);
    }
// Returns the `echo_return_loss` of the provided `RTCAudioSourceStats`.
std::unique_ptr<RTCStatsMemberf64> rtc_audio_source_stats_echo_return_loss(
    const RTCAudioSourceStats& stats) {
      return std::make_unique<RTCStatsMemberf64>(stats.echo_return_loss);
    }
// Returns the `echo_return_loss_enhancement` of the provided `RTCAudioSourceStats`.
std::unique_ptr<RTCStatsMemberf64> rtc_audio_source_stats_echo_return_loss_enhancement(
    const RTCAudioSourceStats& stats) {
      return std::make_unique<RTCStatsMemberf64>(stats.echo_return_loss_enhancement);
    }
/// RTCAudioSourceStats

// RTCIceCandidateStats
// Returns the `transport_id` of the provided `RTCIceCandidateStats`.
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_stats_transport_id(
    const RTCIceCandidateStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.transport_id);
}
// Returns the `is_remote` of the provided `RTCIceCandidateStats`.
std::unique_ptr<RTCStatsMemberbool> rtc_ice_candidate_stats_is_remote(
  const RTCIceCandidateStats& stats) {
  return std::make_unique<RTCStatsMemberbool>(stats.is_remote);
}
// Returns the `network_type` of the provided `RTCIceCandidateStats`.
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_stats_network_type(
    const RTCIceCandidateStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.network_type);
}
// Returns the `ip` of the provided `RTCIceCandidateStats`.
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_stats_ip(
    const RTCIceCandidateStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.ip);
}
// Returns the `address` of the provided `RTCIceCandidateStats`.
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_stats_address(
    const RTCIceCandidateStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.address);
}
// Returns the `port` of the provided `RTCIceCandidateStats`.
std::unique_ptr<RTCStatsMemberi32> rtc_ice_candidate_stats_port(
  const RTCIceCandidateStats& stats) {
  return std::make_unique<RTCStatsMemberi32>(stats.port);
}
// Returns the `protocol` of the provided `RTCIceCandidateStats`.
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_stats_protocol(
    const RTCIceCandidateStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.protocol);
}
// Returns the `relay_protocol` of the provided `RTCIceCandidateStats`.
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_stats_relay_protocol(
    const RTCIceCandidateStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.relay_protocol);
}
// Returns the `candidate_type` of the provided `RTCIceCandidateStats`.
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_stats_candidate_type(
    const RTCIceCandidateStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.candidate_type);
}
// Returns the `priority` of the provided `RTCIceCandidateStats`.
std::unique_ptr<RTCStatsMemberi32> rtc_ice_candidate_stats_priority(
  const RTCIceCandidateStats& stats) {
  return std::make_unique<RTCStatsMemberi32>(stats.priority);
}
// Returns the `url` of the provided `RTCIceCandidateStats`.
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_stats_url(
    const RTCIceCandidateStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.url);
}
// Returns the `vpn` of the provided `RTCIceCandidateStats`.
std::unique_ptr<RTCStatsMemberbool> rtc_ice_candidate_stats_vpn(
  const RTCIceCandidateStats& stats) {
  return std::make_unique<RTCStatsMemberbool>(stats.vpn);
}
// Returns the `network_adapter_type` of the provided `RTCIceCandidateStats`.
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_stats_network_adapter_type(
    const RTCIceCandidateStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.network_adapter_type);
}
/// RTCIceCandidateStats

// RTCOutboundRTPStreamStats
// Returns the `track_id` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberString> rtc_outbound_rtp_stream_stats_track_id(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.track_id);
}
// Returns the `kind` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberString> rtc_outbound_rtp_stream_stats_kind(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.kind);
}
// Returns the `media_source_id` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberString> rtc_outbound_rtp_stream_stats_media_source_id(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.media_source_id);
}
// Returns the `remote_id` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberString> rtc_outbound_rtp_stream_stats_remote_id(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.remote_id);
}
// Returns the `rid` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberString> rtc_outbound_rtp_stream_stats_rid(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.rid);
}
// Returns the `packets_sent` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_outbound_rtp_stream_stats_packets_sent(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.packets_sent);
}
// Returns the `retransmitted_packets_sent` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_outbound_rtp_stream_stats_retransmitted_packets_sent(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.retransmitted_packets_sent);
}
// Returns the `bytes_sent` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_outbound_rtp_stream_stats_bytes_sent(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.bytes_sent);
}
// Returns the `header_bytes_sent` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_outbound_rtp_stream_stats_header_bytes_sent(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.header_bytes_sent);
}
// Returns the `retransmitted_bytes_sent` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_outbound_rtp_stream_stats_retransmitted_bytes_sent(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.retransmitted_bytes_sent);
}
// Returns the `target_bitrate` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberf64> rtc_outbound_rtp_stream_stats_target_bitrate(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.target_bitrate);
}
// Returns the `frames_encoded` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_outbound_rtp_stream_stats_frames_encoded(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.frames_encoded);
}
// Returns the `key_frames_encoded` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_outbound_rtp_stream_stats_key_frames_encoded(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.key_frames_encoded);
}
// Returns the `total_encode_time` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberf64> rtc_outbound_rtp_stream_stats_total_encode_time(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.total_encode_time);
}
// Returns the `total_encoded_bytes_target` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_outbound_rtp_stream_stats_total_encoded_bytes_target(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.total_encoded_bytes_target);
}
// Returns the `frame_width` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_outbound_rtp_stream_stats_frame_width(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.frame_width);
}
// Returns the `frame_height` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_outbound_rtp_stream_stats_frame_height(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.frame_height);
}
// Returns the `frames_per_second` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberf64> rtc_outbound_rtp_stream_stats_frames_per_second(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.frames_per_second);
}
// Returns the `frames_sent` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_outbound_rtp_stream_stats_frames_sent(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.frames_sent);
}
// Returns the `huge_frames_sent` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_outbound_rtp_stream_stats_huge_frames_sent(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.huge_frames_sent);
}
// Returns the `total_packet_send_delay` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberf64> rtc_outbound_rtp_stream_stats_total_packet_send_delay(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.total_packet_send_delay);
}
// Returns the `quality_limitation_reason` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberString> rtc_outbound_rtp_stream_stats_quality_limitation_reason(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.quality_limitation_reason);
}
// Returns the `quality_limitation_resolution_changes` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_outbound_rtp_stream_stats_quality_limitation_resolution_changes(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.quality_limitation_resolution_changes);
}
// Returns the `content_type` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberString> rtc_outbound_rtp_stream_stats_content_type(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.content_type);
}
// Returns the `encoder_implementation` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberString> rtc_outbound_rtp_stream_stats_encoder_implementation(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.encoder_implementation);
}
// Returns the `fir_count` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_outbound_rtp_stream_stats_fir_count(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.fir_count);
}
// Returns the `pli_count` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_outbound_rtp_stream_stats_pli_count(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.pli_count);
}
// Returns the `nack_count` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_outbound_rtp_stream_stats_nack_count(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.nack_count);
}
// Returns the `qp_sum` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_outbound_rtp_stream_stats_qp_sum(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.qp_sum);
}
/// RTCOutboundRTPStreamStats


// RTCInboundRTPStreamStats
// Returns the `remote_id` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberString> rtc_inbound_rtp_stream_stats_remote_id(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.remote_id);
}
// Returns the `packets_received` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_packets_received(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.packets_received);
}
// Returns the `fec_packets_received` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_inbound_rtp_stream_stats_fec_packets_received(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.fec_packets_received);
}
// Returns the `fec_packets_discarded` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_inbound_rtp_stream_stats_fec_packets_discarded(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.fec_packets_discarded);
}
// Returns the `bytes_received` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_inbound_rtp_stream_stats_bytes_received(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.bytes_received);
}
// Returns the `header_bytes_received` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_inbound_rtp_stream_stats_header_bytes_received(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.header_bytes_received);
}
// Returns the `last_packet_received_timestamp` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_last_packet_received_timestamp(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.last_packet_received_timestamp);
}
// Returns the `jitter_buffer_delay` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_jitter_buffer_delay(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.jitter_buffer_delay);
}
// Returns the `jitter_buffer_emitted_count` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_inbound_rtp_stream_stats_jitter_buffer_emitted_count(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.jitter_buffer_emitted_count);
}
// Returns the `total_samples_received` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_inbound_rtp_stream_stats_total_samples_received(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.total_samples_received);
}
// Returns the `concealed_samples` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_inbound_rtp_stream_stats_concealed_samples(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.concealed_samples);
}
// Returns the `silent_concealed_samples` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_inbound_rtp_stream_stats_silent_concealed_samples(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.silent_concealed_samples);
}
// Returns the `concealment_events` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_inbound_rtp_stream_stats_concealment_events(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.concealment_events);
}
// Returns the `inserted_samples_for_deceleration` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_inbound_rtp_stream_stats_inserted_samples_for_deceleration(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.inserted_samples_for_deceleration);
}
// Returns the `removed_samples_for_acceleration` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_inbound_rtp_stream_stats_removed_samples_for_acceleration(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.removed_samples_for_acceleration);
}
// Returns the `audio_level` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_audio_level(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.audio_level);
}
// Returns the `total_audio_energy` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_total_audio_energy(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.total_audio_energy);
}
// Returns the `total_samples_duration` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_total_samples_duration(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.total_samples_duration);
}
// Returns the `frames_received` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberi32> rtc_inbound_rtp_stream_stats_frames_received(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberi32>(stats.frames_received);
}
// Returns the `round_trip_time` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_round_trip_time(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.round_trip_time);
}
// Returns the `packets_repaired` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_packets_repaired(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.packets_repaired);
}
// Returns the `burst_packets_lost` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_burst_packets_lost(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.burst_packets_lost);
}
// Returns the `burst_packets_discarded` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_burst_packets_discarded(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.burst_packets_discarded);
}
// Returns the `burst_loss_count` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_burst_loss_count(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.burst_loss_count);
}
// Returns the `burst_discard_count` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_burst_discard_count(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.burst_discard_count);
}
// Returns the `burst_loss_rate` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_burst_loss_rate(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.burst_loss_rate);
}
// Returns the `burst_discard_rate` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_burst_discard_rate(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.burst_discard_rate);
}
// Returns the `gap_loss_rate` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_gap_loss_rate(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.gap_loss_rate);
}
// Returns the `gap_discard_rate` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_gap_discard_rate(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.gap_discard_rate);
}
// Returns the `frame_width` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_frame_width(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.frame_width);
}
// Returns the `frame_height` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_frame_height(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.frame_height);
}
// Returns the `frame_bit_depth` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_frame_bit_depth(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.frame_bit_depth);
}
// Returns the `frames_per_second` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_frames_per_second(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.frames_per_second);
}
// Returns the `frames_decoded` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_frames_decoded(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.frames_decoded);
}
// Returns the `key_frames_decoded` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_key_frames_decoded(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.key_frames_decoded);
}
// Returns the `frames_dropped` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_frames_dropped(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.frames_dropped);
}
// Returns the `total_decode_time` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_total_decode_time(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.total_decode_time);
}
// Returns the `total_inter_frame_delay` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_total_inter_frame_delay(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.total_inter_frame_delay);
}
// Returns the `total_squared_inter_frame_delay` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_total_squared_inter_frame_delay(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.total_squared_inter_frame_delay);
}
// Returns the `content_type` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberString> rtc_inbound_rtp_stream_stats_content_type(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.content_type);
}
// Returns the `estimated_playout_timestamp` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_estimated_playout_timestamp(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.estimated_playout_timestamp);
}
// Returns the `decoder_implementation` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberString> rtc_inbound_rtp_stream_stats_decoder_implementation(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.decoder_implementation);
}
// Returns the `fir_count` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_fir_count(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.fir_count);
}
// Returns the `pli_count` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_pli_count(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.pli_count);
}
// Returns the `nack_count` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_nack_count(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.nack_count);
}
// Returns the `qp_sum` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_inbound_rtp_stream_stats_qp_sum(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.qp_sum);
}
/// RTCInboundRTPStreamStats

// RTCIceCandidatePairStats
// Returns the `transport_id` of the provided `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_pair_stats_transport_id(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.transport_id);
}
// Returns the `local_candidate_id` of the provided `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_pair_stats_local_candidate_id(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.local_candidate_id);
}
// Returns the `remote_candidate_id` of the provided `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_pair_stats_remote_candidate_id(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.remote_candidate_id);
}
// Returns the `state` of the provided `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_pair_stats_state(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.state);
}
// Returns the `priority` of the provided `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_priority(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.priority);
}
// Returns the `nominated` of the provided `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberbool> rtc_ice_candidate_pair_stats_nominated(
  const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberbool>(stats.nominated);
}
// Returns the `writable` of the provided `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberbool> rtc_ice_candidate_pair_stats_writable(
  const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberbool>(stats.writable);
}
// Returns the `readable` of the provided `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberbool> rtc_ice_candidate_pair_stats_readable(
  const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberbool>(stats.readable);
}
// Returns the `packets_sent` of the provided `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_packets_sent(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.packets_sent);
}
// Returns the `packets_received` of the provided `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_packets_received(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.packets_received);
}
// Returns the `bytes_sent` of the provided `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_bytes_sent(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.bytes_sent);
}
// Returns the `bytes_received` of the provided `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_bytes_received(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.bytes_received);
}
// Returns the `total_round_trip_time` of the provided `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberf64> rtc_ice_candidate_pair_stats_total_round_trip_time(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.total_round_trip_time);
}
// Returns the `current_round_trip_time` of the provided `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberf64> rtc_ice_candidate_pair_stats_current_round_trip_time(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.current_round_trip_time);
}
// Returns the `available_outgoing_bitrate` of the provided `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberf64> rtc_ice_candidate_pair_stats_available_outgoing_bitrate(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.available_outgoing_bitrate);
}
// Returns the `available_incoming_bitrate` of the provided `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberf64> rtc_ice_candidate_pair_stats_available_incoming_bitrate(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.available_incoming_bitrate);
}
// Returns the `requests_received` of the provided `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_requests_received(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.requests_received);
}
// Returns the `requests_sent` of the provided `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_requests_sent(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.requests_sent);
}
// Returns the `responses_received` of the provided `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_responses_received(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.responses_received);
}
// Returns the `responses_sent` of the provided `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_responses_sent(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.responses_sent);
}
// Returns the `retransmissions_received` of the provided `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_retransmissions_received(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.retransmissions_received);
}
// Returns the `retransmissions_sent` of the provided `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_retransmissions_sent(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.retransmissions_sent);
}
// Returns the `consent_requests_received` of the provided `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_consent_requests_received(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.consent_requests_received);
}
// Returns the `consent_requests_sent` of the provided `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_consent_requests_sent(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.consent_requests_sent);
}
// Returns the `consent_responses_received` of the provided `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_consent_responses_received(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.consent_responses_received);
}
// Returns the `consent_responses_sent` of the provided `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_consent_responses_sent(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.consent_responses_sent);
}
// Returns the `packets_discarded_on_send` of the provided `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_packets_discarded_on_send(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.packets_discarded_on_send);
}
// Returns the `bytes_discarded_on_send` of the provided `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_bytes_discarded_on_send(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.bytes_discarded_on_send);
}
/// RTCIceCandidatePairStats

// RTCTransportStats
// Returns the `bytes_sent` of the provided `RTCTransportStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_transport_stats_bytes_sent(const RTCTransportStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.bytes_sent);
}
// Returns the `packets_sent` of the provided `RTCTransportStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_transport_stats_packets_sent(const RTCTransportStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.packets_sent);
}
// Returns the `bytes_received` of the provided `RTCTransportStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_transport_stats_bytes_received(const RTCTransportStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.bytes_received);
}
// Returns the `packets_received` of the provided `RTCTransportStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_transport_stats_packets_received(const RTCTransportStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.packets_received);
}
// Returns the `rtcp_transport_stats_id` of the provided `RTCTransportStats`.
std::unique_ptr<RTCStatsMemberString> rtc_transport_stats_rtcp_transport_stats_id(
    const RTCTransportStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.rtcp_transport_stats_id);
    }
// Returns the `dtls_state` of the provided `RTCTransportStats`.
std::unique_ptr<RTCStatsMemberString> rtc_transport_stats_dtls_state(
    const RTCTransportStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.dtls_state);
}
// Returns the `selected_candidate_pair_id` of the provided `RTCTransportStats`.
std::unique_ptr<RTCStatsMemberString> rtc_transport_stats_selected_candidate_pair_id(
    const RTCTransportStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.selected_candidate_pair_id);
    }
// Returns the `local_certificate_id` of the provided `RTCTransportStats`.
std::unique_ptr<RTCStatsMemberString> rtc_transport_stats_local_certificate_id(
    const RTCTransportStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.local_certificate_id);
    }
// Returns the `remote_certificate_id` of the provided `RTCTransportStats`.
std::unique_ptr<RTCStatsMemberString> rtc_transport_stats_remote_certificate_id(
    const RTCTransportStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.remote_certificate_id);
    }
// Returns the `tls_version` of the provided `RTCTransportStats`.
std::unique_ptr<RTCStatsMemberString> rtc_transport_stats_tls_version(
    const RTCTransportStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.tls_version);
    }
// Returns the `dtls_cipher` of the provided `RTCTransportStats`.
std::unique_ptr<RTCStatsMemberString> rtc_transport_stats_dtls_cipher(
    const RTCTransportStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.dtls_cipher);
    }
// Returns the `srtp_cipher` of the provided `RTCTransportStats`.
std::unique_ptr<RTCStatsMemberString> rtc_transport_stats_srtp_cipher(
    const RTCTransportStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.srtp_cipher);
    }

// Returns the `selected_candidate_pair_changes` of the provided `RTCTransportStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_transport_stats_selected_candidate_pair_changes(
    const RTCTransportStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.selected_candidate_pair_changes);
}
/// RTCTransportStats

// RTCRemoteInboundRtpStreamStats
// Returns the `local_id` of the provided `RTCRemoteInboundRtpStreamStats`.
std::unique_ptr<RTCStatsMemberString> rtc_remote_inbound_rtp_stream_stats_local_id(
    const RTCRemoteInboundRtpStreamStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.local_id);
}
// Returns the `round_trip_time` of the provided `RTCRemoteInboundRtpStreamStats`.
std::unique_ptr<RTCStatsMemberf64> rtc_remote_inbound_rtp_stream_stats_round_trip_time(
    const RTCRemoteInboundRtpStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.round_trip_time);
}
// Returns the `fraction_lost` of the provided `RTCRemoteInboundRtpStreamStats`.
std::unique_ptr<RTCStatsMemberf64> rtc_remote_inbound_rtp_stream_stats_fraction_lost(
    const RTCRemoteInboundRtpStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.fraction_lost);
}
// Returns the `total_round_trip_time` of the provided `RTCRemoteInboundRtpStreamStats`.
std::unique_ptr<RTCStatsMemberf64> rtc_remote_inbound_rtp_stream_stats_total_round_trip_time(
    const RTCRemoteInboundRtpStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.total_round_trip_time);
}
// Returns the `round_trip_time_measurements` of the provided `RTCRemoteInboundRtpStreamStats`.
std::unique_ptr<RTCStatsMemberi32> round_trip_time_measurements(
    const RTCRemoteInboundRtpStreamStats& stats) {
  return std::make_unique<RTCStatsMemberi32>(stats.round_trip_time_measurements);
}
/// RTCRemoteInboundRtpStreamStats

// RTCRemoteOutboundRtpStreamStats
// Returns the `local_id` of the provided `RTCRemoteOutboundRtpStreamStats`.
std::unique_ptr<RTCStatsMemberString> rtc_remote_outbound_rtp_stream_stats_local_id(
    const RTCRemoteOutboundRtpStreamStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.local_id);
}
// Returns the `remote_timestamp` of the provided `RTCRemoteOutboundRtpStreamStats`.
std::unique_ptr<RTCStatsMemberf64> rtc_remote_outbound_rtp_stream_stats_remote_timestamp(
    const RTCRemoteOutboundRtpStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.remote_timestamp);
}
// Returns the `reports_sent` of the provided `RTCRemoteOutboundRtpStreamStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_remote_outbound_rtp_stream_stats_reports_sent(
    const RTCRemoteOutboundRtpStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.reports_sent);
}
// Returns the `round_trip_time` of the provided `RTCRemoteOutboundRtpStreamStats`.
std::unique_ptr<RTCStatsMemberf64> rtc_remote_outbound_rtp_stream_stats_round_trip_time(
    const RTCRemoteOutboundRtpStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.round_trip_time);
}
// Returns the `round_trip_time_measurements` of the provided `RTCRemoteOutboundRtpStreamStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_remote_outbound_rtp_stream_stats_round_trip_time_measurements(
    const RTCRemoteOutboundRtpStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.round_trip_time_measurements);
}
// Returns the `total_round_trip_time` of the provided `RTCRemoteOutboundRtpStreamStats`.
std::unique_ptr<RTCStatsMemberf64> rtc_remote_outbound_rtp_stream_stats_total_round_trip_time(
    const RTCRemoteOutboundRtpStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.total_round_trip_time);
}
/// RTCRemoteOutboundRtpStreamStats

// Returns collection `RTCStats` of the provided `RTCStatsReport`.
rust::Vec<RTCStatsContainer> rtc_stats_report_get_stats(
    const RTCStatsReport& report) {
    rust::Vec<RTCStatsContainer> stats_result;

    for (const RTCStats& stats : *report) {
      RTCStatsContainer wrap_stat = {stats.copy()};
      stats_result.push_back(std::move(wrap_stat));
    }
    return stats_result;
}

}  // namespace bridge