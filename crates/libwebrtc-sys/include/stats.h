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

// Returns the `value` of the provided `RTCStatsMemberString`.
const std::string& rtc_stats_member_string_value(
    const RTCStatsMemberString& stats_member);

// Returns the `value` of the provided `RTCStatsMemberf64`.
double rtc_stats_member_f64_value(const RTCStatsMemberf64& stats_member);

// Returns the `value` of the provided `RTCStatsMemberi32`.
int32_t rtc_stats_member_i32_value(const RTCStatsMemberi32& stats_member);

// Returns the `value` of the provided `RTCStatsMemberu32`.
uint32_t rtc_stats_member_u32_value(const RTCStatsMemberu32& stats_member);

// Returns the `value` of the provided `RTCStatsMemberu64`.
uint64_t rtc_stats_member_u64_value(const RTCStatsMemberu64& stats_member);

// Returns the `value` of the provided `RTCStatsMemberbool`.
bool rtc_stats_member_bool_value(const RTCStatsMemberbool& stats_member);

using RTCStatsReport = rtc::scoped_refptr<const webrtc::RTCStatsReport>;
using RTCStats = webrtc::RTCStats;
struct RTCStatsContainer;

// Returns the `type` of the provided `RTCStats`.
const std::string& rtc_stats_type(const RTCStats& stats);

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

// Try cast a `RTCStats` to the `RTCIceCandidateStats`.
std::unique_ptr<RTCIceCandidateStats> rtc_stats_cast_to_rtc_ice_candidate_stats(
    std::unique_ptr<RTCStats> stats);

// Try cast a `RTCStats` to the `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCOutboundRTPStreamStats>
rtc_stats_cast_to_rtc_outbound_rtp_stream_stats(
    std::unique_ptr<RTCStats> stats);

// Try cast a `RTCStats` to the `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCInboundRTPStreamStats>
rtc_stats_cast_to_rtc_inbound_rtp_stream_stats(
    std::unique_ptr<RTCStats> stats);

// Try cast a `RTCStats` to the `RTCIceCandidatePairStats`.
std::unique_ptr<RTCIceCandidatePairStats>
rtc_stats_cast_to_rtc_ice_candidate_pair_stats(
    std::unique_ptr<RTCStats> stats);

// Try cast a `RTCStats` to the `RTCTransportStats`.
std::unique_ptr<RTCTransportStats>
rtc_stats_cast_to_rtc_transport_stats(
    std::unique_ptr<RTCStats> stats);

// Try cast a `RTCStats` to the `RTCRemoteInboundRtpStreamStats`.
std::unique_ptr<RTCRemoteInboundRtpStreamStats>
rtc_stats_cast_to_rtc_remote_inbound_rtp_stream_stats(
    std::unique_ptr<RTCStats> stats);

// Try cast a `RTCStats` to the `RTCRemoteOutboundRtpStreamStats`.
std::unique_ptr<RTCRemoteOutboundRtpStreamStats>
rtc_stats_cast_to_rtc_remote_outbound_rtp_stream_stats(
    std::unique_ptr<RTCStats> stats);

// Try cast a `RTCStats` to the `RTCMediaSourceStats`.
std::unique_ptr<RTCMediaSourceStats>
rtc_stats_cast_to_rtc_media_source_stats(std::unique_ptr<RTCStats> stats);

// Try cast a `RTCStats` to the `RTCAudioSourceStats`.
std::unique_ptr<RTCAudioSourceStats>
rtc_media_source_stats_cast_to_rtc_audio_source_stats(
    std::unique_ptr<RTCMediaSourceStats> stats);

// Try cast a `RTCStats` to the `RTCVideoSourceStats`.
std::unique_ptr<RTCVideoSourceStats>
rtc_media_source_stats_cast_to_rtc_video_source_stats(
    std::unique_ptr<RTCMediaSourceStats> stats);

// RTCMediaSourceStats

// Returns the `track_identifier` of the provided `RTCMediaSourceStats`.
std::unique_ptr<RTCStatsMemberString> rtc_media_source_stats_track_identifier(
    const RTCMediaSourceStats& stats);

