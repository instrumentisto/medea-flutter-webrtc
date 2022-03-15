#![warn(clippy::pedantic)]
mod bridge_generated; /* AUTO INJECTED BY flutter_rust_bridge. This line may not be accurate, and you can change it according to your needs. */
mod devices;
mod internal;
mod dart_api;
mod pc;
mod user_media;
mod video_sink;

use std::{
    collections::HashMap,
    rc::Rc,
    sync::{
        atomic::{AtomicU64, Ordering},
        Arc,
    },
};

use cxx::UniquePtr;
use dashmap::DashMap;
use flutter_rust_bridge::StreamSink;
use libwebrtc_sys::{
    AudioLayer, AudioSourceInterface, PeerConnectionFactoryInterface, TaskQueueFactory,
    Thread, VideoDeviceInfo,
};
use threadpool::ThreadPool;

use crate::video_sink::Id as VideoSinkId;

#[doc(inline)]
pub use crate::{
    pc::{PeerConnection, PeerConnectionId},
    user_media::{
        AudioDeviceId, AudioDeviceModule, AudioTrack, AudioTrackId, MediaStreamId,
        VideoDeviceId, VideoSource, VideoTrack, VideoTrackId,
    },
    video_sink::{Frame, VideoSink},
};

/// Counter used to generate unique IDs.
static ID_COUNTER: AtomicU64 = AtomicU64::new(1);

/// Returns a next unique ID.
pub(crate) fn next_id() -> u64 {
    ID_COUNTER.fetch_add(1, Ordering::Relaxed)
}

struct Webrtc {
    peer_connections: HashMap<PeerConnectionId, PeerConnection>,
    video_device_info: VideoDeviceInfo,
    video_sources: HashMap<VideoDeviceId, Rc<VideoSource>>,
    video_tracks: Arc<DashMap<VideoTrackId, VideoTrack>>,
    audio_source: Option<Rc<AudioSourceInterface>>,
    audio_tracks: Arc<DashMap<AudioTrackId, AudioTrack>>,
    video_sinks: HashMap<VideoSinkId, VideoSink>,

    /// `peer_connection_factory` must be drops before [`Thread`]s.
    peer_connection_factory: PeerConnectionFactoryInterface,
    task_queue_factory: TaskQueueFactory,
    audio_device_module: AudioDeviceModule,
    worker_thread: Thread,
    network_thread: Thread,
    signaling_thread: Thread,

    /// [`ThreadPool`] used to offload blocking or CPU-intensive tasks, so they
    /// won't block Flutter WebRTC threads.
    callback_pool: ThreadPool,
}
