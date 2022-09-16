#include "stats.h"
#include "libwebrtc-sys/src/bridge.rs.h"
#include <stdexcept>

#define MacroGetStatsOfType(T) _GetStatsOfType<T, T##Container>

namespace bridge {


bool rtc_stats_member_string_is_defined(const RTCStatsMemberString& stats_member) {
  return stats_member.is_defined();
}
bool rtc_stats_member_f64_is_defined(const RTCStatsMemberf64& stats_member) {
  return stats_member.is_defined();
}
bool rtc_stats_member_i32_is_defined(const RTCStatsMemberi32& stats_member) {
  return stats_member.is_defined();
}
bool rtc_stats_member_u32_is_defined(const RTCStatsMemberu32& stats_member) {
  return stats_member.is_defined();
}
bool rtc_stats_member_u64_is_defined(const RTCStatsMemberu64& stats_member) {
  return stats_member.is_defined();
}
bool rtc_stats_member_bool_is_defined(const RTCStatsMemberbool& stats_member) {
  return stats_member.is_defined();
}

std::unique_ptr<std::string> rtc_stats_member_string_value(const RTCStatsMemberString& stats_member) {
  return std::make_unique<std::string>(*stats_member);
}
double rtc_stats_member_f64_value(const RTCStatsMemberf64& stats_member) {
  return *stats_member;
}
int32_t rtc_stats_member_i32_value(const RTCStatsMemberi32& stats_member) {
  return *stats_member;
}
uint32_t rtc_stats_member_u32_value(const RTCStatsMemberu32& stats_member) {
  return *stats_member;
}
uint64_t rtc_stats_member_u64_value(const RTCStatsMemberu64& stats_member) {
  return *stats_member;
}
bool rtc_stats_member_bool_value(const RTCStatsMemberbool& stats_member) {
  return *stats_member;
}




std::unique_ptr<std::string> rtc_stats_id(const RTCStats& stats) {
  return std::make_unique<std::string>(stats.id());
}
int64_t rtc_stats_timestamp_us(const RTCStats& stats) {
  return stats.timestamp_us();
}
std::unique_ptr<std::string> rtc_stats_type(const RTCStats& stats) {
    std::string str = std::string(stats.type());
    return std::make_unique<std::string>(str);
}



std::unique_ptr<RTCMediaSourceStats> rtc_stats_cast_to_rtc_media_source_stats(std::unique_ptr<RTCStats> stats) {
  auto type = std::string(stats->type());
  if (type == "media-source") {
    return std::unique_ptr<RTCMediaSourceStats>(static_cast<RTCMediaSourceStats*>(stats.release()));
  }
  throw std::invalid_argument( "Invalid type. Expected `ice-candidate` but found " + type );
}
std::unique_ptr<RTCIceCandidateStats> rtc_stats_cast_to_rtc_ice_candidate_stats(std::unique_ptr<RTCStats> stats) {
  auto type = std::string(stats->type());
  if (type == "remote-candidate" || type == "local-candidate") {
    return std::unique_ptr<RTCIceCandidateStats>(static_cast<RTCIceCandidateStats*>(stats.release()));
  }
  throw std::invalid_argument( "Invalid type. Expected `local-candidate` or `remote-candidate` but found " + type );
}
std::unique_ptr<RTCOutboundRTPStreamStats> rtc_stats_cast_to_rtc_outbound_rtp_stream_stats(std::unique_ptr<RTCStats> stats) {
  auto type = std::string(stats->type());
  if (type == "outbound-rtp") {
    return std::unique_ptr<RTCOutboundRTPStreamStats>(static_cast<RTCOutboundRTPStreamStats*>(stats.release()));
  }
  throw std::invalid_argument( "Invalid type. Expected `outbound-rtp` but found " + type );
}
std::unique_ptr<RTCInboundRTPStreamStats> rtc_stats_cast_to_rtc_inbound_rtp_stream_stats(std::unique_ptr<RTCStats> stats) {
  auto type = std::string(stats->type());
  if (type == "inbound-rtp") {
    return std::unique_ptr<RTCInboundRTPStreamStats>(static_cast<RTCInboundRTPStreamStats*>(stats.release()));
  }
  throw std::invalid_argument( "Invalid type. Expected `inbound-rtp` but found " + type );
}
std::unique_ptr<RTCIceCandidatePairStats> rtc_stats_cast_to_rtc_ice_candidate_pair_stats(std::unique_ptr<RTCStats> stats) {
  auto type = std::string(stats->type());
  if (type == "candidate-pair") {
    return std::unique_ptr<RTCIceCandidatePairStats>(static_cast<RTCIceCandidatePairStats*>(stats.release()));
  }
  throw std::invalid_argument( "Invalid type. Expected `candidate-pair` but found " + type );

}
std::unique_ptr<RTCTransportStats> rtc_stats_cast_to_rtc_transport_stats(std::unique_ptr<RTCStats> stats) {
  auto type = std::string(stats->type());
  if (type == "transport") {
    return std::unique_ptr<RTCTransportStats>(static_cast<RTCTransportStats*>(stats.release()));
  }
  throw std::invalid_argument( "Invalid type. Expected `transport` but found " + type );

}
std::unique_ptr<RTCRemoteInboundRtpStreamStats> rtc_stats_cast_to_rtc_remote_inbound_rtp_stream_stats(std::unique_ptr<RTCStats> stats) {
  auto type = std::string(stats->type());
  if (type == "remote-inbound-rtp") {
    return std::unique_ptr<RTCRemoteInboundRtpStreamStats>(static_cast<RTCRemoteInboundRtpStreamStats*>(stats.release()));
  }
  throw std::invalid_argument( "Invalid type. Expected `remote-inbound-rtp` but found " + type );

}
std::unique_ptr<RTCRemoteOutboundRtpStreamStats> rtc_stats_cast_to_rtc_remote_outbound_rtp_stream_stats(std::unique_ptr<RTCStats> stats) {
  auto type = std::string(stats->type());
  if (type == "remote-outbound-rtp") {
    return std::unique_ptr<RTCRemoteOutboundRtpStreamStats>(static_cast<RTCRemoteOutboundRtpStreamStats*>(stats.release()));
  }
  throw std::invalid_argument( "Invalid type. Expected `remote-outbound-rtp` but found " + type );
}

std::unique_ptr<RTCVideoSourceStats> rtc_media_source_stats_cast_to_rtc_video_source_stats(std::unique_ptr<RTCMediaSourceStats> stats) {
  auto kind = *stats->kind;
  if (kind == "video") {
    return std::unique_ptr<RTCVideoSourceStats>(static_cast<RTCVideoSourceStats*>(stats.release()));
  }
  throw std::invalid_argument( "Invalid kind. Expected `video` but found " + kind );
}
std::unique_ptr<RTCAudioSourceStats> rtc_media_source_stats_cast_to_rtc_audio_source_stats(std::unique_ptr<RTCMediaSourceStats> stats) {
  auto kind = *stats->kind;
  if (kind == "audio") {
    return std::unique_ptr<RTCAudioSourceStats>(static_cast<RTCAudioSourceStats*>(stats.release()));
  }
  throw std::invalid_argument( "Invalid kind. Expected `audio` but found " + kind );
}


// RTCMediaSourceStats
std::unique_ptr<RTCStatsMemberString> rtc_media_source_stats_track_identifier(
    const RTCMediaSourceStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.track_identifier);
}
std::unique_ptr<RTCStatsMemberString> rtc_media_source_stats_kind(
    const RTCMediaSourceStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.kind);
}
/// RTCMediaSourceStats


