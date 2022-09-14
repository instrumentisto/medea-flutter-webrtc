

#include "api/stats/rtc_stats_collector_callback.h"
#include "api/stats/rtcstats_objects.h"
#include "rust/cxx.h"



namespace bridge {

using RTCStatsMemberString = webrtc::RTCStatsMember<std::string>;
using RTCStatsMemberf64 = webrtc::RTCStatsMember<double>;
using RTCStatsMemberi32 = webrtc::RTCStatsMember<int32_t>;
using RTCStatsMemberu32 = webrtc::RTCStatsMember<uint32_t>;
using RTCStatsMemberu64 = webrtc::RTCStatsMember<uint64_t>;
using RTCStatsMemberbool = webrtc::RTCStatsMember<bool>;

bool rtc_stats_member_string_is_defined(const RTCStatsMemberString& stats_member);
bool rtc_stats_member_f64_is_defined(const RTCStatsMemberf64& stats_member);
bool rtc_stats_member_i32_is_defined(const RTCStatsMemberi32& stats_member);
bool rtc_stats_member_u32_is_defined(const RTCStatsMemberu32& stats_member);
bool rtc_stats_member_u64_is_defined(const RTCStatsMemberu64& stats_member);
bool rtc_stats_member_bool_is_defined(const RTCStatsMemberbool& stats_member);


std::unique_ptr<std::string> rtc_stats_member_string_value(const RTCStatsMemberString& stats_member);
double rtc_stats_member_f64_value(const RTCStatsMemberf64& stats_member);
int32_t rtc_stats_member_i32_value(const RTCStatsMemberi32& stats_member);
uint32_t rtc_stats_member_u32_value(const RTCStatsMemberu32& stats_member);
uint64_t rtc_stats_member_u64_value(const RTCStatsMemberu64& stats_member);
bool rtc_stats_member_bool_value(const RTCStatsMemberbool& stats_member);


using RTCStatsReport = rtc::scoped_refptr<const webrtc::RTCStatsReport>;
using RTCStats = webrtc::RTCStats;
struct RTCStatsContainer;


std::unique_ptr<std::string> rtc_stats_id(const RTCStats& stats);
int64_t rtc_stats_timestamp_us(const RTCStats& stats);
std::unique_ptr<std::string> rtc_stats_type(const RTCStats& stats);




using RTCMediaSourceStats = webrtc::RTCMediaSourceStats;
using RTCVideoSourceStats = webrtc::RTCVideoSourceStats;
using RTCAudioSourceStats = webrtc::RTCAudioSourceStats;

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



std::unique_ptr<RTCIceCandidateStats>            rtc_stats_cast_to_rtc_ice_candidate_stats(std::unique_ptr<RTCStats> stats);
std::unique_ptr<RTCOutboundRTPStreamStats>       rtc_stats_cast_to_rtc_outbound_rtp_stream_stats(std::unique_ptr<RTCStats> stats);
std::unique_ptr<RTCInboundRTPStreamStats>        rtc_stats_cast_to_rtc_inbound_rtp_stream_stats(std::unique_ptr<RTCStats> stats);
std::unique_ptr<RTCIceCandidatePairStats>        rtc_stats_cast_to_rtc_ice_candidate_pair_stats(std::unique_ptr<RTCStats> stats);
std::unique_ptr<RTCTransportStats>               rtc_stats_cast_to_rtc_transport_stats(std::unique_ptr<RTCStats> stats);
std::unique_ptr<RTCRemoteInboundRtpStreamStats>  rtc_stats_cast_to_rtc_remote_inbound_rtp_stream_stats(std::unique_ptr<RTCStats> stats);
std::unique_ptr<RTCRemoteOutboundRtpStreamStats> rtc_stats_cast_to_rtc_remote_outbound_rtp_stream_stats(std::unique_ptr<RTCStats> stats);
std::unique_ptr<RTCMediaSourceStats>             rtc_stats_cast_to_rtc_media_source_stats(std::unique_ptr<RTCStats> stats);


// RTCMediaSourceStats
std::unique_ptr<RTCStatsMemberString> rtc_media_source_stats_track_identifier(
    const RTCMediaSourceStats& stats);
std::unique_ptr<RTCStatsMemberString> rtc_media_source_stats_kind(
    const RTCMediaSourceStats& stats);
/// RTCMediaSourceStats

std::unique_ptr<RTCAudioSourceStats> rtc_media_source_stats_cast_to_rtc_audio_source_stats(std::unique_ptr<RTCMediaSourceStats> stats);
std::unique_ptr<RTCVideoSourceStats> rtc_media_source_stats_cast_to_rtc_video_source_stats(std::unique_ptr<RTCMediaSourceStats> stats);

//RTCVideoSourceStats
std::unique_ptr<RTCStatsMemberu32> rtc_video_source_stats_width(
    const RTCVideoSourceStats& stats);
std::unique_ptr<RTCStatsMemberu32> rtc_video_source_stats_height(
    const RTCVideoSourceStats& stats);
std::unique_ptr<RTCStatsMemberu32> rtc_video_source_stats_frames(
    const RTCVideoSourceStats& stats);
std::unique_ptr<RTCStatsMemberf64> rtc_video_source_stats_frames_per_second(
    const RTCVideoSourceStats& stats);
/// RTCMediaSourceStats 

// RTCAudioSourceStats
std::unique_ptr<RTCStatsMemberf64> rtc_audio_source_stats_audio_level(
    const RTCAudioSourceStats& stats);
std::unique_ptr<RTCStatsMemberf64> rtc_audio_source_stats_total_audio_energy(
    const RTCAudioSourceStats& stats);
std::unique_ptr<RTCStatsMemberf64> rtc_audio_source_stats_total_samples_duration(
    const RTCAudioSourceStats& stats);
std::unique_ptr<RTCStatsMemberf64> rtc_audio_source_stats_echo_return_loss(
    const RTCAudioSourceStats& stats);
std::unique_ptr<RTCStatsMemberf64> rtc_audio_source_stats_echo_return_loss_enhancement(
    const RTCAudioSourceStats& stats);
/// RTCAudioSourceStats

// RTCIceCandidateStats
// std::unique_ptr<RTCIceCandidateStats> RTCStats_cast_to_RTCIceCandidateStats(
//     const RTCStats& stats);
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_stats_transport_id(
    const RTCIceCandidateStats& stats);
std::unique_ptr<RTCStatsMemberbool> rtc_ice_candidate_stats_is_remote(const RTCIceCandidateStats& stats);
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_stats_network_type(
    const RTCIceCandidateStats& stats);
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_stats_ip(
    const RTCIceCandidateStats& stats);
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_stats_address(
    const RTCIceCandidateStats& stats);
std::unique_ptr<RTCStatsMemberi32> rtc_ice_candidate_stats_port(const RTCIceCandidateStats& stats);
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_stats_protocol(
    const RTCIceCandidateStats& stats);
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_stats_relay_protocol(
    const RTCIceCandidateStats& stats);
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_stats_candidate_type(
    const RTCIceCandidateStats& stats);
std::unique_ptr<RTCStatsMemberi32> rtc_ice_candidate_stats_priority(const RTCIceCandidateStats& stats);
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_stats_url(
    const RTCIceCandidateStats& stats);
std::unique_ptr<RTCStatsMemberbool> rtc_ice_candidate_stats_vpn(const RTCIceCandidateStats& stats);
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_stats_network_adapter_type(
    const RTCIceCandidateStats& stats);
/// RTCIceCandidateStats

// RTCOutboundRTPStreamStats
// std::unique_ptr<RTCOutboundRTPStreamStats>
// RTCStats_cast_to_RTCOutboundRTPStreamStats(const RTCStats& stats);
std::unique_ptr<RTCStatsMemberString> rtc_outbound_rtp_stream_stats_track_id(
    const RTCOutboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberString> rtc_outbound_rtp_stream_stats_kind(
    const RTCOutboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberString> rtc_outbound_rtp_stream_stats_media_source_id(
    const RTCOutboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberString> rtc_outbound_rtp_stream_stats_remote_id(
    const RTCOutboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberString> rtc_outbound_rtp_stream_stats_rid(
    const RTCOutboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberu32> rtc_outbound_rtp_stream_stats_packets_sent(
    const RTCOutboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberu64> rtc_outbound_rtp_stream_stats_retransmitted_packets_sent(
    const RTCOutboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberu64> rtc_outbound_rtp_stream_stats_bytes_sent(
    const RTCOutboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberu64> rtc_outbound_rtp_stream_stats_header_bytes_sent(
    const RTCOutboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberu64> rtc_outbound_rtp_stream_stats_retransmitted_bytes_sent(
    const RTCOutboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberf64> rtc_outbound_rtp_stream_stats_target_bitrate(
    const RTCOutboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberu32> rtc_outbound_rtp_stream_stats_frames_encoded(
    const RTCOutboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberu32> rtc_outbound_rtp_stream_stats_key_frames_encoded(
    const RTCOutboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberf64> rtc_outbound_rtp_stream_stats_total_encode_time(
    const RTCOutboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberu64> rtc_outbound_rtp_stream_stats_total_encoded_bytes_target(
    const RTCOutboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberu32> rtc_outbound_rtp_stream_stats_frame_width(
    const RTCOutboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberu32> rtc_outbound_rtp_stream_stats_frame_height(
    const RTCOutboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberf64> rtc_outbound_rtp_stream_stats_frames_per_second(
    const RTCOutboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberu32> rtc_outbound_rtp_stream_stats_frames_sent(
    const RTCOutboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberu32> rtc_outbound_rtp_stream_stats_huge_frames_sent(
    const RTCOutboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberf64> rtc_outbound_rtp_stream_stats_total_packet_send_delay(
    const RTCOutboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberString>
rtc_outbound_rtp_stream_stats_quality_limitation_reason(
    const RTCOutboundRTPStreamStats& stats);
// todo
//   RTCStatsMember<std::map<std::string, double>> quality_limitation_durations;
std::unique_ptr<RTCStatsMemberu32> rtc_outbound_rtp_stream_stats_quality_limitation_resolution_changes(
    const RTCOutboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberString> rtc_outbound_rtp_stream_stats_content_type(
    const RTCOutboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberString> rtc_outbound_rtp_stream_stats_encoder_implementation(
    const RTCOutboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberu32> rtc_outbound_rtp_stream_stats_fir_count(
    const RTCOutboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberu32> rtc_outbound_rtp_stream_stats_pli_count(
    const RTCOutboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberu32> rtc_outbound_rtp_stream_stats_nack_count(
    const RTCOutboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberu64> rtc_outbound_rtp_stream_stats_qp_sum(
    const RTCOutboundRTPStreamStats& stats);
/// RTCOutboundRTPStreamStats

// RTCInboundRTPStreamStats
// std::unique_ptr<RTCInboundRTPStreamStats>
// RTCStats_cast_to_RTCInboundRTPStreamStats(const RTCStats& stats);
std::unique_ptr<RTCStatsMemberString> rtc_inbound_rtp_stream_stats_remote_id(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_packets_received(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberu64> rtc_inbound_rtp_stream_stats_fec_packets_received(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberu64> rtc_inbound_rtp_stream_stats_fec_packets_discarded(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberu64> rtc_inbound_rtp_stream_stats_bytes_received(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberu64> rtc_inbound_rtp_stream_stats_header_bytes_received(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_last_packet_received_timestamp(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_jitter_buffer_delay(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberu64> rtc_inbound_rtp_stream_stats_jitter_buffer_emitted_count(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberu64> rtc_inbound_rtp_stream_stats_total_samples_received(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberu64> rtc_inbound_rtp_stream_stats_concealed_samples(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberu64> rtc_inbound_rtp_stream_stats_silent_concealed_samples(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberu64> rtc_inbound_rtp_stream_stats_concealment_events(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberu64> rtc_inbound_rtp_stream_stats_inserted_samples_for_deceleration(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberu64> rtc_inbound_rtp_stream_stats_removed_samples_for_acceleration(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_audio_level(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_total_audio_energy(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_total_samples_duration(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberi32> rtc_inbound_rtp_stream_stats_frames_received(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_round_trip_time(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_packets_repaired(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_burst_packets_lost(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_burst_packets_discarded(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_burst_loss_count(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_burst_discard_count(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_burst_loss_rate(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_burst_discard_rate(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_gap_loss_rate(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_gap_discard_rate(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_frame_width(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_frame_height(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_frame_bit_depth(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_frames_per_second(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_frames_decoded(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_key_frames_decoded(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_frames_dropped(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_total_decode_time(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_total_inter_frame_delay(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_total_squared_inter_frame_delay(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberString> rtc_inbound_rtp_stream_stats_content_type(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_estimated_playout_timestamp(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberString> rtc_inbound_rtp_stream_stats_decoder_implementation(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_fir_count(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_pli_count(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_nack_count(
    const RTCInboundRTPStreamStats& stats);
std::unique_ptr<RTCStatsMemberu64> rtc_inbound_rtp_stream_stats_qp_sum(const RTCInboundRTPStreamStats& stats);
/// RTCInboundRTPStreamStats

// RTCIceCandidatePairStats
// std::unique_ptr<RTCIceCandidatePairStats>
// RTCStats_cast_to_RTCIceCandidatePairStats(const RTCStats& stats);
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_pair_stats_transport_id(
    const RTCIceCandidatePairStats& stats);
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_pair_stats_local_candidate_id(
    const RTCIceCandidatePairStats& stats);
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_pair_stats_remote_candidate_id(
    const RTCIceCandidatePairStats& stats);
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_pair_stats_state(
    const RTCIceCandidatePairStats& stats);
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_priority(
    const RTCIceCandidatePairStats& stats);
std::unique_ptr<RTCStatsMemberbool> rtc_ice_candidate_pair_stats_nominated(const RTCIceCandidatePairStats& stats);
std::unique_ptr<RTCStatsMemberbool> rtc_ice_candidate_pair_stats_writable(const RTCIceCandidatePairStats& stats);
std::unique_ptr<RTCStatsMemberbool> rtc_ice_candidate_pair_stats_readable(const RTCIceCandidatePairStats& stats);
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_packets_sent(
    const RTCIceCandidatePairStats& stats);
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_packets_received(
    const RTCIceCandidatePairStats& stats);
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_bytes_sent(
    const RTCIceCandidatePairStats& stats);
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_bytes_received(
    const RTCIceCandidatePairStats& stats);
std::unique_ptr<RTCStatsMemberf64> rtc_ice_candidate_pair_stats_total_round_trip_time(
    const RTCIceCandidatePairStats& stats);
std::unique_ptr<RTCStatsMemberf64> rtc_ice_candidate_pair_stats_current_round_trip_time(
    const RTCIceCandidatePairStats& stats);
std::unique_ptr<RTCStatsMemberf64> rtc_ice_candidate_pair_stats_available_outgoing_bitrate(
    const RTCIceCandidatePairStats& stats);
std::unique_ptr<RTCStatsMemberf64> rtc_ice_candidate_pair_stats_available_incoming_bitrate(
    const RTCIceCandidatePairStats& stats);
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_requests_received(
    const RTCIceCandidatePairStats& stats);
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_requests_sent(
    const RTCIceCandidatePairStats& stats);
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_responses_received(
    const RTCIceCandidatePairStats& stats);
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_responses_sent(
    const RTCIceCandidatePairStats& stats);
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_retransmissions_received(
    const RTCIceCandidatePairStats& stats);
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_retransmissions_sent(
    const RTCIceCandidatePairStats& stats);
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_consent_requests_received(
    const RTCIceCandidatePairStats& stats);
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_consent_requests_sent(
    const RTCIceCandidatePairStats& stats);
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_consent_responses_received(
    const RTCIceCandidatePairStats& stats);
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_consent_responses_sent(
    const RTCIceCandidatePairStats& stats);
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_packets_discarded_on_send(
    const RTCIceCandidatePairStats& stats);
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_bytes_discarded_on_send(
    const RTCIceCandidatePairStats& stats);
/// RTCIceCandidatePairStats

// RTCTransportStats
// std::unique_ptr<RTCTransportStats> RTCStats_cast_to_RTCTransportStats(
//     const RTCStats& stats);
std::unique_ptr<RTCStatsMemberu64> rtc_transport_stats_bytes_sent(const RTCTransportStats& stats);
std::unique_ptr<RTCStatsMemberu64> rtc_transport_stats_packets_sent(const RTCTransportStats& stats);
std::unique_ptr<RTCStatsMemberu64> rtc_transport_stats_bytes_received(const RTCTransportStats& stats);
std::unique_ptr<RTCStatsMemberu64> rtc_transport_stats_packets_received(const RTCTransportStats& stats);
std::unique_ptr<RTCStatsMemberString> rtc_transport_stats_rtcp_transport_stats_id(
    const RTCTransportStats& stats);
std::unique_ptr<RTCStatsMemberString> rtc_transport_stats_dtls_state(
    const RTCTransportStats& stats);
std::unique_ptr<RTCStatsMemberString> rtc_transport_stats_selected_candidate_pair_id(
    const RTCTransportStats& stats);
std::unique_ptr<RTCStatsMemberString> rtc_transport_stats_local_certificate_id(
    const RTCTransportStats& stats);
std::unique_ptr<RTCStatsMemberString> rtc_transport_stats_remote_certificate_id(
    const RTCTransportStats& stats);
std::unique_ptr<RTCStatsMemberString> rtc_transport_stats_tls_version(
    const RTCTransportStats& stats);
std::unique_ptr<RTCStatsMemberString> rtc_transport_stats_dtls_cipher(
    const RTCTransportStats& stats);
std::unique_ptr<RTCStatsMemberString> rtc_transport_stats_srtp_cipher(
    const RTCTransportStats& stats);
std::unique_ptr<RTCStatsMemberu32> rtc_transport_stats_selected_candidate_pair_changes(
    const RTCTransportStats& stats);
/// RTCTransportStats

// RTCRemoteInboundRtpStreamStats
// std::unique_ptr<RTCRemoteInboundRtpStreamStats>
// RTCStats_cast_to_RTCRemoteInboundRtpStreamStats(const RTCStats& stats);
std::unique_ptr<RTCStatsMemberString> rtc_remote_inbound_rtp_stream_stats_local_id(
    const RTCRemoteInboundRtpStreamStats& stats);
std::unique_ptr<RTCStatsMemberf64> rtc_remote_inbound_rtp_stream_stats_round_trip_time(
    const RTCRemoteInboundRtpStreamStats& stats);
std::unique_ptr<RTCStatsMemberf64> rtc_remote_inbound_rtp_stream_stats_fraction_lost(
    const RTCRemoteInboundRtpStreamStats& stats);
std::unique_ptr<RTCStatsMemberf64> rtc_remote_inbound_rtp_stream_stats_total_round_trip_time(
    const RTCRemoteInboundRtpStreamStats& stats);
std::unique_ptr<RTCStatsMemberi32> rtc_remote_inbound_rtp_stream_stats_round_trip_time_measurements(
    const RTCRemoteInboundRtpStreamStats& stats);
/// RTCRemoteInboundRtpStreamStats

// RTCRemoteOutboundRtpStreamStats
// std::unique_ptr<RTCRemoteOutboundRtpStreamStats>
// RTCStats_cast_to_RTCRemoteOutboundRtpStreamStats(const RTCStats& stats);
std::unique_ptr<RTCStatsMemberString> rtc_remote_outbound_rtp_stream_stats_local_id(
    const RTCRemoteOutboundRtpStreamStats& stats);
std::unique_ptr<RTCStatsMemberf64> rtc_remote_outbound_rtp_stream_stats_remote_timestamp(
    const RTCRemoteOutboundRtpStreamStats& stats);
std::unique_ptr<RTCStatsMemberu64> rtc_remote_outbound_rtp_stream_stats_reports_sent(
    const RTCRemoteOutboundRtpStreamStats& stats);
std::unique_ptr<RTCStatsMemberf64> rtc_remote_outbound_rtp_stream_stats_round_trip_time(
    const RTCRemoteOutboundRtpStreamStats& stats);
std::unique_ptr<RTCStatsMemberu64> rtc_remote_outbound_rtp_stream_stats_round_trip_time_measurements(
    const RTCRemoteOutboundRtpStreamStats& stats);
std::unique_ptr<RTCStatsMemberf64> rtc_remote_outbound_rtp_stream_stats_total_round_trip_time(
    const RTCRemoteOutboundRtpStreamStats& stats);
/// RTCRemoteOutboundRtpStreamStats

// todo
std::unique_ptr<std::string> stats_json(const RTCStatsReport& report);


rust::Vec<RTCStatsContainer> rtc_stats_report_get_stats(
    const RTCStatsReport& report);

}  // namespace bridge