// Returns the `kind` of the provided `RTCMediaSourceStats`.
std::unique_ptr<RTCStatsMemberString> rtc_media_source_stats_kind(
    const RTCMediaSourceStats& stats);

//RTCVideoSourceStats
// Returns the `width` of the provided `RTCVideoSourceStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_video_source_stats_width(
    const RTCVideoSourceStats& stats);

// Returns the `height` of the provided `RTCVideoSourceStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_video_source_stats_height(
    const RTCVideoSourceStats& stats);

// Returns the `frames` of the provided `RTCVideoSourceStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_video_source_stats_frames(
    const RTCVideoSourceStats& stats);

// Returns the `frames_per_second` of the provided `RTCVideoSourceStats`.
std::unique_ptr<RTCStatsMemberf64> rtc_video_source_stats_frames_per_second(
    const RTCVideoSourceStats& stats);
/// RTCMediaSourceStats

// RTCAudioSourceStats
// Returns the `audio_level` of the provided `RTCAudioSourceStats`.
std::unique_ptr<RTCStatsMemberf64> rtc_audio_source_stats_audio_level(
    const RTCAudioSourceStats& stats);

// Returns the `total_audio_energy` of the provided `RTCAudioSourceStats`.
std::unique_ptr<RTCStatsMemberf64> rtc_audio_source_stats_total_audio_energy(
    const RTCAudioSourceStats& stats);

// Returns the `total_samples_duration` of the provided `RTCAudioSourceStats`.
std::unique_ptr<RTCStatsMemberf64>
rtc_audio_source_stats_total_samples_duration(
    const RTCAudioSourceStats& stats);

// Returns the `echo_return_loss` of the provided `RTCAudioSourceStats`.
std::unique_ptr<RTCStatsMemberf64> rtc_audio_source_stats_echo_return_loss(
    const RTCAudioSourceStats& stats);

// Returns the `echo_return_loss_enhancement` of the provided
// `RTCAudioSourceStats`.
std::unique_ptr<RTCStatsMemberf64>
rtc_audio_source_stats_echo_return_loss_enhancement(
    const RTCAudioSourceStats& stats);
/// RTCAudioSourceStats

// RTCIceCandidateStats
// Returns the `transport_id` of the provided `RTCIceCandidateStats`.
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_stats_transport_id(
    const RTCIceCandidateStats& stats);

// Returns the `is_remote` of the provided `RTCIceCandidateStats`.
std::unique_ptr<RTCStatsMemberbool>
rtc_ice_candidate_stats_is_remote(const RTCIceCandidateStats& stats);

// Returns the `network_type` of the provided `RTCIceCandidateStats`.
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_stats_network_type(
    const RTCIceCandidateStats& stats);

// Returns the `ip` of the provided `RTCIceCandidateStats`.
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_stats_ip(
    const RTCIceCandidateStats& stats);

// Returns the `address` of the provided `RTCIceCandidateStats`.
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_stats_address(
    const RTCIceCandidateStats& stats);

// Returns the `port` of the provided `RTCIceCandidateStats`.
std::unique_ptr<RTCStatsMemberi32>
rtc_ice_candidate_stats_port(const RTCIceCandidateStats& stats);

// Returns the `protocol` of the provided `RTCIceCandidateStats`.
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_stats_protocol(
    const RTCIceCandidateStats& stats);

// Returns the `relay_protocol` of the provided `RTCIceCandidateStats`.
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_stats_relay_protocol(
    const RTCIceCandidateStats& stats);

// Returns the `candidate_type` of the provided `RTCIceCandidateStats`.
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_stats_candidate_type(
    const RTCIceCandidateStats& stats);

// Returns the `priority` of the provided `RTCIceCandidateStats`.
std::unique_ptr<RTCStatsMemberi32>
rtc_ice_candidate_stats_priority(const RTCIceCandidateStats& stats);

// Returns the `url` of the provided `RTCIceCandidateStats`.
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_stats_url(
    const RTCIceCandidateStats& stats);