//RTCVideoSourceStats
std::unique_ptr<RTCStatsMemberu32> rtc_video_source_stats_width(
    const RTCVideoSourceStats& stats) {
      return std::make_unique<RTCStatsMemberu32>(stats.width);
    }
std::unique_ptr<RTCStatsMemberu32> rtc_video_source_stats_height(
    const RTCVideoSourceStats& stats) {
      return std::make_unique<RTCStatsMemberu32>(stats.height);
    }
std::unique_ptr<RTCStatsMemberu32> rtc_video_source_stats_frames(
    const RTCVideoSourceStats& stats) {
      return std::make_unique<RTCStatsMemberu32>(stats.frames);
    }
std::unique_ptr<RTCStatsMemberf64> rtc_video_source_stats_frames_per_second(
    const RTCVideoSourceStats& stats) {
      return std::make_unique<RTCStatsMemberf64>(stats.frames_per_second);
    }
/// RTCMediaSourceStats 


// RTCAudioSourceStats
std::unique_ptr<RTCStatsMemberf64> rtc_audio_source_stats_audio_level(
    const RTCAudioSourceStats& stats) {
      return std::make_unique<RTCStatsMemberf64>(stats.audio_level);
    }
std::unique_ptr<RTCStatsMemberf64> rtc_audio_source_stats_total_audio_energy(
    const RTCAudioSourceStats& stats) {
      return std::make_unique<RTCStatsMemberf64>(stats.total_audio_energy);
    }
