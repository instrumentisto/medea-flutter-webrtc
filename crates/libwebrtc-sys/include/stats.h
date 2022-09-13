

#include "api/stats/rtc_stats_collector_callback.h"
#include "api/stats/rtcstats_objects.h"
#include "rust/cxx.h"



namespace bridge {

using RTCStatsReport = rtc::scoped_refptr<const webrtc::RTCStatsReport>;
using RTCStats = webrtc::RTCStats;

using RTCMediaSourceStats = webrtc::RTCMediaSourceStats;
struct RTCMediaSourceStatsContainer;

using RTCIceCandidateStats = webrtc::RTCIceCandidateStats;
struct RTCIceCandidateStatsContainer;

using RTCOutboundRTPStreamStats = webrtc::RTCOutboundRTPStreamStats;
struct RTCOutboundRTPStreamStatsContainer;

using RTCInboundRTPStreamStats = webrtc::RTCInboundRTPStreamStats;
struct RTCInboundRTPStreamStatsContainer;

using RTCIceCandidatePairStats = webrtc::RTCIceCandidatePairStats;
struct RTCIceCandidatePairStatsContainer;

using RTCTransportStats = webrtc::RTCTransportStats;
struct RTCTransportStatsContainer;

using RTCRemoteInboundRtpStreamStats = webrtc::RTCRemoteInboundRtpStreamStats;
struct RTCRemoteInboundRtpStreamStatsContainer;

using RTCRemoteOutboundRtpStreamStats = webrtc::RTCRemoteOutboundRtpStreamStats;
struct RTCRemoteOutboundRtpStreamStatsContainer;


// RTCMediaSourceStats
// std::unique_ptr<RTCMediaSourceStats> RTCStats_cast_to_RTCMediaSourceStats(
//     const RTCStats& stats);
std::unique_ptr<std::string> RTCMediaSourceStats_track_identifier(
    const RTCMediaSourceStats& stats);
std::unique_ptr<std::string> RTCMediaSourceStats_kind(
    const RTCMediaSourceStats& stats);
/// RTCMediaSourceStats

// RTCIceCandidateStats
// std::unique_ptr<RTCIceCandidateStats> RTCStats_cast_to_RTCIceCandidateStats(
//     const RTCStats& stats);
std::unique_ptr<std::string> RTCIceCandidateStats_transport_id(
    const RTCIceCandidateStats& stats);
bool RTCIceCandidateStats_is_remote(const RTCIceCandidateStats& stats);
std::unique_ptr<std::string> RTCIceCandidateStats_network_type(
    const RTCIceCandidateStats& stats);
std::unique_ptr<std::string> RTCIceCandidateStats_ip(
    const RTCIceCandidateStats& stats);
std::unique_ptr<std::string> RTCIceCandidateStats_address(
    const RTCIceCandidateStats& stats);
int32_t RTCIceCandidateStats_port(const RTCIceCandidateStats& stats);
std::unique_ptr<std::string> RTCIceCandidateStats_protocol(
    const RTCIceCandidateStats& stats);
std::unique_ptr<std::string> RTCIceCandidateStats_relay_protocol(
    const RTCIceCandidateStats& stats);
std::unique_ptr<std::string> RTCIceCandidateStats_candidate_type(
    const RTCIceCandidateStats& stats);
int32_t RTCIceCandidateStats_priority(const RTCIceCandidateStats& stats);
std::unique_ptr<std::string> RTCIceCandidateStats_url(
    const RTCIceCandidateStats& stats);
bool RTCIceCandidateStats_vpn(const RTCIceCandidateStats& stats);
std::unique_ptr<std::string> RTCIceCandidateStats_network_adapter_type(
    const RTCIceCandidateStats& stats);
/// RTCIceCandidateStats

// RTCOutboundRTPStreamStats
// std::unique_ptr<RTCOutboundRTPStreamStats>
// RTCStats_cast_to_RTCOutboundRTPStreamStats(const RTCStats& stats);
std::unique_ptr<std::string> RTCOutboundRTPStreamStats_track_id(
    const RTCOutboundRTPStreamStats& stats);
std::unique_ptr<std::string> RTCOutboundRTPStreamStats_kind(
    const RTCOutboundRTPStreamStats& stats);
std::unique_ptr<std::string> RTCOutboundRTPStreamStats_media_source_id(
    const RTCOutboundRTPStreamStats& stats);
std::unique_ptr<std::string> RTCOutboundRTPStreamStats_remote_id(
    const RTCOutboundRTPStreamStats& stats);
std::unique_ptr<std::string> RTCOutboundRTPStreamStats_rid(
    const RTCOutboundRTPStreamStats& stats);
uint32_t RTCOutboundRTPStreamStats_packets_sent(
    const RTCOutboundRTPStreamStats& stats);
uint64_t RTCOutboundRTPStreamStats_retransmitted_packets_sent(
    const RTCOutboundRTPStreamStats& stats);
uint64_t RTCOutboundRTPStreamStats_bytes_sent(
    const RTCOutboundRTPStreamStats& stats);
uint64_t RTCOutboundRTPStreamStats_header_bytes_sent(
    const RTCOutboundRTPStreamStats& stats);
uint64_t RTCOutboundRTPStreamStats_retransmitted_bytes_sent(
    const RTCOutboundRTPStreamStats& stats);
double RTCOutboundRTPStreamStats_target_bitrate(
    const RTCOutboundRTPStreamStats& stats);
uint32_t RTCOutboundRTPStreamStats_frames_encoded(
    const RTCOutboundRTPStreamStats& stats);
uint32_t RTCOutboundRTPStreamStats_key_frames_encoded(
    const RTCOutboundRTPStreamStats& stats);
double RTCOutboundRTPStreamStats_total_encode_time(
    const RTCOutboundRTPStreamStats& stats);
uint64_t RTCOutboundRTPStreamStats_total_encoded_bytes_target(
    const RTCOutboundRTPStreamStats& stats);
uint32_t RTCOutboundRTPStreamStats_frame_width(
    const RTCOutboundRTPStreamStats& stats);
uint32_t RTCOutboundRTPStreamStats_frame_height(
    const RTCOutboundRTPStreamStats& stats);
double RTCOutboundRTPStreamStats_frames_per_second(
    const RTCOutboundRTPStreamStats& stats);
uint32_t RTCOutboundRTPStreamStats_frames_sent(
    const RTCOutboundRTPStreamStats& stats);
uint32_t RTCOutboundRTPStreamStats_huge_frames_sent(
    const RTCOutboundRTPStreamStats& stats);
double RTCOutboundRTPStreamStats_total_packet_send_delay(
    const RTCOutboundRTPStreamStats& stats);
std::unique_ptr<std::string>
RTCOutboundRTPStreamStats_quality_limitation_reason(
    const RTCOutboundRTPStreamStats& stats);
// todo
//   RTCStatsMember<std::map<std::string, double>> quality_limitation_durations;
uint32_t RTCOutboundRTPStreamStats_quality_limitation_resolution_changes(
    const RTCOutboundRTPStreamStats& stats);
std::unique_ptr<std::string> RTCOutboundRTPStreamStats_content_type(
    const RTCOutboundRTPStreamStats& stats);
std::unique_ptr<std::string> RTCOutboundRTPStreamStats_encoder_implementation(
    const RTCOutboundRTPStreamStats& stats);
uint32_t RTCOutboundRTPStreamStats_fir_count(
    const RTCOutboundRTPStreamStats& stats);
uint32_t RTCOutboundRTPStreamStats_pli_count(
    const RTCOutboundRTPStreamStats& stats);
uint32_t RTCOutboundRTPStreamStats_nack_count(
    const RTCOutboundRTPStreamStats& stats);
uint64_t RTCOutboundRTPStreamStats_qp_sum(
    const RTCOutboundRTPStreamStats& stats);
/// RTCOutboundRTPStreamStats

// RTCInboundRTPStreamStats
// std::unique_ptr<RTCInboundRTPStreamStats>
// RTCStats_cast_to_RTCInboundRTPStreamStats(const RTCStats& stats);
std::unique_ptr<std::string> RTCInboundRTPStreamStats_remote_id(
    const RTCInboundRTPStreamStats& stats);
uint32_t RTCInboundRTPStreamStats_packets_received(
    const RTCInboundRTPStreamStats& stats);
uint64_t RTCInboundRTPStreamStats_fec_packets_received(
    const RTCInboundRTPStreamStats& stats);
uint64_t RTCInboundRTPStreamStats_fec_packets_discarded(
    const RTCInboundRTPStreamStats& stats);
uint64_t RTCInboundRTPStreamStats_bytes_received(
    const RTCInboundRTPStreamStats& stats);
uint64_t RTCInboundRTPStreamStats_header_bytes_received(
    const RTCInboundRTPStreamStats& stats);
double RTCInboundRTPStreamStats_last_packet_received_timestamp(
    const RTCInboundRTPStreamStats& stats);
double RTCInboundRTPStreamStats_jitter_buffer_delay(
    const RTCInboundRTPStreamStats& stats);
uint64_t RTCInboundRTPStreamStats_jitter_buffer_emitted_count(
    const RTCInboundRTPStreamStats& stats);
uint64_t RTCInboundRTPStreamStats_total_samples_received(
    const RTCInboundRTPStreamStats& stats);
uint64_t RTCInboundRTPStreamStats_concealed_samples(
    const RTCInboundRTPStreamStats& stats);
uint64_t RTCInboundRTPStreamStats_silent_concealed_samples(
    const RTCInboundRTPStreamStats& stats);
uint64_t RTCInboundRTPStreamStats_concealment_events(
    const RTCInboundRTPStreamStats& stats);
uint64_t RTCInboundRTPStreamStats_inserted_samples_for_deceleration(
    const RTCInboundRTPStreamStats& stats);
uint64_t RTCInboundRTPStreamStats_removed_samples_for_acceleration(
    const RTCInboundRTPStreamStats& stats);
double RTCInboundRTPStreamStats_audio_level(
    const RTCInboundRTPStreamStats& stats);
double RTCInboundRTPStreamStats_total_audio_energy(
    const RTCInboundRTPStreamStats& stats);
double RTCInboundRTPStreamStats_total_samples_duration(
    const RTCInboundRTPStreamStats& stats);
int32_t RTCInboundRTPStreamStats_frames_received(
    const RTCInboundRTPStreamStats& stats);
double RTCInboundRTPStreamStats_round_trip_time(
    const RTCInboundRTPStreamStats& stats);
uint32_t RTCInboundRTPStreamStats_packets_repaired(
    const RTCInboundRTPStreamStats& stats);
uint32_t RTCInboundRTPStreamStats_burst_packets_lost(
    const RTCInboundRTPStreamStats& stats);
uint32_t RTCInboundRTPStreamStats_burst_packets_discarded(
    const RTCInboundRTPStreamStats& stats);
uint32_t RTCInboundRTPStreamStats_burst_loss_count(
    const RTCInboundRTPStreamStats& stats);
uint32_t RTCInboundRTPStreamStats_burst_discard_count(
    const RTCInboundRTPStreamStats& stats);
double RTCInboundRTPStreamStats_burst_loss_rate(
    const RTCInboundRTPStreamStats& stats);
double RTCInboundRTPStreamStats_burst_discard_rate(
    const RTCInboundRTPStreamStats& stats);
double RTCInboundRTPStreamStats_gap_loss_rate(
    const RTCInboundRTPStreamStats& stats);
double RTCInboundRTPStreamStats_gap_discard_rate(
    const RTCInboundRTPStreamStats& stats);
uint32_t RTCInboundRTPStreamStats_frame_width(
    const RTCInboundRTPStreamStats& stats);
uint32_t RTCInboundRTPStreamStats_frame_height(
    const RTCInboundRTPStreamStats& stats);
uint32_t RTCInboundRTPStreamStats_frame_bit_depth(
    const RTCInboundRTPStreamStats& stats);
double RTCInboundRTPStreamStats_frames_per_second(
    const RTCInboundRTPStreamStats& stats);
uint32_t RTCInboundRTPStreamStats_frames_decoded(
    const RTCInboundRTPStreamStats& stats);
uint32_t RTCInboundRTPStreamStats_key_frames_decoded(
    const RTCInboundRTPStreamStats& stats);
uint32_t RTCInboundRTPStreamStats_frames_dropped(
    const RTCInboundRTPStreamStats& stats);
double RTCInboundRTPStreamStats_total_decode_time(
    const RTCInboundRTPStreamStats& stats);
double RTCInboundRTPStreamStats_total_inter_frame_delay(
    const RTCInboundRTPStreamStats& stats);
double RTCInboundRTPStreamStats_total_squared_inter_frame_delay(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<std::string> RTCInboundRTPStreamStats_content_type(
    const RTCInboundRTPStreamStats& stats);
double RTCInboundRTPStreamStats_estimated_playout_timestamp(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<std::string> RTCInboundRTPStreamStats_decoder_implementation(
    const RTCInboundRTPStreamStats& stats);
uint32_t RTCInboundRTPStreamStats_fir_count(
    const RTCInboundRTPStreamStats& stats);
uint32_t RTCInboundRTPStreamStats_pli_count(
    const RTCInboundRTPStreamStats& stats);
uint32_t RTCInboundRTPStreamStats_nack_count(
    const RTCInboundRTPStreamStats& stats);
uint64_t RTCInboundRTPStreamStats_qp_sum(const RTCInboundRTPStreamStats& stats);
/// RTCInboundRTPStreamStats

// RTCIceCandidatePairStats
// std::unique_ptr<RTCIceCandidatePairStats>
// RTCStats_cast_to_RTCIceCandidatePairStats(const RTCStats& stats);
std::unique_ptr<std::string> RTCIceCandidatePairStats_transport_id(
    const RTCIceCandidatePairStats& stats);
std::unique_ptr<std::string> RTCIceCandidatePairStats_local_candidate_id(
    const RTCIceCandidatePairStats& stats);
std::unique_ptr<std::string> RTCIceCandidatePairStats_remote_candidate_id(
    const RTCIceCandidatePairStats& stats);
std::unique_ptr<std::string> RTCIceCandidatePairStats_state(
    const RTCIceCandidatePairStats& stats);
uint64_t RTCIceCandidatePairStats_priority(
    const RTCIceCandidatePairStats& stats);
bool RTCIceCandidatePairStats_nominated(const RTCIceCandidatePairStats& stats);
bool RTCIceCandidatePairStats_writable(const RTCIceCandidatePairStats& stats);
bool RTCIceCandidatePairStats_readable(const RTCIceCandidatePairStats& stats);
uint64_t RTCIceCandidatePairStats_packets_sent(
    const RTCIceCandidatePairStats& stats);
uint64_t RTCIceCandidatePairStats_packets_received(
    const RTCIceCandidatePairStats& stats);
uint64_t RTCIceCandidatePairStats_bytes_sent(
    const RTCIceCandidatePairStats& stats);
uint64_t RTCIceCandidatePairStats_bytes_received(
    const RTCIceCandidatePairStats& stats);
bool RTCIceCandidatePairStats_total_round_trip_time(
    const RTCIceCandidatePairStats& stats);
bool RTCIceCandidatePairStats_current_round_trip_time(
    const RTCIceCandidatePairStats& stats);
bool RTCIceCandidatePairStats_available_outgoing_bitrate(
    const RTCIceCandidatePairStats& stats);
bool RTCIceCandidatePairStats_available_incoming_bitrate(
    const RTCIceCandidatePairStats& stats);
uint64_t RTCIceCandidatePairStats_requests_received(
    const RTCIceCandidatePairStats& stats);
uint64_t RTCIceCandidatePairStats_requests_sent(
    const RTCIceCandidatePairStats& stats);
uint64_t RTCIceCandidatePairStats_responses_received(
    const RTCIceCandidatePairStats& stats);
uint64_t RTCIceCandidatePairStats_responses_sent(
    const RTCIceCandidatePairStats& stats);
uint64_t RTCIceCandidatePairStats_retransmissions_received(
    const RTCIceCandidatePairStats& stats);
uint64_t RTCIceCandidatePairStats_retransmissions_sent(
    const RTCIceCandidatePairStats& stats);
uint64_t RTCIceCandidatePairStats_consent_requests_received(
    const RTCIceCandidatePairStats& stats);
uint64_t RTCIceCandidatePairStats_consent_requests_sent(
    const RTCIceCandidatePairStats& stats);
uint64_t RTCIceCandidatePairStats_consent_responses_received(
    const RTCIceCandidatePairStats& stats);
uint64_t RTCIceCandidatePairStats_consent_responses_sent(
    const RTCIceCandidatePairStats& stats);
uint64_t RTCIceCandidatePairStats_packets_discarded_on_send(
    const RTCIceCandidatePairStats& stats);
uint64_t RTCIceCandidatePairStats_bytes_discarded_on_send(
    const RTCIceCandidatePairStats& stats);
/// RTCIceCandidatePairStats

// RTCTransportStats
// std::unique_ptr<RTCTransportStats> RTCStats_cast_to_RTCTransportStats(
//     const RTCStats& stats);
uint64_t RTCTransportStats_bytes_sent(const RTCTransportStats& stats);
uint64_t RTCTransportStats_packets_sent(const RTCTransportStats& stats);
uint64_t RTCTransportStats_bytes_received(const RTCTransportStats& stats);
uint64_t RTCTransportStats_packets_received(const RTCTransportStats& stats);
std::unique_ptr<std::string> RTCTransportStats_rtcp_transport_stats_id(
    const RTCTransportStats& stats);
std::unique_ptr<std::string> RTCTransportStats_dtls_state(
    const RTCTransportStats& stats);
std::unique_ptr<std::string> RTCTransportStats_selected_candidate_pair_id(
    const RTCTransportStats& stats);
std::unique_ptr<std::string> RTCTransportStats_local_certificate_id(
    const RTCTransportStats& stats);
std::unique_ptr<std::string> RTCTransportStats_remote_certificate_id(
    const RTCTransportStats& stats);
std::unique_ptr<std::string> RTCTransportStats_tls_version(
    const RTCTransportStats& stats);
std::unique_ptr<std::string> RTCTransportStats_dtls_cipher(
    const RTCTransportStats& stats);
std::unique_ptr<std::string> RTCTransportStats_srtp_cipher(
    const RTCTransportStats& stats);
uint32_t RTCTransportStats_selected_candidate_pair_changes(
    const RTCTransportStats& stats);
/// RTCTransportStats

// RTCRemoteInboundRtpStreamStats
// std::unique_ptr<RTCRemoteInboundRtpStreamStats>
// RTCStats_cast_to_RTCRemoteInboundRtpStreamStats(const RTCStats& stats);
std::unique_ptr<std::string> RTCRemoteInboundRtpStreamStats_local_id(
    const RTCRemoteInboundRtpStreamStats& stats);
double RTCRemoteInboundRtpStreamStats_round_trip_time(
    const RTCRemoteInboundRtpStreamStats& stats);
double RTCRemoteInboundRtpStreamStats_fraction_lost(
    const RTCRemoteInboundRtpStreamStats& stats);
double RTCRemoteInboundRtpStreamStats_total_round_trip_time(
    const RTCRemoteInboundRtpStreamStats& stats);
int32_t RTCRemoteInboundRtpStreamStats_round_trip_time_measurements(
    const RTCRemoteInboundRtpStreamStats& stats);
/// RTCRemoteInboundRtpStreamStats

// RTCRemoteOutboundRtpStreamStats
// std::unique_ptr<RTCRemoteOutboundRtpStreamStats>
// RTCStats_cast_to_RTCRemoteOutboundRtpStreamStats(const RTCStats& stats);
std::unique_ptr<std::string> RTCRemoteOutboundRtpStreamStats_local_id(
    const RTCRemoteOutboundRtpStreamStats& stats);
double RTCRemoteOutboundRtpStreamStats_remote_timestamp(
    const RTCRemoteOutboundRtpStreamStats& stats);
uint64_t RTCRemoteOutboundRtpStreamStats_reports_sent(
    const RTCRemoteOutboundRtpStreamStats& stats);
double RTCRemoteOutboundRtpStreamStats_round_trip_time(
    const RTCRemoteOutboundRtpStreamStats& stats);
uint64_t RTCRemoteOutboundRtpStreamStats_round_trip_time_measurements(
    const RTCRemoteOutboundRtpStreamStats& stats);
double RTCRemoteOutboundRtpStreamStats_total_round_trip_time(
    const RTCRemoteOutboundRtpStreamStats& stats);
/// RTCRemoteOutboundRtpStreamStats

// todo
std::unique_ptr<std::string> stats_json(const RTCStatsReport& report);

rust::Vec<RTCMediaSourceStatsContainer> get_stats_RTCMediaSourceStats(
    const RTCStatsReport& report);
rust::Vec<RTCIceCandidateStatsContainer>
get_stats_RTCIceCandidateStats(const RTCStatsReport& report);
rust::Vec<RTCOutboundRTPStreamStatsContainer>
get_stats_RTCOutboundRTPStreamStats(const RTCStatsReport& report);
rust::Vec<RTCInboundRTPStreamStatsContainer>
get_stats_RTCInboundRTPStreamStats(const RTCStatsReport& report);
rust::Vec<RTCIceCandidatePairStatsContainer>
get_stats_RTCIceCandidatePairStats(const RTCStatsReport& report);
rust::Vec<RTCTransportStatsContainer> get_stats_RTCTransportStats(
    const RTCStatsReport& report);
rust::Vec<RTCRemoteInboundRtpStreamStatsContainer>
get_stats_RTCRemoteInboundRtpStreamStats(const RTCStatsReport& report);
rust::Vec<RTCRemoteOutboundRtpStreamStatsContainer>
get_stats_RTCRemoteOutboundRtpStreamStats(const RTCStatsReport& report);

}  // namespace bridge