// Returns the `vpn` of the provided `RTCIceCandidateStats`.
std::unique_ptr<RTCStatsMemberbool>
rtc_ice_candidate_stats_vpn(const RTCIceCandidateStats& stats);

// Returns the `network_adapter_type` of the provided `RTCIceCandidateStats`.
std::unique_ptr<RTCStatsMemberString>
rtc_ice_candidate_stats_network_adapter_type(
    const RTCIceCandidateStats& stats);

// RTCIceCandidateStats

// RTCOutboundRTPStreamStats
// Returns the `track_id` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberString> rtc_outbound_rtp_stream_stats_track_id(
    const RTCOutboundRTPStreamStats& stats);

// Returns the `kind` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberString> rtc_outbound_rtp_stream_stats_kind(
    const RTCOutboundRTPStreamStats& stats);

// Returns the `media_source_id` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberString>
rtc_outbound_rtp_stream_stats_media_source_id(
    const RTCOutboundRTPStreamStats& stats);

// Returns the `remote_id` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberString> rtc_outbound_rtp_stream_stats_remote_id(
    const RTCOutboundRTPStreamStats& stats);

// Returns the `rid` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberString> rtc_outbound_rtp_stream_stats_rid(
    const RTCOutboundRTPStreamStats& stats);

// Returns the `packets_sent` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_outbound_rtp_stream_stats_packets_sent(
    const RTCOutboundRTPStreamStats& stats);

// Returns the `retransmitted_packets_sent` of the provided
// `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu64>
rtc_outbound_rtp_stream_stats_retransmitted_packets_sent(
    const RTCOutboundRTPStreamStats& stats);

// Returns the `bytes_sent` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_outbound_rtp_stream_stats_bytes_sent(
    const RTCOutboundRTPStreamStats& stats);

// Returns the `header_bytes_sent` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu64>
rtc_outbound_rtp_stream_stats_header_bytes_sent(
    const RTCOutboundRTPStreamStats& stats);

// Returns the `retransmitted_bytes_sent` of the provided
// `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu64>
rtc_outbound_rtp_stream_stats_retransmitted_bytes_sent(
    const RTCOutboundRTPStreamStats& stats);

// Returns the `target_bitrate` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberf64>
rtc_outbound_rtp_stream_stats_target_bitrate(
    const RTCOutboundRTPStreamStats& stats);

// Returns the `frames_encoded` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32>
rtc_outbound_rtp_stream_stats_frames_encoded(
    const RTCOutboundRTPStreamStats& stats);

// Returns the `key_frames_encoded` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32>
rtc_outbound_rtp_stream_stats_key_frames_encoded(
    const RTCOutboundRTPStreamStats& stats);

// Returns the `total_encode_time` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberf64>
rtc_outbound_rtp_stream_stats_total_encode_time(
    const RTCOutboundRTPStreamStats& stats);

// Returns the `total_encoded_bytes_target` of the provided
// `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu64>
rtc_outbound_rtp_stream_stats_total_encoded_bytes_target(
    const RTCOutboundRTPStreamStats& stats);

// Returns the `frame_width` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_outbound_rtp_stream_stats_frame_width(
    const RTCOutboundRTPStreamStats& stats);

// Returns the `frame_height` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_outbound_rtp_stream_stats_frame_height(
    const RTCOutboundRTPStreamStats& stats);

// Returns the `frames_per_second` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberf64>
rtc_outbound_rtp_stream_stats_frames_per_second(
    const RTCOutboundRTPStreamStats& stats);

// Returns the `frames_sent` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_outbound_rtp_stream_stats_frames_sent(
    const RTCOutboundRTPStreamStats& stats);

// Returns the `huge_frames_sent` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32>
rtc_outbound_rtp_stream_stats_huge_frames_sent(
    const RTCOutboundRTPStreamStats& stats);

// Returns the `total_packet_send_delay` of the provided
// `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberf64>
rtc_outbound_rtp_stream_stats_total_packet_send_delay(
    const RTCOutboundRTPStreamStats& stats);