std::unique_ptr<RTCStatsMemberf64> rtc_audio_source_stats_total_samples_duration(
    const RTCAudioSourceStats& stats) {
      return std::make_unique<RTCStatsMemberf64>(stats.total_samples_duration);
    }
std::unique_ptr<RTCStatsMemberf64> rtc_audio_source_stats_echo_return_loss(
    const RTCAudioSourceStats& stats) {
      return std::make_unique<RTCStatsMemberf64>(stats.echo_return_loss);
    }
std::unique_ptr<RTCStatsMemberf64> rtc_audio_source_stats_echo_return_loss_enhancement(
    const RTCAudioSourceStats& stats) {
      return std::make_unique<RTCStatsMemberf64>(stats.echo_return_loss_enhancement);
    }
/// RTCAudioSourceStats




// RTCIceCandidateStats
// std::unique_ptr<RTCIceCandidateStats> RTCStats_cast_to_RTCIceCandidateStats(
//     const RTCStats& stats) {
//   std::make_unique<RTCIceCandidateStats>(
//       RTCIceCandidateStats(stats.cast_to<RTCIceCandidateStats>()));
// }
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_stats_transport_id(
    const RTCIceCandidateStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.transport_id);
}
std::unique_ptr<RTCStatsMemberbool> rtc_ice_candidate_stats_is_remote(const RTCIceCandidateStats& stats) {
  return std::make_unique<RTCStatsMemberbool>(stats.is_remote);
}
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_stats_network_type(
    const RTCIceCandidateStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.network_type);
}
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_stats_ip(
    const RTCIceCandidateStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.ip);
}
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_stats_address(
    const RTCIceCandidateStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.address);
}
std::unique_ptr<RTCStatsMemberi32> rtc_ice_candidate_stats_port(const RTCIceCandidateStats& stats) {
  return std::make_unique<RTCStatsMemberi32>(stats.port);
}
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_stats_protocol(
    const RTCIceCandidateStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.protocol);
}
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_stats_relay_protocol(
    const RTCIceCandidateStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.relay_protocol);
}
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_stats_candidate_type(
    const RTCIceCandidateStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.candidate_type);
}
std::unique_ptr<RTCStatsMemberi32> rtc_ice_candidate_stats_priority(const RTCIceCandidateStats& stats) {
  return std::make_unique<RTCStatsMemberi32>(stats.priority);
}
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_stats_url(
    const RTCIceCandidateStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.url);
}
std::unique_ptr<RTCStatsMemberbool> rtc_ice_candidate_stats_vpn(const RTCIceCandidateStats& stats) {
  return std::make_unique<RTCStatsMemberbool>(stats.vpn);
}
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_stats_network_adapter_type(
    const RTCIceCandidateStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.network_adapter_type);
}
/// RTCIceCandidateStats

