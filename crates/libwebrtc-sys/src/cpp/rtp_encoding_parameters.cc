#include "rtp_encoding_parameters.h"
#include "rust/cxx.h"
#include <stdexcept>
#include "libwebrtc-sys/src/bridge.rs.h"

namespace bridge {

rust::String rtp_encoding_parameters_rid(const webrtc::RtpEncodingParameters& encoding) {
  return rust::String(encoding.rid.c_str());
}

// Sets the `RtpEncodingParameters.rid` field value.
void set_rtp_encoding_parameters_rid(webrtc::RtpEncodingParameters& encoding,
                                     rust::String rid) {
  encoding.rid = std::string(rid.c_str());
}

// Returns the `RtpEncodingParameters.active` field value.
bool rtp_encoding_parameters_active(
    const webrtc::RtpEncodingParameters& encoding) {
  return encoding.active;
}

// Returns the `RtpEncodingParameters.maxBitrate` field value.
int32_t rtp_encoding_parameters_max_bitrate(
    const webrtc::RtpEncodingParameters& encoding) {
      if (encoding.max_bitrate_bps.has_value()) {
        return encoding.max_bitrate_bps.value();
      } else {
        throw std::logic_error("None.");
      }
}

// Sets the `RtpEncodingParameters.active` field value.
void set_rtp_encoding_parameters_active(webrtc::RtpEncodingParameters& encoding,
                                        bool active) {
  encoding.active = active;
}

// Returns the `RtpEncodingParameters.minBitrate` field value.
int32_t rtp_encoding_parameters_min_bitrate(
    const webrtc::RtpEncodingParameters& encoding) {
      if (encoding.min_bitrate_bps.has_value()) {
        return encoding.min_bitrate_bps.value();
      } else {
        throw std::logic_error("None.");
      }
}

// Returns the `RtpEncodingParameters.maxBitrate` field value.
void set_rtp_encoding_parameters_max_bitrate(
    webrtc::RtpEncodingParameters& encoding,
    int32_t max_bitrate) {
  encoding.max_bitrate_bps = max_bitrate;
}

// Returns the `RtpEncodingParameters.maxFramerate` field value.
double rtp_encoding_parameters_max_framerate(
    const webrtc::RtpEncodingParameters& encoding) {
      if (encoding.max_framerate.has_value()) {
        return encoding.max_framerate.value();
      } else {
        throw std::logic_error("None.");
      }
}

// Sets the `RtpEncodingParameters.maxFramerate` field value.
void set_rtp_encoding_parameters_max_framerate(
    webrtc::RtpEncodingParameters& encoding,
    double max_framrate) {
  encoding.max_framerate = max_framrate;
}

// Returns the `RtpEncodingParameters.ssrc` field value.
int64_t rtp_encoding_parameters_ssrc(
    const webrtc::RtpEncodingParameters& encoding) {
      if (encoding.ssrc.has_value()) {
        return encoding.ssrc.value();
      } else {
        throw std::logic_error("None.");
      }
}

// Returns the `RtpEncodingParameters.scale_resolution_down_by` field value.
double rtp_encoding_parameters_scale_resolution_down_by(
    const webrtc::RtpEncodingParameters& encoding) {
      if (encoding.scale_resolution_down_by.has_value()) {
        return encoding.scale_resolution_down_by.value();
      } else {
        throw std::logic_error("None.");
      }
}

// Sets the `RtpEncodingParameters.scale_resolution_down_by` field value.
void set_rtp_encoding_parameters_scale_resolution_down_by(
    webrtc::RtpEncodingParameters& encoding,
    double scale_resolution_down_by) {
  encoding.scale_resolution_down_by = scale_resolution_down_by;
}

rust::cxxbridge1::Box<bridge::OptionString> rtp_encoding_parameters_scalability_mode(
  const webrtc::RtpEncodingParameters& encoding) {
  auto scalability_mode = init_option_string();

  if (encoding.scalability_mode.has_value()) {
    scalability_mode->set_value(rust::String(encoding.scalability_mode.value()));
  }

  return scalability_mode;
}

// Sets the `RtpEncodingParameters.scalability_mode` field value.
void set_rtp_encoding_parameters_scalability_mode(
    webrtc::RtpEncodingParameters& encoding,
    rust::String scalability_mode) {
  encoding.scalability_mode = std::string(scalability_mode);
}

}  // namespace bridge