// Returns the `quality_limitation_reason` of the provided
// `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberString>
rtc_outbound_rtp_stream_stats_quality_limitation_reason(
    const RTCOutboundRTPStreamStats& stats);

// Returns the `quality_limitation_resolution_changes` of the provided
// `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32>
rtc_outbound_rtp_stream_stats_quality_limitation_resolution_changes(
    const RTCOutboundRTPStreamStats& stats);

// Returns the `content_type` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberString>
rtc_outbound_rtp_stream_stats_content_type(
    const RTCOutboundRTPStreamStats& stats);

// Returns the `encoder_implementation` of the provided
// `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberString>
rtc_outbound_rtp_stream_stats_encoder_implementation(
    const RTCOutboundRTPStreamStats& stats);

// Returns the `fir_count` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_outbound_rtp_stream_stats_fir_count(
    const RTCOutboundRTPStreamStats& stats);

// Returns the `pli_count` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_outbound_rtp_stream_stats_pli_count(
    const RTCOutboundRTPStreamStats& stats);

// Returns the `nack_count` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_outbound_rtp_stream_stats_nack_count(
    const RTCOutboundRTPStreamStats& stats);

// Returns the `qp_sum` of the provided `RTCOutboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_outbound_rtp_stream_stats_qp_sum(
    const RTCOutboundRTPStreamStats& stats);
/// RTCOutboundRTPStreamStats

// RTCInboundRTPStreamStats
// Returns the `remote_id` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberString> rtc_inbound_rtp_stream_stats_remote_id(
    const RTCInboundRTPStreamStats& stats);

// Returns the `packets_received` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32>
rtc_inbound_rtp_stream_stats_packets_received(
    const RTCInboundRTPStreamStats& stats);

// Returns the `fec_packets_received` of the provided
// `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu64>
rtc_inbound_rtp_stream_stats_fec_packets_received(
    const RTCInboundRTPStreamStats& stats);

// Returns the `fec_packets_discarded` of the provided
// `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu64>
rtc_inbound_rtp_stream_stats_fec_packets_discarded(
    const RTCInboundRTPStreamStats& stats);

// Returns the `bytes_received` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu64>
rtc_inbound_rtp_stream_stats_bytes_received(
    const RTCInboundRTPStreamStats& stats);

// Returns the `header_bytes_received` of the provided
// `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu64>
rtc_inbound_rtp_stream_stats_header_bytes_received(
    const RTCInboundRTPStreamStats& stats);

// Returns the `last_packet_received_timestamp` of the provided
// `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberf64>
rtc_inbound_rtp_stream_stats_last_packet_received_timestamp(
    const RTCInboundRTPStreamStats& stats);

// Returns the `jitter_buffer_delay` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberf64>
rtc_inbound_rtp_stream_stats_jitter_buffer_delay(
    const RTCInboundRTPStreamStats& stats);

// Returns the `jitter_buffer_emitted_count` of the provided
// `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu64>
rtc_inbound_rtp_stream_stats_jitter_buffer_emitted_count(
    const RTCInboundRTPStreamStats& stats);

// Returns the `total_samples_received` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu64>
rtc_inbound_rtp_stream_stats_total_samples_received(
    const RTCInboundRTPStreamStats& stats);

// Returns the `concealed_samples` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu64>
rtc_inbound_rtp_stream_stats_concealed_samples(
    const RTCInboundRTPStreamStats& stats);

// Returns the `silent_concealed_samples` of the provided
// `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu64>
rtc_inbound_rtp_stream_stats_silent_concealed_samples(
    const RTCInboundRTPStreamStats& stats);

// Returns the `concealment_events` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu64>
rtc_inbound_rtp_stream_stats_concealment_events(
    const RTCInboundRTPStreamStats& stats);

// Returns the `inserted_samples_for_deceleration` of the provided
// `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu64>
rtc_inbound_rtp_stream_stats_inserted_samples_for_deceleration(
    const RTCInboundRTPStreamStats& stats);

