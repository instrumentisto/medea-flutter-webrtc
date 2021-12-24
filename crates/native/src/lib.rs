// use std::{collections::HashMap, rc::Rc};

// use cxx::UniquePtr;
// use libwebrtc_sys::*;

// mod user_media;
// use user_media::*;

// mod device_info;
// use device_info::*;

/// The module which describes the bridge to call Rust from C++.
#[cxx::bridge]
pub mod ffi {
    //     /// Information about a physical device instance.
    //     struct DeviceInfo {
    //         deviceId: String,
    //         kind: String,
    //         label: String,
    //     }

    //     /// Media Stream constrants.
    //     struct Constraints {
    //         audio: bool,
    //         video: VideoConstraints,
    //     }

    //     /// Constraints for video capturer.
    //     struct VideoConstraints {
    //         min_width: String,
    //         min_height: String,
    //         min_fps: String,
    //     }

    //     /// Information about local [Media Stream].
    //     ///
    //     /// [Media Stream]: https://tinyurl.com/2k2376z9
    //     struct LocalStreamInfo {
    //         stream_id: String,
    //         video_tracks: Vec<TrackInfo>,
    //         audio_tracks: Vec<TrackInfo>,
    //     }

    //     /// Information about [Track].
    //     ///
    //     /// [Track]: https://tinyurl.com/yc79x5s8
    //     struct TrackInfo {
    //         id: String,
    //         label: String,
    //         kind: TrackKind,
    //         enabled: bool,
    //     }

    //     /// Kind of [Track].
    //     ///
    //     /// [Track]: https://tinyurl.com/yc79x5s8
    //     enum TrackKind {
    //         Audio,
    //         Video,
    //     }

    //     extern "Rust" {
    //         type Webrtc;

    //         fn enumerate_devices() -> Vec<DeviceInfo>;
    //         fn init() -> Box<Webrtc>;
    //         fn get_user_media(
    //             webrtc: &mut Box<Webrtc>,
    //             constraints: Constraints,
    //         ) -> LocalStreamInfo;
    //         fn dispose_stream(webrtc: &mut Box<Webrtc>, id: String);
    //     }
}

// /// Contains all necessary tools for interoperate with [libWebRTC].
// ///
// /// [libWebrtc]: https://tinyurl.com/54y935zz

// #[allow(dead_code)]
// pub struct Inner {
//     task_queue_factory: UniquePtr<webrtc::TaskQueueFactory>,
//     worker_thread: UniquePtr<webrtc::Thread>,
//     signaling_thread: UniquePtr<webrtc::Thread>,
//     peer_connection_factory:
// UniquePtr<webrtc::PeerConnectionFactoryInterface>,     video_sources:
// HashMap<VideoSouceId, Rc<VideoSource>>,     video_tracks:
// HashMap<VideoTrackId, VideoTrack>,     audio_sources:
//         HashMap<AudioSourceId, UniquePtr<webrtc::AudioSourceInterface>>,
//     audio_tracks: HashMap<AudioTrackId, AudioTrack>,
//     local_media_streams: HashMap<StreamId, MediaStream>,
// }

// /// Wraps the [Inner] instanse.
// /// This struct is intended to be extern and managed outside of the Rust app.
// ///
// /// [Inner](Inner)
// pub struct Webrtc(Box<Inner>);
