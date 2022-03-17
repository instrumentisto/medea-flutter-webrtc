#![allow(
    non_camel_case_types,
    unused,
    clippy::redundant_closure,
    clippy::useless_conversion,
    clippy::unit_arg,
    non_snake_case
)]
// AUTO GENERATED FILE, DO NOT EDIT.
// Generated by `flutter_rust_bridge`.

use crate::api::*;
use flutter_rust_bridge::*;

// Section: imports

// Section: wire functions

#[no_mangle]
pub extern "C" fn wire_create_peer_connection(
    port_: i64,
    configuration: *mut wire_RtcConfiguration,
    id: u64,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "create_peer_connection",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_configuration = configuration.wire2api();
            let api_id = id.wire2api();
            move |task_callback| create_peer_connection(api_configuration, api_id)
        },
    )
}

#[no_mangle]
pub extern "C" fn wire_create_offer(
    port_: i64,
    peer_id: u64,
    voice_activity_detection: bool,
    ice_restart: bool,
    use_rtp_mux: bool,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "create_offer",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_peer_id = peer_id.wire2api();
            let api_voice_activity_detection = voice_activity_detection.wire2api();
            let api_ice_restart = ice_restart.wire2api();
            let api_use_rtp_mux = use_rtp_mux.wire2api();
            move |task_callback| {
                Ok(create_offer(
                    api_peer_id,
                    api_voice_activity_detection,
                    api_ice_restart,
                    api_use_rtp_mux,
                ))
            }
        },
    )
}

#[no_mangle]
pub extern "C" fn wire_create_answer(
    port_: i64,
    peer_connection_id: u64,
    voice_activity_detection: bool,
    ice_restart: bool,
    use_rtp_mux: bool,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "create_answer",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_peer_connection_id = peer_connection_id.wire2api();
            let api_voice_activity_detection = voice_activity_detection.wire2api();
            let api_ice_restart = ice_restart.wire2api();
            let api_use_rtp_mux = use_rtp_mux.wire2api();
            move |task_callback| {
                Ok(create_answer(
                    api_peer_connection_id,
                    api_voice_activity_detection,
                    api_ice_restart,
                    api_use_rtp_mux,
                ))
            }
        },
    )
}

#[no_mangle]
pub extern "C" fn wire_set_local_description(
    port_: i64,
    peer_connection_id: u64,
    kind: *mut wire_uint_8_list,
    sdp: *mut wire_uint_8_list,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "set_local_description",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_peer_connection_id = peer_connection_id.wire2api();
            let api_kind = kind.wire2api();
            let api_sdp = sdp.wire2api();
            move |task_callback| {
                Ok(set_local_description(
                    api_peer_connection_id,
                    api_kind,
                    api_sdp,
                ))
            }
        },
    )
}

#[no_mangle]
pub extern "C" fn wire_set_remote_description(
    port_: i64,
    peer_connection_id: u64,
    kind: *mut wire_uint_8_list,
    sdp: *mut wire_uint_8_list,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "set_remote_description",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_peer_connection_id = peer_connection_id.wire2api();
            let api_kind = kind.wire2api();
            let api_sdp = sdp.wire2api();
            move |task_callback| {
                Ok(set_remote_description(
                    api_peer_connection_id,
                    api_kind,
                    api_sdp,
                ))
            }
        },
    )
}

#[no_mangle]
pub extern "C" fn wire_add_transceiver(
    port_: i64,
    peer_id: u64,
    media_type: i32,
    direction: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "add_transceiver",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_peer_id = peer_id.wire2api();
            let api_media_type = media_type.wire2api();
            let api_direction = direction.wire2api();
            move |task_callback| {
                Ok(add_transceiver(api_peer_id, api_media_type, api_direction))
            }
        },
    )
}

#[no_mangle]
pub extern "C" fn wire_get_transceivers(port_: i64, peer_id: u64) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "get_transceivers",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_peer_id = peer_id.wire2api();
            move |task_callback| Ok(get_transceivers(api_peer_id))
        },
    )
}

#[no_mangle]
pub extern "C" fn wire_set_transceiver_direction(
    port_: i64,
    peer_id: u64,
    transceiver_id: u64,
    direction: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "set_transceiver_direction",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_peer_id = peer_id.wire2api();
            let api_transceiver_id = transceiver_id.wire2api();
            let api_direction = direction.wire2api();
            move |task_callback| {
                Ok(set_transceiver_direction(
                    api_peer_id,
                    api_transceiver_id,
                    api_direction,
                ))
            }
        },
    )
}