// Returns the `removed_samples_for_acceleration` of the provided
// `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu64>
rtc_inbound_rtp_stream_stats_removed_samples_for_acceleration(
    const RTCInboundRTPStreamStats& stats);

// Returns the `audio_level` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_audio_level(
    const RTCInboundRTPStreamStats& stats);

// Returns the `total_audio_energy` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberf64>
rtc_inbound_rtp_stream_stats_total_audio_energy(
    const RTCInboundRTPStreamStats& stats);

// Returns the `total_samples_duration` of the provided
// `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberf64>
rtc_inbound_rtp_stream_stats_total_samples_duration(
    const RTCInboundRTPStreamStats& stats);

// Returns the `frames_received` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberi32> rtc_inbound_rtp_stream_stats_frames_received(
    const RTCInboundRTPStreamStats& stats);

// Returns the `round_trip_time` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_round_trip_time(
    const RTCInboundRTPStreamStats& stats);

// Returns the `packets_repaired` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32>
rtc_inbound_rtp_stream_stats_packets_repaired(
    const RTCInboundRTPStreamStats& stats);

// Returns the `burst_packets_lost` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32>
rtc_inbound_rtp_stream_stats_burst_packets_lost(
    const RTCInboundRTPStreamStats& stats);

// Returns the `burst_packets_discarded` of the provided
// `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32>
rtc_inbound_rtp_stream_stats_burst_packets_discarded(
    const RTCInboundRTPStreamStats& stats);

// Returns the `burst_loss_count` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32>
rtc_inbound_rtp_stream_stats_burst_loss_count(
    const RTCInboundRTPStreamStats& stats);

// Returns the `burst_discard_count` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32>
rtc_inbound_rtp_stream_stats_burst_discard_count(
    const RTCInboundRTPStreamStats& stats);

// Returns the `burst_loss_rate` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_burst_loss_rate(
    const RTCInboundRTPStreamStats& stats);

// Returns the `burst_discard_rate` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberf64>
rtc_inbound_rtp_stream_stats_burst_discard_rate(
    const RTCInboundRTPStreamStats& stats);

// Returns the `gap_loss_rate` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberf64> rtc_inbound_rtp_stream_stats_gap_loss_rate(
    const RTCInboundRTPStreamStats& stats);

// Returns the `gap_discard_rate` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberf64>
rtc_inbound_rtp_stream_stats_gap_discard_rate(
    const RTCInboundRTPStreamStats& stats);

// Returns the `frame_width` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_frame_width(
    const RTCInboundRTPStreamStats& stats);

// Returns the `frame_height` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_frame_height(
    const RTCInboundRTPStreamStats& stats);

// Returns the `frame_bit_depth` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_frame_bit_depth(
    const RTCInboundRTPStreamStats& stats);

// Returns the `frames_per_second` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberf64>
rtc_inbound_rtp_stream_stats_frames_per_second(
    const RTCInboundRTPStreamStats& stats);

// Returns the `frames_decoded` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_frames_decoded(
    const RTCInboundRTPStreamStats& stats);

// Returns the `key_frames_decoded` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32>
rtc_inbound_rtp_stream_stats_key_frames_decoded(
    const RTCInboundRTPStreamStats& stats);

// Returns the `frames_dropped` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_frames_dropped(
    const RTCInboundRTPStreamStats& stats);

// Returns the `total_decode_time` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberf64>
rtc_inbound_rtp_stream_stats_total_decode_time(
    const RTCInboundRTPStreamStats& stats);

// Returns the `total_inter_frame_delay` of the provided
// `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberf64>
rtc_inbound_rtp_stream_stats_total_inter_frame_delay(
    const RTCInboundRTPStreamStats& stats);

// Returns the `total_squared_inter_frame_delay` of the provided
// `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberf64>
rtc_inbound_rtp_stream_stats_total_squared_inter_frame_delay(
    const RTCInboundRTPStreamStats& stats);

// Returns the `content_type` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberString> rtc_inbound_rtp_stream_stats_content_type(
    const RTCInboundRTPStreamStats& stats);

