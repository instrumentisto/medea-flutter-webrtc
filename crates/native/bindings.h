#include <cstdarg>
#include <cstdint>
#include <cstdlib>
#include <ostream>
#include <new>

/// Single video `frame`.
struct VideoFrame;

struct wire_uint_8_list {
  uint8_t *ptr;
  int32_t len;
};

struct wire_StringList {
  wire_uint_8_list **ptr;
  int32_t len;
};

struct wire_RtcIceServer {
  wire_StringList *urls;
  wire_uint_8_list *username;
  wire_uint_8_list *credential;
};

struct wire_list_rtc_ice_server {
  wire_RtcIceServer *ptr;
  int32_t len;
};

struct wire_RtcConfiguration {
  int32_t ice_transport_policy;
  int32_t bundle_policy;
  wire_list_rtc_ice_server *ice_servers;
};

struct wire_AudioConstraints {
  wire_uint_8_list *device_id;
};

struct wire_VideoConstraints {
  wire_uint_8_list *device_id;
  uint32_t width;
  uint32_t height;
  uint32_t frame_rate;
  bool is_display;
};

struct wire_MediaStreamConstraints {
  wire_AudioConstraints *audio;
  wire_VideoConstraints *video;
};

/// [`sys::VideoFrame`] and metadata which will be passed
/// to the C API renderer.
struct Frame {
  /// Height of the [`Frame`].
  uintptr_t height;
  /// Width of the [`Frame`].
  uintptr_t width;
  /// Rotation of the [`Frame`].
  int32_t rotation;
  /// Size of the [`Frame`] buffer.
  uintptr_t buffer_size;
  /// Actual [`sys::VideoFrame`].
  VideoFrame *frame;
};

extern "C" {

void wire_enumerate_devices(int64_t port_);

void wire_create_peer_connection(int64_t port_, wire_RtcConfiguration *configuration);

void wire_create_offer(int64_t port_,
                       uint64_t peer_id,
                       bool voice_activity_detection,
                       bool ice_restart,
                       bool use_rtp_mux);

void wire_create_answer(int64_t port_,
                        uint64_t peer_id,
                        bool voice_activity_detection,
                        bool ice_restart,
                        bool use_rtp_mux);

void wire_set_local_description(int64_t port_,
                                uint64_t peer_id,
                                int32_t kind,
                                wire_uint_8_list *sdp);

void wire_set_remote_description(int64_t port_,
                                 uint64_t peer_id,
                                 int32_t kind,
                                 wire_uint_8_list *sdp);

void wire_add_transceiver(int64_t port_, uint64_t peer_id, int32_t media_type, int32_t direction);

void wire_get_transceivers(int64_t port_, uint64_t peer_id);

void wire_set_transceiver_direction(int64_t port_,
                                    uint64_t peer_id,
                                    uint32_t transceiver_index,
                                    int32_t direction);

void wire_set_transceiver_recv(int64_t port_,
                               uint64_t peer_id,
                               uint32_t transceiver_index,
                               bool recv);

void wire_set_transceiver_send(int64_t port_,
                               uint64_t peer_id,
                               uint32_t transceiver_index,
                               bool send);

void wire_get_transceiver_mid(int64_t port_, uint64_t peer_id, uint32_t transceiver_index);

void wire_get_transceiver_direction(int64_t port_, uint64_t peer_id, uint32_t transceiver_index);

void wire_stop_transceiver(int64_t port_, uint64_t peer_id, uint32_t transceiver_index);

void wire_sender_replace_track(int64_t port_,
                               uint64_t peer_id,
                               uint32_t transceiver_index,
                               wire_uint_8_list *track_id);

void wire_add_ice_candidate(int64_t port_,
                            uint64_t peer_id,
                            wire_uint_8_list *candidate,
                            wire_uint_8_list *sdp_mid,
                            int32_t sdp_mline_index);

void wire_restart_ice(int64_t port_, uint64_t peer_id);

void wire_dispose_peer_connection(int64_t port_, uint64_t peer_id);

void wire_get_media(int64_t port_, wire_MediaStreamConstraints *constraints);

void wire_set_audio_playout_device(int64_t port_, wire_uint_8_list *device_id);

void wire_microphone_volume_is_available(int64_t port_);

void wire_set_microphone_volume(int64_t port_, uint8_t level);

void wire_microphone_volume(int64_t port_);

void wire_dispose_track(int64_t port_, wire_uint_8_list *track_id, int32_t kind);

void wire_track_state(int64_t port_, wire_uint_8_list *track_id, int32_t kind);

void wire_set_track_enabled(int64_t port_, wire_uint_8_list *track_id, int32_t kind, bool enabled);

void wire_clone_track(int64_t port_, wire_uint_8_list *track_id, int32_t kind);

void wire_register_track_observer(int64_t port_, wire_uint_8_list *track_id, int32_t kind);

void wire_set_on_device_changed(int64_t port_);

void wire_create_video_sink(int64_t port_,
                            int64_t sink_id,
                            wire_uint_8_list *track_id,
                            uint64_t callback_ptr);

void wire_dispose_video_sink(int64_t port_, int64_t sink_id);

wire_StringList *new_StringList(int32_t len);

wire_AudioConstraints *new_box_autoadd_audio_constraints();

wire_MediaStreamConstraints *new_box_autoadd_media_stream_constraints();

wire_RtcConfiguration *new_box_autoadd_rtc_configuration();

wire_VideoConstraints *new_box_autoadd_video_constraints();

wire_list_rtc_ice_server *new_list_rtc_ice_server(int32_t len);

wire_uint_8_list *new_uint_8_list(int32_t len);

void free_WireSyncReturnStruct(WireSyncReturnStruct val);

/// C side function into which [`Frame`]s will be passed.
extern void on_frame_caller(const void *handler, Frame frame);

/// Destructor for the C side renderer.
extern void drop_handler(const void *handler);

} // extern "C"