// RTCOutboundRTPStreamStats
// std::unique_ptr<RTCOutboundRTPStreamStats>
// RTCStats_cast_to_RTCOutboundRTPStreamStats(const RTCStats& stats) {
//   std::make_unique<RTCOutboundRTPStreamStats>(
//       RTCOutboundRTPStreamStats(stats.cast_to<RTCOutboundRTPStreamStats>()));
// }
std::unique_ptr<RTCStatsMemberString> rtc_outbound_rtp_stream_stats_track_id(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.track_id);
}
std::unique_ptr<RTCStatsMemberString> rtc_outbound_rtp_stream_stats_kind(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.kind);
}
std::unique_ptr<RTCStatsMemberString> rtc_outbound_rtp_stream_stats_media_source_id(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.media_source_id);
}
std::unique_ptr<RTCStatsMemberString> rtc_outbound_rtp_stream_stats_remote_id(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.remote_id);
}
std::unique_ptr<RTCStatsMemberString> rtc_outbound_rtp_stream_stats_rid(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.rid);
}
std::unique_ptr<RTCStatsMemberu32> rtc_outbound_rtp_stream_stats_packets_sent(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.packets_sent);
}
std::unique_ptr<RTCStatsMemberu64> rtc_outbound_rtp_stream_stats_retransmitted_packets_sent(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.retransmitted_packets_sent);
}
std::unique_ptr<RTCStatsMemberu64> rtc_outbound_rtp_stream_stats_bytes_sent(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.bytes_sent);
}
std::unique_ptr<RTCStatsMemberu64> rtc_outbound_rtp_stream_stats_header_bytes_sent(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.header_bytes_sent);
}
std::unique_ptr<RTCStatsMemberu64> rtc_outbound_rtp_stream_stats_retransmitted_bytes_sent(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.retransmitted_bytes_sent);
}
std::unique_ptr<RTCStatsMemberf64> rtc_outbound_rtp_stream_stats_target_bitrate(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.target_bitrate);
}
std::unique_ptr<RTCStatsMemberu32> rtc_outbound_rtp_stream_stats_frames_encoded(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.frames_encoded);
}
std::unique_ptr<RTCStatsMemberu32> rtc_outbound_rtp_stream_stats_key_frames_encoded(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.key_frames_encoded);
}
std::unique_ptr<RTCStatsMemberf64> rtc_outbound_rtp_stream_stats_total_encode_time(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.total_encode_time);
}
std::unique_ptr<RTCStatsMemberu64> rtc_outbound_rtp_stream_stats_total_encoded_bytes_target(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.total_encoded_bytes_target);
}
std::unique_ptr<RTCStatsMemberu32> rtc_outbound_rtp_stream_stats_frame_width(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.frame_width);
}
std::unique_ptr<RTCStatsMemberu32> rtc_outbound_rtp_stream_stats_frame_height(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.frame_height);
}
std::unique_ptr<RTCStatsMemberf64> rtc_outbound_rtp_stream_stats_frames_per_second(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.frames_per_second);
}
std::unique_ptr<RTCStatsMemberu32> rtc_outbound_rtp_stream_stats_frames_sent(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.frames_sent);
}
std::unique_ptr<RTCStatsMemberu32> rtc_outbound_rtp_stream_stats_huge_frames_sent(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.huge_frames_sent);
}
std::unique_ptr<RTCStatsMemberf64> rtc_outbound_rtp_stream_stats_total_packet_send_delay(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.total_packet_send_delay);
}
std::unique_ptr<RTCStatsMemberString>
rtc_outbound_rtp_stream_stats_quality_limitation_reason(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.quality_limitation_reason);
}
// todo
//   RTCStatsMember<std::map<std::string, double>> quality_limitation_durations
//   {return std::make_unique<RTCStatsMember>(stats.;}
std::unique_ptr<RTCStatsMemberu32> rtc_outbound_rtp_stream_stats_quality_limitation_resolution_changes(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.quality_limitation_resolution_changes);
}
std::unique_ptr<RTCStatsMemberString> rtc_outbound_rtp_stream_stats_content_type(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.content_type);
}
std::unique_ptr<RTCStatsMemberString> rtc_outbound_rtp_stream_stats_encoder_implementation(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.encoder_implementation);
}
std::unique_ptr<RTCStatsMemberu32> rtc_outbound_rtp_stream_stats_fir_count(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.fir_count);
}
std::unique_ptr<RTCStatsMemberu32> rtc_outbound_rtp_stream_stats_pli_count(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.pli_count);
}
std::unique_ptr<RTCStatsMemberu32> rtc_outbound_rtp_stream_stats_nack_count(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.nack_count);
}
std::unique_ptr<RTCStatsMemberu64> rtc_outbound_rtp_stream_stats_qp_sum(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.qp_sum);
}
/// RTCOutboundRTPStreamStats