#[no_mangle]
pub extern "C" fn wire_get_transceiver_mid(port_: i64, peer_id: u64, transceiver_id: u64) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "get_transceiver_mid",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_peer_id = peer_id.wire2api();
            let api_transceiver_id = transceiver_id.wire2api();
            move |task_callback| Ok(get_transceiver_mid(api_peer_id, api_transceiver_id))
        },
    )
}

#[no_mangle]
pub extern "C" fn wire_get_transceiver_direction(
    port_: i64,
    peer_id: u64,
    transceiver_id: u64,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "get_transceiver_direction",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_peer_id = peer_id.wire2api();
            let api_transceiver_id = transceiver_id.wire2api();
            move |task_callback| {
                Ok(get_transceiver_direction(api_peer_id, api_transceiver_id))
            }
        },
    )
}

#[no_mangle]
pub extern "C" fn wire_stop_transceiver(port_: i64, peer_id: u64, transceiver_id: u64) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "stop_transceiver",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_peer_id = peer_id.wire2api();
            let api_transceiver_id = transceiver_id.wire2api();
            move |task_callback| Ok(stop_transceiver(api_peer_id, api_transceiver_id))
        },
    )
}

#[no_mangle]
pub extern "C" fn wire_sender_replace_track(
    port_: i64,
    peer_id: u64,
    transceiver_id: u64,
    track_id: u64,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "sender_replace_track",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_peer_id = peer_id.wire2api();
            let api_transceiver_id = transceiver_id.wire2api();
            let api_track_id = track_id.wire2api();
            move |task_callback| {
                Ok(sender_replace_track(
                    api_peer_id,
                    api_transceiver_id,
                    api_track_id,
                ))
            }
        },
    )
}

#[no_mangle]
pub extern "C" fn wire_add_ice_candidate(
    port_: i64,
    peer_id: u64,
    candidate: *mut wire_uint_8_list,
    sdp_mid: *mut wire_uint_8_list,
    sdp_mline_index: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "add_ice_candidate",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_peer_id = peer_id.wire2api();
            let api_candidate = candidate.wire2api();
            let api_sdp_mid = sdp_mid.wire2api();
            let api_sdp_mline_index = sdp_mline_index.wire2api();
            move |task_callback| {
                Ok(add_ice_candidate(
                    api_peer_id,
                    api_candidate,
                    api_sdp_mid,
                    api_sdp_mline_index,
                ))
            }
        },
    )
}

#[no_mangle]
pub extern "C" fn wire_restart_ice(port_: i64, peer_id: u64) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "restart_ice",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_peer_id = peer_id.wire2api();
            move |task_callback| Ok(restart_ice(api_peer_id))
        },
    )
}

#[no_mangle]
pub extern "C" fn wire_dispose_peer_connection(port_: i64, peer_id: u64) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "dispose_peer_connection",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_peer_id = peer_id.wire2api();
            move |task_callback| Ok(dispose_peer_connection(api_peer_id))
        },
    )
}

#[no_mangle]
pub extern "C" fn wire_dispose_stream(port_: i64, id: u64) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "dispose_stream",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_id = id.wire2api();
            move |task_callback| Ok(dispose_stream(api_id))
        },
    )
}

#[no_mangle]
pub extern "C" fn wire_set_track_enabled(port_: i64, track_id: u64, enabled: bool) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "set_track_enabled",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_track_id = track_id.wire2api();
            let api_enabled = enabled.wire2api();
            move |task_callback| Ok(set_track_enabled(api_track_id, api_enabled))
        },
    )
}

#[no_mangle]
pub extern "C" fn wire_create_video_sink(
    port_: i64,
    sink_id: i64,
    track_id: u64,
    callback_ptr: u64,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "create_video_sink",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_sink_id = sink_id.wire2api();
            let api_track_id = track_id.wire2api();
            let api_callback_ptr = callback_ptr.wire2api();
            move |task_callback| {
                Ok(create_video_sink(
                    api_sink_id,
                    api_track_id,
                    api_callback_ptr,
                ))
            }
        },
    )
}

#[no_mangle]
pub extern "C" fn wire_dispose_video_sink(port_: i64, sink_id: i64) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "dispose_video_sink",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_sink_id = sink_id.wire2api();
            move |task_callback| Ok(dispose_video_sink(api_sink_id))
        },
    )
}

#[no_mangle]
pub extern "C" fn wire_enumerate_devices(port_: i64) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "enumerate_devices",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || move |task_callback| Ok(enumerate_devices()),
    )
}

