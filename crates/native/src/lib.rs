#![warn(clippy::pedantic)]
mod api;
#[rustfmt::skip]
mod bridge_generated;
mod cpp_api;
mod devices;
mod pc;
mod user_media;
mod video_sink;

use std::{
    collections::HashMap,
    sync::{
        atomic::{AtomicU64, Ordering},
        Arc,
    },
};

use dashmap::DashMap;
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
    video_sources: HashMap<VideoDeviceId, Arc<VideoSource>>,
    video_tracks: Arc<DashMap<VideoTrackId, VideoTrack>>,
    audio_source: Option<Arc<AudioSourceInterface>>,
    audio_tracks: Arc<DashMap<AudioTrackId, AudioTrack>>,
    video_sinks: HashMap<VideoSinkId, VideoSink>,

    /// `peer_connection_factory` must be drops before [`Thread`]s.
    peer_connection_factory: PeerConnectionFactoryInterface,
    task_queue_factory: TaskQueueFactory,
    audio_device_module: AudioDeviceModule,
    worker_thread: Thread,
    // TODO(alexlapa): recheck whether do we really need to create network
    //                 thread manually
    network_thread: Thread,
    signaling_thread: Thread,

    /// [`ThreadPool`] used to offload blocking or CPU-intensive tasks, so they
    /// won't block Flutter WebRTC threads.
    callback_pool: ThreadPool,
}

impl Webrtc {
    fn new() -> anyhow::Result<Self> {
        let mut task_queue_factory = TaskQueueFactory::create_default_task_queue_factory();

        let mut wt = Thread::create(false).unwrap();
        wt.start().unwrap();
        let mut st = Thread::create(false).unwrap();
        st.start().unwrap();
        let mut nt = Thread::create(true).unwrap();
        nt.start().unwrap();

        let audio_device_module = AudioDeviceModule::new(
            &mut wt,
            &mut st,
            AudioLayer::kPlatformDefaultAudio,
            &mut task_queue_factory,
        )
        .unwrap();

        let pcf = PeerConnectionFactoryInterface::create(
            Some(&nt),
            Some(&wt),
            Some(&st),
            Some(&audio_device_module.inner),
        );

        // let create_result = audio_device_module
        //     .create_peer_connection_factory()
        //     .unwrap();
        let video_device_info = VideoDeviceInfo::create().unwrap();
        Ok(Webrtc {
            task_queue_factory,
            network_thread: nt,
            worker_thread: wt,
            signaling_thread: st,
            audio_device_module,
            video_device_info,
            peer_connection_factory: pcf.unwrap(),
            video_sources: HashMap::new(),
            video_tracks: Arc::new(DashMap::new()),
            audio_source: None,
            audio_tracks: Arc::new(DashMap::new()),
            peer_connections: HashMap::new(),
            video_sinks: HashMap::new(),
            callback_pool: ThreadPool::new(4),
        })
    }
}