// Returns the `estimated_playout_timestamp` of the provided
// `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberf64>
rtc_inbound_rtp_stream_stats_estimated_playout_timestamp(
    const RTCInboundRTPStreamStats& stats);

// Returns the `decoder_implementation` of the provided
// `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberString>
rtc_inbound_rtp_stream_stats_decoder_implementation(
    const RTCInboundRTPStreamStats& stats);

// Returns the `fir_count` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_fir_count(
    const RTCInboundRTPStreamStats& stats);

// Returns the `pli_count` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_pli_count(
    const RTCInboundRTPStreamStats& stats);

// Returns the `nack_count` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu32> rtc_inbound_rtp_stream_stats_nack_count(
    const RTCInboundRTPStreamStats& stats);

// Returns the `qp_sum` of the provided `RTCInboundRTPStreamStats`.
std::unique_ptr<RTCStatsMemberu64>
rtc_inbound_rtp_stream_stats_qp_sum(const RTCInboundRTPStreamStats& stats);

/// RTCInboundRTPStreamStats

// RTCIceCandidatePairStats
// Returns the `transport_id` of the provided `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_pair_stats_transport_id(
    const RTCIceCandidatePairStats& stats);

// Returns the `local_candidate_id` of the provided `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberString>
rtc_ice_candidate_pair_stats_local_candidate_id(
    const RTCIceCandidatePairStats& stats);

// Returns the `remote_candidate_id` of the provided `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberString>
rtc_ice_candidate_pair_stats_remote_candidate_id(
    const RTCIceCandidatePairStats& stats);

// Returns the `state` of the provided `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberString> rtc_ice_candidate_pair_stats_state(
    const RTCIceCandidatePairStats& stats);

// Returns the `priority` of the provided `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_priority(
    const RTCIceCandidatePairStats& stats);

// Returns the `nominated` of the provided `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberbool>
rtc_ice_candidate_pair_stats_nominated(
    const RTCIceCandidatePairStats& stats);

// Returns the `writable` of the provided `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberbool>
rtc_ice_candidate_pair_stats_writable(
    const RTCIceCandidatePairStats& stats);

// Returns the `readable` of the provided `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberbool>
rtc_ice_candidate_pair_stats_readable(
    const RTCIceCandidatePairStats& stats);

// Returns the `packets_sent` of the provided `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_packets_sent(
    const RTCIceCandidatePairStats& stats);

// Returns the `packets_received` of the provided `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberu64>
rtc_ice_candidate_pair_stats_packets_received(
    const RTCIceCandidatePairStats&
    stats);

// Returns the `bytes_sent` of the provided `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_bytes_sent(
    const RTCIceCandidatePairStats& stats);

// Returns the `bytes_received` of the provided `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_bytes_received(
    const RTCIceCandidatePairStats& stats);

// Returns the `total_round_trip_time` of the provided
// `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberf64>
rtc_ice_candidate_pair_stats_total_round_trip_time(
    const RTCIceCandidatePairStats& stats);

// Returns the `current_round_trip_time` of the provided
// `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberf64>
rtc_ice_candidate_pair_stats_current_round_trip_time(
    const RTCIceCandidatePairStats& stats);

// Returns the `available_outgoing_bitrate` of the provided
// `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberf64>
rtc_ice_candidate_pair_stats_available_outgoing_bitrate(
    const RTCIceCandidatePairStats& stats);

// Returns the `available_incoming_bitrate` of the provided
// `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberf64>
rtc_ice_candidate_pair_stats_available_incoming_bitrate(
    const RTCIceCandidatePairStats& stats);

// Returns the `requests_received` of the provided `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberu64>
rtc_ice_candidate_pair_stats_requests_received(
    const RTCIceCandidatePairStats& stats);

// Returns the `requests_sent` of the provided `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_requests_sent(
    const RTCIceCandidatePairStats& stats);

// Returns the `responses_received` of the provided `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberu64>
rtc_ice_candidate_pair_stats_responses_received(
    const RTCIceCandidatePairStats& stats);