#[no_mangle]
pub extern "C" fn wire_get_media(port_: i64, constraints: *mut wire_MediaStreamConstraints) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "get_media",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_constraints = constraints.wire2api();
            move |task_callback| Ok(get_media(api_constraints))
        },
    )
}

#[no_mangle]
pub extern "C" fn wire__touch(
    port_: i64,
    a: *mut wire_RtcIceServer,
    b: *mut wire_RtcConfiguration,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "_touch",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_a = a.wire2api();
            let api_b = b.wire2api();
            move |task_callback| Ok(_touch(api_a, api_b))
        },
    )
}

// Section: wire structs

#[repr(C)]
#[derive(Clone)]
pub struct wire_StringList {
    ptr: *mut *mut wire_uint_8_list,
    len: i32,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_AudioConstraints {
    device_id: *mut wire_uint_8_list,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_list_rtc_ice_server {
    ptr: *mut wire_RtcIceServer,
    len: i32,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_MediaStreamConstraints {
    audio: *mut wire_AudioConstraints,
    video: *mut wire_VideoConstraints,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_RtcConfiguration {
    ice_transport_policy: *mut wire_uint_8_list,
    bundle_policy: *mut wire_uint_8_list,
    ice_servers: *mut wire_list_rtc_ice_server,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_RtcIceServer {
    urls: *mut wire_StringList,
    username: *mut wire_uint_8_list,
    credential: *mut wire_uint_8_list,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_uint_8_list {
    ptr: *mut u8,
    len: i32,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_VideoConstraints {
    device_id: *mut wire_uint_8_list,
    width: u32,
    height: u32,
    frame_rate: u32,
    is_display: bool,
}

// Section: wrapper structs

// Section: static checks

// Section: allocate functions

#[no_mangle]
pub extern "C" fn new_StringList(len: i32) -> *mut wire_StringList {
    let wrap = wire_StringList {
        ptr: support::new_leak_vec_ptr(<*mut wire_uint_8_list>::new_with_null_ptr(), len),
        len,
    };
    support::new_leak_box_ptr(wrap)
}

#[no_mangle]
pub extern "C" fn new_box_autoadd_audio_constraints() -> *mut wire_AudioConstraints {
    support::new_leak_box_ptr(wire_AudioConstraints::new_with_null_ptr())
}

#[no_mangle]
pub extern "C" fn new_box_autoadd_media_stream_constraints(
) -> *mut wire_MediaStreamConstraints {
    support::new_leak_box_ptr(wire_MediaStreamConstraints::new_with_null_ptr())
}

#[no_mangle]
pub extern "C" fn new_box_autoadd_rtc_configuration() -> *mut wire_RtcConfiguration {
    support::new_leak_box_ptr(wire_RtcConfiguration::new_with_null_ptr())
}

#[no_mangle]
pub extern "C" fn new_box_autoadd_rtc_ice_server() -> *mut wire_RtcIceServer {
    support::new_leak_box_ptr(wire_RtcIceServer::new_with_null_ptr())
}

#[no_mangle]
pub extern "C" fn new_box_autoadd_video_constraints() -> *mut wire_VideoConstraints {
    support::new_leak_box_ptr(wire_VideoConstraints::new_with_null_ptr())
}

#[no_mangle]
pub extern "C" fn new_list_rtc_ice_server(len: i32) -> *mut wire_list_rtc_ice_server {
    let wrap = wire_list_rtc_ice_server {
        ptr: support::new_leak_vec_ptr(<wire_RtcIceServer>::new_with_null_ptr(), len),
        len,
    };
    support::new_leak_box_ptr(wrap)
}

#[no_mangle]
pub extern "C" fn new_uint_8_list(len: i32) -> *mut wire_uint_8_list {
    let ans = wire_uint_8_list {
        ptr: support::new_leak_vec_ptr(Default::default(), len),
        len,
    };
    support::new_leak_box_ptr(ans)
}

// Section: impl Wire2Api

pub trait Wire2Api<T> {
    fn wire2api(self) -> T;
}

impl<T, S> Wire2Api<Option<T>> for *mut S
where
    *mut S: Wire2Api<T>,
{
    fn wire2api(self) -> Option<T> {
        if self.is_null() {
            None
        } else {
            Some(self.wire2api())
        }
    }
}

impl Wire2Api<String> for *mut wire_uint_8_list {
    fn wire2api(self) -> String {
        let vec: Vec<u8> = self.wire2api();
        String::from_utf8_lossy(&vec).into_owned()
    }
}

impl Wire2Api<Vec<String>> for *mut wire_StringList {
    fn wire2api(self) -> Vec<String> {
        let vec = unsafe {
            let wrap = support::box_from_leak_ptr(self);
            support::vec_from_leak_ptr(wrap.ptr, wrap.len)
        };
        vec.into_iter().map(Wire2Api::wire2api).collect()
    }
}

impl Wire2Api<AudioConstraints> for wire_AudioConstraints {
    fn wire2api(self) -> AudioConstraints {
        AudioConstraints {
            device_id: self.device_id.wire2api(),
        }
    }
}

impl Wire2Api<bool> for bool {
    fn wire2api(self) -> bool {
        self
    }
}

impl Wire2Api<AudioConstraints> for *mut wire_AudioConstraints {
    fn wire2api(self) -> AudioConstraints {
        let wrap = unsafe { support::box_from_leak_ptr(self) };
        (*wrap).wire2api().into()
    }
}

impl Wire2Api<MediaStreamConstraints> for *mut wire_MediaStreamConstraints {
    fn wire2api(self) -> MediaStreamConstraints {
        let wrap = unsafe { support::box_from_leak_ptr(self) };
        (*wrap).wire2api().into()
    }
}

impl Wire2Api<RtcConfiguration> for *mut wire_RtcConfiguration {
    fn wire2api(self) -> RtcConfiguration {
        let wrap = unsafe { support::box_from_leak_ptr(self) };
        (*wrap).wire2api().into()
    }
}

impl Wire2Api<RtcIceServer> for *mut wire_RtcIceServer {
    fn wire2api(self) -> RtcIceServer {
        let wrap = unsafe { support::box_from_leak_ptr(self) };
        (*wrap).wire2api().into()
    }
}

impl Wire2Api<VideoConstraints> for *mut wire_VideoConstraints {
    fn wire2api(self) -> VideoConstraints {
        let wrap = unsafe { support::box_from_leak_ptr(self) };
        (*wrap).wire2api().into()
    }
}

impl Wire2Api<i32> for i32 {
    fn wire2api(self) -> i32 {
        self
    }
}

impl Wire2Api<i64> for i64 {
    fn wire2api(self) -> i64 {
        self
    }
}

impl Wire2Api<Vec<RtcIceServer>> for *mut wire_list_rtc_ice_server {
    fn wire2api(self) -> Vec<RtcIceServer> {
        let vec = unsafe {
            let wrap = support::box_from_leak_ptr(self);
            support::vec_from_leak_ptr(wrap.ptr, wrap.len)
        };
        vec.into_iter().map(Wire2Api::wire2api).collect()
    }
}

impl Wire2Api<MediaStreamConstraints> for wire_MediaStreamConstraints {
    fn wire2api(self) -> MediaStreamConstraints {
        MediaStreamConstraints {
            audio: self.audio.wire2api(),
            video: self.video.wire2api(),
        }
    }
}

impl Wire2Api<MediaType> for i32 {
    fn wire2api(self) -> MediaType {
        match self {
            0 => MediaType::Audio,
            1 => MediaType::Video,
            _ => unreachable!("Invalid variant for MediaType: {}", self),
        }
    }
}

impl Wire2Api<RtcConfiguration> for wire_RtcConfiguration {
    fn wire2api(self) -> RtcConfiguration {
        RtcConfiguration {
            ice_transport_policy: self.ice_transport_policy.wire2api(),
            bundle_policy: self.bundle_policy.wire2api(),
            ice_servers: self.ice_servers.wire2api(),
        }
    }
}

impl Wire2Api<RtcIceServer> for wire_RtcIceServer {
    fn wire2api(self) -> RtcIceServer {
        RtcIceServer {
            urls: self.urls.wire2api(),
            username: self.username.wire2api(),
            credential: self.credential.wire2api(),
        }
    }
}

impl Wire2Api<RtpTransceiverDirection> for i32 {
    fn wire2api(self) -> RtpTransceiverDirection {
        match self {
            0 => RtpTransceiverDirection::SendRecv,
            1 => RtpTransceiverDirection::SendOnly,
            2 => RtpTransceiverDirection::RecvOnly,
            3 => RtpTransceiverDirection::Inactive,
            4 => RtpTransceiverDirection::Stopped,
            _ => unreachable!("Invalid variant for RtpTransceiverDirection: {}", self),
        }
    }
}

impl Wire2Api<u32> for u32 {
    fn wire2api(self) -> u32 {
        self
    }
}

impl Wire2Api<u64> for u64 {
    fn wire2api(self) -> u64 {
        self
    }
}

impl Wire2Api<u8> for u8 {
    fn wire2api(self) -> u8 {
        self
    }
}

impl Wire2Api<Vec<u8>> for *mut wire_uint_8_list {
    fn wire2api(self) -> Vec<u8> {
        unsafe {
            let wrap = support::box_from_leak_ptr(self);
            support::vec_from_leak_ptr(wrap.ptr, wrap.len)
        }
    }
}

impl Wire2Api<VideoConstraints> for wire_VideoConstraints {
    fn wire2api(self) -> VideoConstraints {
        VideoConstraints {
            device_id: self.device_id.wire2api(),
            width: self.width.wire2api(),
            height: self.height.wire2api(),
            frame_rate: self.frame_rate.wire2api(),
            is_display: self.is_display.wire2api(),
        }
    }
}

// Section: impl NewWithNullPtr

pub trait NewWithNullPtr {
    fn new_with_null_ptr() -> Self;
}

impl<T> NewWithNullPtr for *mut T {
    fn new_with_null_ptr() -> Self {
        std::ptr::null_mut()
    }
}

impl NewWithNullPtr for wire_AudioConstraints {
    fn new_with_null_ptr() -> Self {
        Self {
            device_id: core::ptr::null_mut(),
        }
    }
}

impl NewWithNullPtr for wire_MediaStreamConstraints {
    fn new_with_null_ptr() -> Self {
        Self {
            audio: core::ptr::null_mut(),
            video: core::ptr::null_mut(),
        }
    }
}

impl NewWithNullPtr for wire_RtcConfiguration {
    fn new_with_null_ptr() -> Self {
        Self {
            ice_transport_policy: core::ptr::null_mut(),
            bundle_policy: core::ptr::null_mut(),
            ice_servers: core::ptr::null_mut(),
        }
    }
}

impl NewWithNullPtr for wire_RtcIceServer {
    fn new_with_null_ptr() -> Self {
        Self {
            urls: core::ptr::null_mut(),
            username: core::ptr::null_mut(),
            credential: core::ptr::null_mut(),
        }
    }
}

impl NewWithNullPtr for wire_VideoConstraints {
    fn new_with_null_ptr() -> Self {
        Self {
            device_id: core::ptr::null_mut(),
            width: Default::default(),
            height: Default::default(),
            frame_rate: Default::default(),
            is_display: Default::default(),
        }
    }
}

// Section: impl IntoDart

impl support::IntoDart for MediaDeviceInfoFFI {
    fn into_dart(self) -> support::DartCObject {
        vec![
            self.device_id.into_dart(),
            self.kind.into_dart(),
            self.label.into_dart(),
        ]
        .into_dart()
    }
}
impl support::IntoDartExceptPrimitive for MediaDeviceInfoFFI {}

impl support::IntoDart for MediaDeviceKind {
    fn into_dart(self) -> support::DartCObject {
        match self {
            Self::AudioInput => 0,
            Self::AudioOutput => 1,
            Self::VideoInput => 2,
        }
        .into_dart()
    }
}

impl support::IntoDart for MediaStreamTrackFFI {
    fn into_dart(self) -> support::DartCObject {
        vec![
            self.id.into_dart(),
            self.label.into_dart(),
            self.kind.into_dart(),
            self.enabled.into_dart(),
        ]
        .into_dart()
    }
}
impl support::IntoDartExceptPrimitive for MediaStreamTrackFFI {}

impl support::IntoDart for MediaType {
    fn into_dart(self) -> support::DartCObject {
        match self {
            Self::Audio => 0,
            Self::Video => 1,
        }
        .into_dart()
    }
}

impl support::IntoDart for RtcRtpSender {
    fn into_dart(self) -> support::DartCObject {
        vec![self.id.into_dart()].into_dart()
    }
}
impl support::IntoDartExceptPrimitive for RtcRtpSender {}

impl support::IntoDart for RtcRtpTransceiver {
    fn into_dart(self) -> support::DartCObject {
        vec![
            self.id.into_dart(),
            self.mid.into_dart(),
            self.direction.into_dart(),
            self.sender.into_dart(),
        ]
        .into_dart()
    }
}
impl support::IntoDartExceptPrimitive for RtcRtpTransceiver {}

// Section: executor

support::lazy_static! {
    pub static ref FLUTTER_RUST_BRIDGE_HANDLER: support::DefaultHandler = Default::default();
}

// Section: sync execution mode utility

#[no_mangle]
pub extern "C" fn free_WireSyncReturnStruct(val: support::WireSyncReturnStruct) {
    unsafe {
        let _ = support::vec_from_leak_ptr(val.ptr, val.len);
    }
}