// RTCInboundRTPStreamStats
// std::unique_ptr<RTCInboundRTPStreamStats>
// RTCStats_cast_to_RTCInboundRTPStreamStats(const RTCStats& stats) {
//   std::make_unique<RTCInboundRTPStreamStats>(
//       RTCInboundRTPStreamStats(stats.cast_to<RTCInboundRTPStreamStats>()));
// }
std::unique_ptr<RTCStatsMemberString> rtc_inbound_rtp_stream_stats_remote_id(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.remote_id);
}
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_packets_received(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.packets_received);
}
std::unique_ptr<RTCStatsMemberu64> rtc_inbound_rtp_stream_stats_fec_packets_received(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.fec_packets_received);
}
std::unique_ptr<RTCStatsMemberu64> rtc_inbound_rtp_stream_stats_fec_packets_discarded(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.fec_packets_discarded);
}
std::unique_ptr<RTCStatsMemberu64> rtc_inbound_rtp_stream_stats_bytes_received(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.bytes_received);
}
std::unique_ptr<RTCStatsMemberu64> rtc_inbound_rtp_stream_stats_header_bytes_received(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.header_bytes_received);
}
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_last_packet_received_timestamp(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.last_packet_received_timestamp);
}
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_jitter_buffer_delay(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.jitter_buffer_delay);
}
std::unique_ptr<RTCStatsMemberu64> rtc_inbound_rtp_stream_stats_jitter_buffer_emitted_count(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.jitter_buffer_emitted_count);
}
std::unique_ptr<RTCStatsMemberu64> rtc_inbound_rtp_stream_stats_total_samples_received(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.total_samples_received);
}
std::unique_ptr<RTCStatsMemberu64> rtc_inbound_rtp_stream_stats_concealed_samples(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.concealed_samples);
}
std::unique_ptr<RTCStatsMemberu64> rtc_inbound_rtp_stream_stats_silent_concealed_samples(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.silent_concealed_samples);
}
std::unique_ptr<RTCStatsMemberu64> rtc_inbound_rtp_stream_stats_concealment_events(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.concealment_events);
}
std::unique_ptr<RTCStatsMemberu64> rtc_inbound_rtp_stream_stats_inserted_samples_for_deceleration(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.inserted_samples_for_deceleration);
}
std::unique_ptr<RTCStatsMemberu64> rtc_inbound_rtp_stream_stats_removed_samples_for_acceleration(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.removed_samples_for_acceleration);
}
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_audio_level(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.audio_level);
}
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_total_audio_energy(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.total_audio_energy);
}
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_total_samples_duration(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.total_samples_duration);
}
std::unique_ptr<RTCStatsMemberi32> rtc_inbound_rtp_stream_stats_frames_received(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberi32>(stats.frames_received);
}
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_round_trip_time(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.round_trip_time);
}
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_packets_repaired(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.packets_repaired);
}
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_burst_packets_lost(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.burst_packets_lost);
}
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_burst_packets_discarded(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.burst_packets_discarded);
}
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_burst_loss_count(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.burst_loss_count);
}
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_burst_discard_count(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.burst_discard_count);
}
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_burst_loss_rate(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.burst_loss_rate);
}
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_burst_discard_rate(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.burst_discard_rate);
}
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_gap_loss_rate(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.gap_loss_rate);
}
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_gap_discard_rate(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.gap_discard_rate);
}
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_frame_width(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.frame_width);
}
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_frame_height(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.frame_height);
}
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_frame_bit_depth(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.frame_bit_depth);
}
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_frames_per_second(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.frames_per_second);
}
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_frames_decoded(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.frames_decoded);
}
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_key_frames_decoded(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.key_frames_decoded);
}
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_frames_dropped(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.frames_dropped);
}
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_total_decode_time(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.total_decode_time);
}
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_total_inter_frame_delay(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.total_inter_frame_delay);
}
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_total_squared_inter_frame_delay(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.total_squared_inter_frame_delay);
}
std::unique_ptr<RTCStatsMemberString> rtc_inbound_rtp_stream_stats_content_type(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.content_type);
}
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_estimated_playout_timestamp(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.estimated_playout_timestamp);
}
std::unique_ptr<RTCStatsMemberString> rtc_inbound_rtp_stream_stats_decoder_implementation(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.decoder_implementation);
}
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_fir_count(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.fir_count);
}
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_pli_count(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.pli_count);
}
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_nack_count(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.nack_count);
}
std::unique_ptr<RTCStatsMemberu64> rtc_inbound_rtp_stream_stats_qp_sum(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.qp_sum);
}
/// RTCInboundRTPStreamStats