// Returns the `responses_sent` of the provided `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_ice_candidate_pair_stats_responses_sent(
    const RTCIceCandidatePairStats& stats);

// Returns the `retransmissions_received` of the provided
// `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberu64>
rtc_ice_candidate_pair_stats_retransmissions_received(
    const RTCIceCandidatePairStats& stats);

// Returns the `retransmissions_sent` of the provided
// `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberu64>
rtc_ice_candidate_pair_stats_retransmissions_sent(
    const RTCIceCandidatePairStats& stats);

// Returns the `consent_requests_received` of the provided
// `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberu64>
rtc_ice_candidate_pair_stats_consent_requests_received(
    const RTCIceCandidatePairStats& stats);

// Returns the `consent_requests_sent` of the provided
// `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberu64>
rtc_ice_candidate_pair_stats_consent_requests_sent(
    const RTCIceCandidatePairStats& stats);

// Returns the `consent_responses_received` of the provided
// `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberu64>
rtc_ice_candidate_pair_stats_consent_responses_received(
    const RTCIceCandidatePairStats& stats);

// Returns the `consent_responses_sent` of the provided
// `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberu64>
rtc_ice_candidate_pair_stats_consent_responses_sent(
    const RTCIceCandidatePairStats& stats);

// Returns the `packets_discarded_on_send` of the provided
// `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberu64>
rtc_ice_candidate_pair_stats_packets_discarded_on_send(
    const RTCIceCandidatePairStats& stats);

// Returns the `bytes_discarded_on_send` of the provided
// `RTCIceCandidatePairStats`.
std::unique_ptr<RTCStatsMemberu64>
rtc_ice_candidate_pair_stats_bytes_discarded_on_send(
    const RTCIceCandidatePairStats& stats);

// RTCIceCandidatePairStats

// RTCTransportStats
// Returns the `bytes_sent` of the provided `RTCTransportStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_transport_stats_bytes_sent(
    const RTCTransportStats& stats);

// Returns the `packets_sent` of the provided `RTCTransportStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_transport_stats_packets_sent(
    const RTCTransportStats& stats);

// Returns the `bytes_received` of the provided `RTCTransportStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_transport_stats_bytes_received(
    const RTCTransportStats& stats);

// Returns the `packets_received` of the provided `RTCTransportStats`.
std::unique_ptr<RTCStatsMemberu64> rtc_transport_stats_packets_received(
    const RTCTransportStats& stats);

// Returns the `rtcp_transport_stats_id` of the provided `RTCTransportStats`.
std::unique_ptr<RTCStatsMemberString>
rtc_transport_stats_rtcp_transport_stats_id(
    const RTCTransportStats& stats);

// Returns the `dtls_state` of the provided `RTCTransportStats`.
std::unique_ptr<RTCStatsMemberString> rtc_transport_stats_dtls_state(
    const RTCTransportStats& stats);

// Returns the `selected_candidate_pair_id` of the provided `RTCTransportStats`.
std::unique_ptr<RTCStatsMemberString>
rtc_transport_stats_selected_candidate_pair_id(
    const RTCTransportStats& stats);

// Returns the `local_certificate_id` of the provided `RTCTransportStats`.
std::unique_ptr<RTCStatsMemberString> rtc_transport_stats_local_certificate_id(
    const RTCTransportStats& stats);

// Returns the `remote_certificate_id` of the provided `RTCTransportStats`.
std::unique_ptr<RTCStatsMemberString> rtc_transport_stats_remote_certificate_id(
    const RTCTransportStats& stats);

// Returns the `tls_version` of the provided `RTCTransportStats`.
std::unique_ptr<RTCStatsMemberString> rtc_transport_stats_tls_version(
    const RTCTransportStats& stats);

// Returns the `dtls_cipher` of the provided `RTCTransportStats`.
std::unique_ptr<RTCStatsMemberString> rtc_transport_stats_dtls_cipher(
    const RTCTransportStats& stats);

