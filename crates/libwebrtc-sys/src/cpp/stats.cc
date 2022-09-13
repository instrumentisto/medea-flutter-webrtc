#include "stats.h"
#include "libwebrtc-sys/src/bridge.rs.h"

#define MacroGetStatsOfType(T) _GetStatsOfType<T, T##Container>

namespace bridge {

template <typename A, typename B>
rust::vec<B> _GetStatsOfType(const RTCStatsReport& report) {
  auto temp = report->GetStatsOfType<A>();
  auto result = rust::vec<B>();

  printf("\n\n\nWTF1\n");
  for (const A* stats : temp) {
    printf("LENGHT__\n");
    std::unique_ptr<webrtc::RTCStats> copy =
        static_cast<const webrtc::RTCStats*>(stats)->copy();

    B stat = {std::unique_ptr<A>(static_cast<A*>(copy.release()))};
    result.push_back(std::move(stat));
  }
  return result;
}

// RTCMediaSourceStats
// std::unique_ptr<RTCMediaSourceStats> RTCStats_cast_to_RTCMediaSourceStats(
//     const RTCStats& stats) {
//   std::make_unique<RTCMediaSourceStats>(
//       RTCMediaSourceStats(stats.cast_to<RTCMediaSourceStats>()));
// }
std::unique_ptr<std::string> RTCMediaSourceStats_track_identifier(
    const RTCMediaSourceStats& stats) {
  return std::make_unique<std::string>(*stats.track_identifier);
}
std::unique_ptr<std::string> RTCMediaSourceStats_kind(
    const RTCMediaSourceStats& stats) {
  return std::make_unique<std::string>(*stats.kind);
}
/// RTCMediaSourceStats

// RTCIceCandidateStats
// std::unique_ptr<RTCIceCandidateStats> RTCStats_cast_to_RTCIceCandidateStats(
//     const RTCStats& stats) {
//   std::make_unique<RTCIceCandidateStats>(
//       RTCIceCandidateStats(stats.cast_to<RTCIceCandidateStats>()));
// }
std::unique_ptr<std::string> RTCIceCandidateStats_transport_id(
    const RTCIceCandidateStats& stats) {
  return std::make_unique<std::string>(*stats.transport_id);
}
bool RTCIceCandidateStats_is_remote(const RTCIceCandidateStats& stats) {
  return *stats.is_remote;
}
std::unique_ptr<std::string> RTCIceCandidateStats_network_type(
    const RTCIceCandidateStats& stats) {
  return std::make_unique<std::string>(*stats.network_type);
}
std::unique_ptr<std::string> RTCIceCandidateStats_ip(
    const RTCIceCandidateStats& stats) {
  return std::make_unique<std::string>(*stats.ip);
}
std::unique_ptr<std::string> RTCIceCandidateStats_address(
    const RTCIceCandidateStats& stats) {
  return std::make_unique<std::string>(*stats.address);
}
int32_t RTCIceCandidateStats_port(const RTCIceCandidateStats& stats) {
  return *stats.port;
}
std::unique_ptr<std::string> RTCIceCandidateStats_protocol(
    const RTCIceCandidateStats& stats) {
  return std::make_unique<std::string>(*stats.protocol);
}
std::unique_ptr<std::string> RTCIceCandidateStats_relay_protocol(
    const RTCIceCandidateStats& stats) {
  return std::make_unique<std::string>(*stats.relay_protocol);
}
std::unique_ptr<std::string> RTCIceCandidateStats_candidate_type(
    const RTCIceCandidateStats& stats) {
  return std::make_unique<std::string>(*stats.candidate_type);
}
int32_t RTCIceCandidateStats_priority(const RTCIceCandidateStats& stats) {
  return *stats.priority;
}
std::unique_ptr<std::string> RTCIceCandidateStats_url(
    const RTCIceCandidateStats& stats) {
  return std::make_unique<std::string>(*stats.url);
}
bool RTCIceCandidateStats_vpn(const RTCIceCandidateStats& stats) {
  return *stats.vpn;
}
std::unique_ptr<std::string> RTCIceCandidateStats_network_adapter_type(
    const RTCIceCandidateStats& stats) {
  return std::make_unique<std::string>(*stats.network_adapter_type);
}
/// RTCIceCandidateStats

// RTCOutboundRTPStreamStats
// std::unique_ptr<RTCOutboundRTPStreamStats>
// RTCStats_cast_to_RTCOutboundRTPStreamStats(const RTCStats& stats) {
//   std::make_unique<RTCOutboundRTPStreamStats>(
//       RTCOutboundRTPStreamStats(stats.cast_to<RTCOutboundRTPStreamStats>()));
// }
std::unique_ptr<std::string> RTCOutboundRTPStreamStats_track_id(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<std::string>(*stats.track_id);
}
std::unique_ptr<std::string> RTCOutboundRTPStreamStats_kind(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<std::string>(*stats.kind);
}
std::unique_ptr<std::string> RTCOutboundRTPStreamStats_media_source_id(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<std::string>(*stats.media_source_id);
}
std::unique_ptr<std::string> RTCOutboundRTPStreamStats_remote_id(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<std::string>(*stats.remote_id);
}
std::unique_ptr<std::string> RTCOutboundRTPStreamStats_rid(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<std::string>(*stats.rid);
}
uint32_t RTCOutboundRTPStreamStats_packets_sent(
    const RTCOutboundRTPStreamStats& stats) {
  return *stats.packets_sent;
}
uint64_t RTCOutboundRTPStreamStats_retransmitted_packets_sent(
    const RTCOutboundRTPStreamStats& stats) {
  return *stats.retransmitted_packets_sent;
}
uint64_t RTCOutboundRTPStreamStats_bytes_sent(
    const RTCOutboundRTPStreamStats& stats) {
  return *stats.bytes_sent;
}
uint64_t RTCOutboundRTPStreamStats_header_bytes_sent(
    const RTCOutboundRTPStreamStats& stats) {
  return *stats.header_bytes_sent;
}
uint64_t RTCOutboundRTPStreamStats_retransmitted_bytes_sent(
    const RTCOutboundRTPStreamStats& stats) {
  return *stats.retransmitted_bytes_sent;
}
double RTCOutboundRTPStreamStats_target_bitrate(
    const RTCOutboundRTPStreamStats& stats) {
  return *stats.target_bitrate;
}
uint32_t RTCOutboundRTPStreamStats_frames_encoded(
    const RTCOutboundRTPStreamStats& stats) {
  return *stats.frames_encoded;
}
uint32_t RTCOutboundRTPStreamStats_key_frames_encoded(
    const RTCOutboundRTPStreamStats& stats) {
  return *stats.key_frames_encoded;
}
double RTCOutboundRTPStreamStats_total_encode_time(
    const RTCOutboundRTPStreamStats& stats) {
  return *stats.total_encode_time;
}
uint64_t RTCOutboundRTPStreamStats_total_encoded_bytes_target(
    const RTCOutboundRTPStreamStats& stats) {
  return *stats.total_encoded_bytes_target;
}
uint32_t RTCOutboundRTPStreamStats_frame_width(
    const RTCOutboundRTPStreamStats& stats) {
  return *stats.frame_width;
}
uint32_t RTCOutboundRTPStreamStats_frame_height(
    const RTCOutboundRTPStreamStats& stats) {
  return *stats.frame_height;
}
double RTCOutboundRTPStreamStats_frames_per_second(
    const RTCOutboundRTPStreamStats& stats) {
  return *stats.frames_per_second;
}
uint32_t RTCOutboundRTPStreamStats_frames_sent(
    const RTCOutboundRTPStreamStats& stats) {
  return *stats.frames_sent;
}
uint32_t RTCOutboundRTPStreamStats_huge_frames_sent(
    const RTCOutboundRTPStreamStats& stats) {
  return *stats.huge_frames_sent;
}
double RTCOutboundRTPStreamStats_total_packet_send_delay(
    const RTCOutboundRTPStreamStats& stats) {
  return *stats.total_packet_send_delay;
}
std::unique_ptr<std::string>
RTCOutboundRTPStreamStats_quality_limitation_reason(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<std::string>(*stats.quality_limitation_reason);
}
// todo
//   RTCStatsMember<std::map<std::string, double>> quality_limitation_durations
//   {return *stats.;}
uint32_t RTCOutboundRTPStreamStats_quality_limitation_resolution_changes(
    const RTCOutboundRTPStreamStats& stats) {
  return *stats.quality_limitation_resolution_changes;
}
std::unique_ptr<std::string> RTCOutboundRTPStreamStats_content_type(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<std::string>(*stats.content_type);
}
std::unique_ptr<std::string> RTCOutboundRTPStreamStats_encoder_implementation(
    const RTCOutboundRTPStreamStats& stats) {
  return std::make_unique<std::string>(*stats.encoder_implementation);
}
uint32_t RTCOutboundRTPStreamStats_fir_count(
    const RTCOutboundRTPStreamStats& stats) {
  return *stats.fir_count;
}
uint32_t RTCOutboundRTPStreamStats_pli_count(
    const RTCOutboundRTPStreamStats& stats) {
  return *stats.pli_count;
}
uint32_t RTCOutboundRTPStreamStats_nack_count(
    const RTCOutboundRTPStreamStats& stats) {
  return *stats.nack_count;
}
uint64_t RTCOutboundRTPStreamStats_qp_sum(
    const RTCOutboundRTPStreamStats& stats) {
  return *stats.qp_sum;
}
/// RTCOutboundRTPStreamStats

// RTCInboundRTPStreamStats
// std::unique_ptr<RTCInboundRTPStreamStats>
// RTCStats_cast_to_RTCInboundRTPStreamStats(const RTCStats& stats) {
//   std::make_unique<RTCInboundRTPStreamStats>(
//       RTCInboundRTPStreamStats(stats.cast_to<RTCInboundRTPStreamStats>()));
// }
std::unique_ptr<std::string> RTCInboundRTPStreamStats_remote_id(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<std::string>(*stats.remote_id);
}
uint32_t RTCInboundRTPStreamStats_packets_received(
    const RTCInboundRTPStreamStats& stats) {
  return *stats.packets_received;
}
uint64_t RTCInboundRTPStreamStats_fec_packets_received(
    const RTCInboundRTPStreamStats& stats) {
  return *stats.fec_packets_received;
}
uint64_t RTCInboundRTPStreamStats_fec_packets_discarded(
    const RTCInboundRTPStreamStats& stats) {
  return *stats.fec_packets_discarded;
}
uint64_t RTCInboundRTPStreamStats_bytes_received(
    const RTCInboundRTPStreamStats& stats) {
  return *stats.bytes_received;
}
uint64_t RTCInboundRTPStreamStats_header_bytes_received(
    const RTCInboundRTPStreamStats& stats) {
  return *stats.header_bytes_received;
}
double RTCInboundRTPStreamStats_last_packet_received_timestamp(
    const RTCInboundRTPStreamStats& stats) {
  return *stats.last_packet_received_timestamp;
}
double RTCInboundRTPStreamStats_jitter_buffer_delay(
    const RTCInboundRTPStreamStats& stats) {
  return *stats.jitter_buffer_delay;
}
uint64_t RTCInboundRTPStreamStats_jitter_buffer_emitted_count(
    const RTCInboundRTPStreamStats& stats) {
  return *stats.jitter_buffer_emitted_count;
}
uint64_t RTCInboundRTPStreamStats_total_samples_received(
    const RTCInboundRTPStreamStats& stats) {
  return *stats.total_samples_received;
}
uint64_t RTCInboundRTPStreamStats_concealed_samples(
    const RTCInboundRTPStreamStats& stats) {
  return *stats.concealed_samples;
}
uint64_t RTCInboundRTPStreamStats_silent_concealed_samples(
    const RTCInboundRTPStreamStats& stats) {
  return *stats.silent_concealed_samples;
}
uint64_t RTCInboundRTPStreamStats_concealment_events(
    const RTCInboundRTPStreamStats& stats) {
  return *stats.concealment_events;
}
uint64_t RTCInboundRTPStreamStats_inserted_samples_for_deceleration(
    const RTCInboundRTPStreamStats& stats) {
  return *stats.inserted_samples_for_deceleration;
}
uint64_t RTCInboundRTPStreamStats_removed_samples_for_acceleration(
    const RTCInboundRTPStreamStats& stats) {
  return *stats.removed_samples_for_acceleration;
}
double RTCInboundRTPStreamStats_audio_level(
    const RTCInboundRTPStreamStats& stats) {
  return *stats.audio_level;
}
double RTCInboundRTPStreamStats_total_audio_energy(
    const RTCInboundRTPStreamStats& stats) {
  return *stats.total_audio_energy;
}
double RTCInboundRTPStreamStats_total_samples_duration(
    const RTCInboundRTPStreamStats& stats) {
  return *stats.total_samples_duration;
}
int32_t RTCInboundRTPStreamStats_frames_received(
    const RTCInboundRTPStreamStats& stats) {
  return *stats.frames_received;
}
double RTCInboundRTPStreamStats_round_trip_time(
    const RTCInboundRTPStreamStats& stats) {
  return *stats.round_trip_time;
}
uint32_t RTCInboundRTPStreamStats_packets_repaired(
    const RTCInboundRTPStreamStats& stats) {
  return *stats.packets_repaired;
}
uint32_t RTCInboundRTPStreamStats_burst_packets_lost(
    const RTCInboundRTPStreamStats& stats) {
  return *stats.burst_packets_lost;
}
uint32_t RTCInboundRTPStreamStats_burst_packets_discarded(
    const RTCInboundRTPStreamStats& stats) {
  return *stats.burst_packets_discarded;
}
uint32_t RTCInboundRTPStreamStats_burst_loss_count(
    const RTCInboundRTPStreamStats& stats) {
  return *stats.burst_loss_count;
}
uint32_t RTCInboundRTPStreamStats_burst_discard_count(
    const RTCInboundRTPStreamStats& stats) {
  return *stats.burst_discard_count;
}
double RTCInboundRTPStreamStats_burst_loss_rate(
    const RTCInboundRTPStreamStats& stats) {
  return *stats.burst_loss_rate;
}
double RTCInboundRTPStreamStats_burst_discard_rate(
    const RTCInboundRTPStreamStats& stats) {
  return *stats.burst_discard_rate;
}
double RTCInboundRTPStreamStats_gap_loss_rate(
    const RTCInboundRTPStreamStats& stats) {
  return *stats.gap_loss_rate;
}
double RTCInboundRTPStreamStats_gap_discard_rate(
    const RTCInboundRTPStreamStats& stats) {
  return *stats.gap_discard_rate;
}
uint32_t RTCInboundRTPStreamStats_frame_width(
    const RTCInboundRTPStreamStats& stats) {
  return *stats.frame_width;
}
uint32_t RTCInboundRTPStreamStats_frame_height(
    const RTCInboundRTPStreamStats& stats) {
  return *stats.frame_height;
}
uint32_t RTCInboundRTPStreamStats_frame_bit_depth(
    const RTCInboundRTPStreamStats& stats) {
  return *stats.frame_bit_depth;
}
double RTCInboundRTPStreamStats_frames_per_second(
    const RTCInboundRTPStreamStats& stats) {
  return *stats.frames_per_second;
}
uint32_t RTCInboundRTPStreamStats_frames_decoded(
    const RTCInboundRTPStreamStats& stats) {
  return *stats.frames_decoded;
}
uint32_t RTCInboundRTPStreamStats_key_frames_decoded(
    const RTCInboundRTPStreamStats& stats) {
  return *stats.key_frames_decoded;
}
uint32_t RTCInboundRTPStreamStats_frames_dropped(
    const RTCInboundRTPStreamStats& stats) {
  return *stats.frames_dropped;
}
double RTCInboundRTPStreamStats_total_decode_time(
    const RTCInboundRTPStreamStats& stats) {
  return *stats.total_decode_time;
}
double RTCInboundRTPStreamStats_total_inter_frame_delay(
    const RTCInboundRTPStreamStats& stats) {
  return *stats.total_inter_frame_delay;
}
double RTCInboundRTPStreamStats_total_squared_inter_frame_delay(
    const RTCInboundRTPStreamStats& stats) {
  return *stats.total_squared_inter_frame_delay;
}
std::unique_ptr<std::string> RTCInboundRTPStreamStats_content_type(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<std::string>(*stats.content_type);
}
double RTCInboundRTPStreamStats_estimated_playout_timestamp(
    const RTCInboundRTPStreamStats& stats) {
  return *stats.estimated_playout_timestamp;
}
std::unique_ptr<std::string> RTCInboundRTPStreamStats_decoder_implementation(
    const RTCInboundRTPStreamStats& stats) {
  return std::make_unique<std::string>(*stats.decoder_implementation);
}
uint32_t RTCInboundRTPStreamStats_fir_count(
    const RTCInboundRTPStreamStats& stats) {
  return *stats.fir_count;
}
uint32_t RTCInboundRTPStreamStats_pli_count(
    const RTCInboundRTPStreamStats& stats) {
  return *stats.pli_count;
}
uint32_t RTCInboundRTPStreamStats_nack_count(
    const RTCInboundRTPStreamStats& stats) {
  return *stats.nack_count;
}
uint64_t RTCInboundRTPStreamStats_qp_sum(
    const RTCInboundRTPStreamStats& stats) {
  return *stats.qp_sum;
}
/// RTCInboundRTPStreamStats

// RTCIceCandidatePairStats
// std::unique_ptr<RTCIceCandidatePairStats>
// RTCStats_cast_to_RTCIceCandidatePairStats(const RTCStats& stats) {
//   std::make_unique<RTCIceCandidatePairStats>(
//       RTCIceCandidatePairStats(stats.cast_to<RTCIceCandidatePairStats>()));
// }

std::unique_ptr<std::string> RTCIceCandidatePairStats_transport_id(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<std::string>(*stats.transport_id);
}
std::unique_ptr<std::string> RTCIceCandidatePairStats_local_candidate_id(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<std::string>(*stats.local_candidate_id);
}
std::unique_ptr<std::string> RTCIceCandidatePairStats_remote_candidate_id(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<std::string>(*stats.remote_candidate_id);
}
std::unique_ptr<std::string> RTCIceCandidatePairStats_state(
    const RTCIceCandidatePairStats& stats) {
  return std::make_unique<std::string>(*stats.state);
}
uint64_t RTCIceCandidatePairStats_priority(
    const RTCIceCandidatePairStats& stats) {
  return *stats.priority;
}
bool RTCIceCandidatePairStats_nominated(const RTCIceCandidatePairStats& stats) {
  return *stats.nominated;
}
bool RTCIceCandidatePairStats_writable(const RTCIceCandidatePairStats& stats) {
  return *stats.writable;
}
bool RTCIceCandidatePairStats_readable(const RTCIceCandidatePairStats& stats) {
  return *stats.readable;
}
uint64_t RTCIceCandidatePairStats_packets_sent(
    const RTCIceCandidatePairStats& stats) {
  return *stats.packets_sent;
}
uint64_t RTCIceCandidatePairStats_packets_received(
    const RTCIceCandidatePairStats& stats) {
  return *stats.packets_received;
}
uint64_t RTCIceCandidatePairStats_bytes_sent(
    const RTCIceCandidatePairStats& stats) {
  return *stats.bytes_sent;
}
uint64_t RTCIceCandidatePairStats_bytes_received(
    const RTCIceCandidatePairStats& stats) {
  return *stats.bytes_received;
}
bool RTCIceCandidatePairStats_total_round_trip_time(
    const RTCIceCandidatePairStats& stats) {
  return *stats.total_round_trip_time;
}
bool RTCIceCandidatePairStats_current_round_trip_time(
    const RTCIceCandidatePairStats& stats) {
  return *stats.current_round_trip_time;
}
bool RTCIceCandidatePairStats_available_outgoing_bitrate(
    const RTCIceCandidatePairStats& stats) {
  return *stats.available_outgoing_bitrate;
}
bool RTCIceCandidatePairStats_available_incoming_bitrate(
    const RTCIceCandidatePairStats& stats) {
  return *stats.available_incoming_bitrate;
}
uint64_t RTCIceCandidatePairStats_requests_received(
    const RTCIceCandidatePairStats& stats) {
  return *stats.requests_received;
}
uint64_t RTCIceCandidatePairStats_requests_sent(
    const RTCIceCandidatePairStats& stats) {
  return *stats.requests_sent;
}
uint64_t RTCIceCandidatePairStats_responses_received(
    const RTCIceCandidatePairStats& stats) {
  return *stats.responses_received;
}
uint64_t RTCIceCandidatePairStats_responses_sent(
    const RTCIceCandidatePairStats& stats) {
  return *stats.responses_sent;
}
uint64_t RTCIceCandidatePairStats_retransmissions_received(
    const RTCIceCandidatePairStats& stats) {
  return *stats.retransmissions_received;
}
uint64_t RTCIceCandidatePairStats_retransmissions_sent(
    const RTCIceCandidatePairStats& stats) {
  return *stats.retransmissions_sent;
}
uint64_t RTCIceCandidatePairStats_consent_requests_received(
    const RTCIceCandidatePairStats& stats) {
  return *stats.consent_requests_received;
}
uint64_t RTCIceCandidatePairStats_consent_requests_sent(
    const RTCIceCandidatePairStats& stats) {
  return *stats.consent_requests_sent;
}
uint64_t RTCIceCandidatePairStats_consent_responses_received(
    const RTCIceCandidatePairStats& stats) {
  return *stats.consent_responses_received;
}
uint64_t RTCIceCandidatePairStats_consent_responses_sent(
    const RTCIceCandidatePairStats& stats) {
  return *stats.consent_responses_sent;
}
uint64_t RTCIceCandidatePairStats_packets_discarded_on_send(
    const RTCIceCandidatePairStats& stats) {
  return *stats.packets_discarded_on_send;
}
uint64_t RTCIceCandidatePairStats_bytes_discarded_on_send(
    const RTCIceCandidatePairStats& stats) {
  return *stats.bytes_discarded_on_send;
}
/// RTCIceCandidatePairStats

// RTCTransportStats
// std::unique_ptr<RTCTransportStats> RTCStats_cast_to_RTCTransportStats(
//     const RTCStats& stats) {
//   std::make_unique<RTCTransportStats>(
//       RTCTransportStats(stats.cast_to<RTCTransportStats>()));
// }
uint64_t RTCTransportStats_bytes_sent(const RTCTransportStats& stats) {
  return *stats.bytes_sent;
}
uint64_t RTCTransportStats_packets_sent(const RTCTransportStats& stats) {
  return *stats.packets_sent;
}
uint64_t RTCTransportStats_bytes_received(const RTCTransportStats& stats) {
  return *stats.bytes_received;
}
uint64_t RTCTransportStats_packets_received(const RTCTransportStats& stats) {
  return *stats.packets_received;
}
std::unique_ptr<std::string> RTCTransportStats_rtcp_transport_stats_id(
    const RTCTransportStats& stats) {
  return std::make_unique<std::string>(*stats.rtcp_transport_stats_id);
}
std::unique_ptr<std::string> RTCTransportStats_dtls_state(
    const RTCTransportStats& stats) {
  return std::make_unique<std::string>(*stats.dtls_state);
}
std::unique_ptr<std::string> RTCTransportStats_selected_candidate_pair_id(
    const RTCTransportStats& stats) {
  return std::make_unique<std::string>(*stats.selected_candidate_pair_id);
}
std::unique_ptr<std::string> RTCTransportStats_local_certificate_id(
    const RTCTransportStats& stats) {
  return std::make_unique<std::string>(*stats.local_certificate_id);
}
std::unique_ptr<std::string> RTCTransportStats_remote_certificate_id(
    const RTCTransportStats& stats) {
  return std::make_unique<std::string>(*stats.remote_certificate_id);
}
std::unique_ptr<std::string> RTCTransportStats_tls_version(
    const RTCTransportStats& stats) {
  return std::make_unique<std::string>(*stats.tls_version);
}
std::unique_ptr<std::string> RTCTransportStats_dtls_cipher(
    const RTCTransportStats& stats) {
  return std::make_unique<std::string>(*stats.dtls_cipher);
}
std::unique_ptr<std::string> RTCTransportStats_srtp_cipher(
    const RTCTransportStats& stats) {
  return std::make_unique<std::string>(*stats.srtp_cipher);
}
uint32_t RTCTransportStats_selected_candidate_pair_changes(
    const RTCTransportStats& stats) {
  return *stats.selected_candidate_pair_changes;
}
/// RTCTransportStats

// RTCRemoteInboundRtpStreamStats
// std::unique_ptr<RTCRemoteInboundRtpStreamStats>
// RTCStats_cast_to_RTCRemoteInboundRtpStreamStats(const RTCStats& stats) {
//   std::make_unique<RTCRemoteInboundRtpStreamStats>(
//       RTCRemoteInboundRtpStreamStats(
//           stats.cast_to<RTCRemoteInboundRtpStreamStats>()));
// }
std::unique_ptr<std::string> RTCRemoteInboundRtpStreamStats_local_id(
    const RTCRemoteInboundRtpStreamStats& stats) {
  return std::make_unique<std::string>(*stats.local_id);
}
double RTCRemoteInboundRtpStreamStats_round_trip_time(
    const RTCRemoteInboundRtpStreamStats& stats) {
  return *stats.round_trip_time;
}
double RTCRemoteInboundRtpStreamStats_fraction_lost(
    const RTCRemoteInboundRtpStreamStats& stats) {
  return *stats.fraction_lost;
}
double RTCRemoteInboundRtpStreamStats_total_round_trip_time(
    const RTCRemoteInboundRtpStreamStats& stats) {
  return *stats.total_round_trip_time;
}
int32_t RTCRemoteInboundRtpStreamStats_round_trip_time_measurements(
    const RTCRemoteInboundRtpStreamStats& stats) {
  return *stats.round_trip_time_measurements;
}
/// RTCRemoteInboundRtpStreamStats

// RTCRemoteOutboundRtpStreamStats
// std::unique_ptr<RTCRemoteOutboundRtpStreamStats>
// RTCStats_cast_to_RTCRemoteOutboundRtpStreamStats(const RTCStats& stats) {
//   std::make_unique<RTCRemoteOutboundRtpStreamStats>(
//       RTCRemoteOutboundRtpStreamStats(
//           stats.cast_to<RTCRemoteOutboundRtpStreamStats>()));
// }

std::unique_ptr<std::string> RTCRemoteOutboundRtpStreamStats_local_id(
    const RTCRemoteOutboundRtpStreamStats& stats) {
  return std::make_unique<std::string>(*stats.local_id);
}
double RTCRemoteOutboundRtpStreamStats_remote_timestamp(
    const RTCRemoteOutboundRtpStreamStats& stats) {
  return *stats.remote_timestamp;
}
uint64_t RTCRemoteOutboundRtpStreamStats_reports_sent(
    const RTCRemoteOutboundRtpStreamStats& stats) {
  return *stats.reports_sent;
}
double RTCRemoteOutboundRtpStreamStats_round_trip_time(
    const RTCRemoteOutboundRtpStreamStats& stats) {
  return *stats.round_trip_time;
}
uint64_t RTCRemoteOutboundRtpStreamStats_round_trip_time_measurements(
    const RTCRemoteOutboundRtpStreamStats& stats) {
  return *stats.round_trip_time_measurements;
}
double RTCRemoteOutboundRtpStreamStats_total_round_trip_time(
    const RTCRemoteOutboundRtpStreamStats& stats) {
  return *stats.total_round_trip_time;
}
/// RTCRemoteOutboundRtpStreamStats

// todo
std::unique_ptr<std::string> stats_json(const RTCStatsReport& report) {
  return std::make_unique<std::string>(report->ToJson());
}

rust::Vec<RTCMediaSourceStatsContainer> get_stats_RTCMediaSourceStats(
    const RTCStatsReport& report) {
  return MacroGetStatsOfType(RTCMediaSourceStats)(report);
}
rust::Vec<RTCIceCandidateStatsContainer> get_stats_RTCIceCandidateStats(
    const RTCStatsReport& report) {
  return MacroGetStatsOfType(RTCIceCandidateStats)(report);
}
rust::Vec<RTCOutboundRTPStreamStatsContainer>
get_stats_RTCOutboundRTPStreamStats(const RTCStatsReport& report) {
  return MacroGetStatsOfType(RTCOutboundRTPStreamStats)(report);
}
rust::Vec<RTCInboundRTPStreamStatsContainer> get_stats_RTCInboundRTPStreamStats(
    const RTCStatsReport& report) {
  return MacroGetStatsOfType(RTCInboundRTPStreamStats)(report);
}
rust::Vec<RTCIceCandidatePairStatsContainer> get_stats_RTCIceCandidatePairStats(
    const RTCStatsReport& report) {
  return MacroGetStatsOfType(RTCIceCandidatePairStats)(report);
}
rust::Vec<RTCTransportStatsContainer> get_stats_RTCTransportStats(
    const RTCStatsReport& report) {
  return MacroGetStatsOfType(RTCTransportStats)(report);
}
rust::Vec<RTCRemoteInboundRtpStreamStatsContainer>
get_stats_RTCRemoteInboundRtpStreamStats(const RTCStatsReport& report) {
  return MacroGetStatsOfType(RTCRemoteInboundRtpStreamStats)(report);
}
rust::Vec<RTCRemoteOutboundRtpStreamStatsContainer>
get_stats_RTCRemoteOutboundRtpStreamStats(const RTCStatsReport& report) {
  return MacroGetStatsOfType(RTCRemoteOutboundRtpStreamStats)(report);
}
}  // namespace bridge