// RTCIceCandidatePairStats
// std::unique_ptr<RTCIceCandidatePairStats>
// RTCStats_cast_to_RTCIceCandidatePairStats(const RTCStats& stats) {
//   std::make_unique<RTCIceCandidatePairStats>(
//       RTCIceCandidatePairStats(stats.cast_to<RTCIceCandidatePairStats>()));
// }

std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_pair_stats_transport_id(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.transport_id);
}
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_pair_stats_local_candidate_id(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.local_candidate_id);
}
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_pair_stats_remote_candidate_id(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.remote_candidate_id);
}
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_pair_stats_state(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.state);
}
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_priority(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.priority);
}
std::unique_ptr<RTCStatsMemberbool> rtc_ice_candidate_pair_stats_nominated(const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberbool>(stats.nominated);
}
std::unique_ptr<RTCStatsMemberbool> rtc_ice_candidate_pair_stats_writable(const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberbool>(stats.writable);
}
std::unique_ptr<RTCStatsMemberbool> rtc_ice_candidate_pair_stats_readable(const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberbool>(stats.readable);
}
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_packets_sent(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.packets_sent);
}
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_packets_received(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.packets_received);
}
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_bytes_sent(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.bytes_sent);
}
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_bytes_received(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.bytes_received);
}
std::unique_ptr<RTCStatsMemberf64> rtc_ice_candidate_pair_stats_total_round_trip_time(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.total_round_trip_time);
}
std::unique_ptr<RTCStatsMemberf64> rtc_ice_candidate_pair_stats_current_round_trip_time(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.current_round_trip_time);
}
std::unique_ptr<RTCStatsMemberf64> rtc_ice_candidate_pair_stats_available_outgoing_bitrate(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.available_outgoing_bitrate);
}
std::unique_ptr<RTCStatsMemberf64> rtc_ice_candidate_pair_stats_available_incoming_bitrate(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.available_incoming_bitrate);
}
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_requests_received(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.requests_received);
}
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_requests_sent(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.requests_sent);
}
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_responses_received(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.responses_received);
}
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_responses_sent(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.responses_sent);
}
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_retransmissions_received(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.retransmissions_received);
}
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_retransmissions_sent(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.retransmissions_sent);
}
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_consent_requests_received(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.consent_requests_received);
}
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_consent_requests_sent(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.consent_requests_sent);
}
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_consent_responses_received(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.consent_responses_received);
}
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_consent_responses_sent(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.consent_responses_sent);
}
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_packets_discarded_on_send(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.packets_discarded_on_send);
}
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_bytes_discarded_on_send(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.bytes_discarded_on_send);
}
/// RTCIceCandidatePairStats

// RTCTransportStats
// std::unique_ptr<RTCTransportStats> RTCStats_cast_to_RTCTransportStats(
//     const RTCStats& stats) {
//   std::make_unique<RTCTransportStats>(
//       RTCTransportStats(stats.cast_to<RTCTransportStats>()));
// }
std::unique_ptr<RTCStatsMemberu64> rtc_transport_stats_bytes_sent(const RTCTransportStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.bytes_sent);
}
std::unique_ptr<RTCStatsMemberu64> rtc_transport_stats_packets_sent(const RTCTransportStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.packets_sent);
}
std::unique_ptr<RTCStatsMemberu64> rtc_transport_stats_bytes_received(const RTCTransportStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.bytes_received);
}
std::unique_ptr<RTCStatsMemberu64> rtc_transport_stats_packets_received(const RTCTransportStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.packets_received);
}
std::unique_ptr<RTCStatsMemberString> rtc_transport_stats_rtcp_transport_stats_id(
    const RTCTransportStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.rtcp_transport_stats_id);
}
std::unique_ptr<RTCStatsMemberString> rtc_transport_stats_dtls_state(
    const RTCTransportStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.dtls_state);
}
std::unique_ptr<RTCStatsMemberString> rtc_transport_stats_selected_candidate_pair_id(
    const RTCTransportStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.selected_candidate_pair_id);
}
std::unique_ptr<RTCStatsMemberString> rtc_transport_stats_local_certificate_id(
    const RTCTransportStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.local_certificate_id);
}
std::unique_ptr<RTCStatsMemberString> rtc_transport_stats_remote_certificate_id(
    const RTCTransportStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.remote_certificate_id);
}
std::unique_ptr<RTCStatsMemberString> rtc_transport_stats_tls_version(
    const RTCTransportStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.tls_version);
}
std::unique_ptr<RTCStatsMemberString> rtc_transport_stats_dtls_cipher(
    const RTCTransportStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.dtls_cipher);
}
std::unique_ptr<RTCStatsMemberString> rtc_transport_stats_srtp_cipher(
    const RTCTransportStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.srtp_cipher);
}
std::unique_ptr<RTCStatsMemberu32> rtc_transport_stats_selected_candidate_pair_changes(
    const RTCTransportStats& stats) {
  return std::make_unique<RTCStatsMemberu32>(stats.selected_candidate_pair_changes);
}
/// RTCTransportStats