// Returns the `srtp_cipher` of the provided `RTCTransportStats`.
std::unique_ptr<RTCStatsMemberString> rtc_transport_stats_srtp_cipher(
    const RTCTransportStats& stats);

// Returns the `selected_candidate_pair_changes` of the provided
// `RTCTransportStats`.
std::unique_ptr<RTCStatsMemberu32>
rtc_transport_stats_selected_candidate_pair_changes(
    const RTCTransportStats& stats);

// RTCTransportStats

// RTCRemoteInboundRtpStreamStats
// Returns the `local_id` of the provided `RTCRemoteInboundRtpStreamStats`.
std::unique_ptr<RTCStatsMemberString>
rtc_remote_inbound_rtp_stream_stats_local_id(
    const RTCRemoteInboundRtpStreamStats& stats);

// Returns the `round_trip_time` of the provided
// `RTCRemoteInboundRtpStreamStats`.
std::unique_ptr<RTCStatsMemberf64>
rtc_remote_inbound_rtp_stream_stats_round_trip_time(
    const RTCRemoteInboundRtpStreamStats& stats);

// Returns the `fraction_lost` of the provided `RTCRemoteInboundRtpStreamStats`.
std::unique_ptr<RTCStatsMemberf64>
rtc_remote_inbound_rtp_stream_stats_fraction_lost(
    const RTCRemoteInboundRtpStreamStats& stats);

// Returns the `total_round_trip_time` of the provided
// `RTCRemoteInboundRtpStreamStats`.
std::unique_ptr<RTCStatsMemberf64>
rtc_remote_inbound_rtp_stream_stats_total_round_trip_time(
    const RTCRemoteInboundRtpStreamStats& stats);

// Returns the `round_trip_time_measurements` of the provided
// `RTCRemoteInboundRtpStreamStats`.
std::unique_ptr<RTCStatsMemberi32> round_trip_time_measurements(
    const RTCRemoteInboundRtpStreamStats& stats);

/// RTCRemoteInboundRtpStreamStats

// RTCRemoteOutboundRtpStreamStats

// Returns the `local_id` of the provided `RTCRemoteOutboundRtpStreamStats`.
std::unique_ptr<RTCStatsMemberString>
rtc_remote_outbound_rtp_stream_stats_local_id(
    const RTCRemoteOutboundRtpStreamStats& stats);

// Returns the `remote_timestamp` of the provided
// `RTCRemoteOutboundRtpStreamStats`.
std::unique_ptr<RTCStatsMemberf64>
rtc_remote_outbound_rtp_stream_stats_remote_timestamp(
    const RTCRemoteOutboundRtpStreamStats& stats);

// Returns the `reports_sent` of the provided `RTCRemoteOutboundRtpStreamStats`.
std::unique_ptr<RTCStatsMemberu64>
rtc_remote_outbound_rtp_stream_stats_reports_sent(
    const RTCRemoteOutboundRtpStreamStats& stats);

// Returns the `round_trip_time` of the provided
// `RTCRemoteOutboundRtpStreamStats`.
std::unique_ptr<RTCStatsMemberf64>
rtc_remote_outbound_rtp_stream_stats_round_trip_time(
    const RTCRemoteOutboundRtpStreamStats& stats);

// Returns the `round_trip_time_measurements` of the provided
// `RTCRemoteOutboundRtpStreamStats`.
std::unique_ptr<RTCStatsMemberu64>
rtc_remote_outbound_rtp_stream_stats_round_trip_time_measurements(
    const RTCRemoteOutboundRtpStreamStats& stats);

// Returns the `total_round_trip_time` of the provided
// `RTCRemoteOutboundRtpStreamStats`.
std::unique_ptr<RTCStatsMemberf64>
rtc_remote_outbound_rtp_stream_stats_total_round_trip_time(
    const RTCRemoteOutboundRtpStreamStats& stats);

/// RTCRemoteOutboundRtpStreamStats

// Returns collection `RTCStats` of the provided `RTCStatsReport`.
rust::Vec<RTCStatsContainer> rtc_stats_report_get_stats(
    const RTCStatsReport& report);

}  // namespace bridge
