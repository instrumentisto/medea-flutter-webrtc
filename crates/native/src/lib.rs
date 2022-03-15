#![warn(clippy::pedantic)]
mod api;
mod bridge_generated;
mod cpp_api;
mod devices;
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

/// [`Context`] wrapper that is exposed to the C++ API clients.
pub struct Webrtc(Box<Context>);

unsafe impl Sync for Webrtc {}

/// Application context that manages all dependencies.
#[allow(dead_code)]
pub struct Context {
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

/// Creates a new instance of [`Webrtc`].
///
/// # Panics
///
/// Panics on any error returned from the `libWebRTC`.
#[must_use]
pub fn init() -> Box<Webrtc> {
    // TODO: Dont panic but propagate errors to API users.
    let mut task_queue_factory = TaskQueueFactory::create_default_task_queue_factory();

    let mut network_thread = Thread::create(true).unwrap();
    network_thread.start().unwrap();

    let mut worker_thread = Thread::create(false).unwrap();
    worker_thread.start().unwrap();

    let mut signaling_thread = Thread::create(false).unwrap();
    signaling_thread.start().unwrap();

    let audio_device_module =
        AudioDeviceModule::new(AudioLayer::kPlatformDefaultAudio, &mut task_queue_factory)
            .unwrap();

    let peer_connection_factory = PeerConnectionFactoryInterface::create(
        Some(&network_thread),
        Some(&worker_thread),
        Some(&signaling_thread),
        Some(&audio_device_module.inner),
    )
    .unwrap();

    let video_device_info = VideoDeviceInfo::create().unwrap();

    Box::new(Webrtc(Box::new(Context {
        task_queue_factory,
        network_thread,
        worker_thread,
        signaling_thread,
        audio_device_module,
        video_device_info,
        peer_connection_factory,
        video_sources: HashMap::new(),
        video_tracks: Arc::new(DashMap::new()),
        audio_source: None,
        audio_tracks: Arc::new(DashMap::new()),
        peer_connections: HashMap::new(),
        video_sinks: HashMap::new(),
        callback_pool: ThreadPool::new(4),
    })))
}

impl Drop for Webrtc {
    fn drop(&mut self) {
        todo!();
        // self.set_on_device_changed(UniquePtr::null());
    }
}