// RTCRemoteInboundRtpStreamStats
// std::unique_ptr<RTCRemoteInboundRtpStreamStats>
// RTCStats_cast_to_RTCRemoteInboundRtpStreamStats(const RTCStats& stats) {
//   std::make_unique<RTCRemoteInboundRtpStreamStats>(
//       RTCRemoteInboundRtpStreamStats(
//           stats.cast_to<RTCRemoteInboundRtpStreamStats>()));
// }
std::unique_ptr<RTCStatsMemberString> rtc_remote_inbound_rtp_stream_stats_local_id(
    const RTCRemoteInboundRtpStreamStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.local_id);
}
std::unique_ptr<RTCStatsMemberf64> rtc_remote_inbound_rtp_stream_stats_round_trip_time(
    const RTCRemoteInboundRtpStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.round_trip_time);
}
std::unique_ptr<RTCStatsMemberf64> rtc_remote_inbound_rtp_stream_stats_fraction_lost(
    const RTCRemoteInboundRtpStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.fraction_lost);
}
std::unique_ptr<RTCStatsMemberf64> rtc_remote_inbound_rtp_stream_stats_total_round_trip_time(
    const RTCRemoteInboundRtpStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.total_round_trip_time);
}
std::unique_ptr<RTCStatsMemberi32> round_trip_time_measurements(
    const RTCRemoteInboundRtpStreamStats& stats) {
  return std::make_unique<RTCStatsMemberi32>(stats.round_trip_time_measurements);
}
/// RTCRemoteInboundRtpStreamStats

std::unique_ptr<RTCStatsMemberString> rtc_remote_outbound_rtp_stream_stats_local_id(
    const RTCRemoteOutboundRtpStreamStats& stats) {
  return std::make_unique<RTCStatsMemberString>(stats.local_id);
}
std::unique_ptr<RTCStatsMemberf64> rtc_remote_outbound_rtp_stream_stats_remote_timestamp(
    const RTCRemoteOutboundRtpStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.remote_timestamp);
}
std::unique_ptr<RTCStatsMemberu64> rtc_remote_outbound_rtp_stream_stats_reports_sent(
    const RTCRemoteOutboundRtpStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.reports_sent);
}
std::unique_ptr<RTCStatsMemberf64> rtc_remote_outbound_rtp_stream_stats_round_trip_time(
    const RTCRemoteOutboundRtpStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.round_trip_time);
}
std::unique_ptr<RTCStatsMemberu64> rtc_remote_outbound_rtp_stream_stats_round_trip_time_measurements(
    const RTCRemoteOutboundRtpStreamStats& stats) {
  return std::make_unique<RTCStatsMemberu64>(stats.round_trip_time_measurements);
}
std::unique_ptr<RTCStatsMemberf64> rtc_remote_outbound_rtp_stream_stats_total_round_trip_time(
    const RTCRemoteOutboundRtpStreamStats& stats) {
  return std::make_unique<RTCStatsMemberf64>(stats.total_round_trip_time);
}
/// RTCRemoteOutboundRtpStreamStats

// todo
std::unique_ptr<std::string> stats_json(const RTCStatsReport& report) {
  return std::make_unique<std::string>(report->ToJson());
}

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


