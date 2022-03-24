use std::{
    ops::DerefMut,
    sync::{mpsc, Arc, Mutex},
    thread::JoinHandle,
};

use anyhow::bail;
use dashmap::mapref::one::RefMut;
use derive_more::{AsRef, Display, From};
use flutter_rust_bridge::StreamSink;
use libwebrtc_sys as sys;
use sys::TrackEventObserver;

use crate::{
    api, api::TrackEvent, next_id, PeerConnectionId, VideoSink, VideoSinkId, Webrtc,
};

impl Webrtc {
    /// Creates a new local [`MediaStream`] with [`VideoTrack`]s and/or
    /// [`AudioTrack`]s according to the provided accepted
    /// [`api::MediaStreamConstraints`].
    #[allow(clippy::too_many_lines, clippy::missing_panics_doc)]
    pub fn get_media(
        &mut self,
        constraints: api::MediaStreamConstraints,
    ) -> anyhow::Result<Vec<api::MediaStreamTrack>> {
        let mut result = Vec::new();

        if let Some(video) = constraints.video {
            let source = self.get_or_create_video_source(&video)?;
            let track = self.create_video_track(source)?;
            result.push(api::MediaStreamTrack::from(&*track));
        }

        if let Some(audio) = constraints.audio {
            let source = self.get_or_create_audio_source(&audio)?;
            let track = self.create_audio_track(source)?;
            result.push(api::MediaStreamTrack::from(&*track));
        }

        Ok(result)
    }

    /// Disposes the [`MediaStream`] and all the contained tracks in it.
    pub fn dispose_track(&mut self, track_id: u64) {
        if let Some((_, track)) = self.video_tracks.remove(&VideoTrackId::from(track_id)) {
            if let MediaTrackSource::Local(src) = track.source {
                if Arc::strong_count(&src) == 2 {
                    self.video_sources.remove(&src.device_id);
                };
            }
        } else if let Some((_, track)) =
            self.audio_tracks.remove(&AudioTrackId::from(track_id))
        {
            if let MediaTrackSource::Local(src) = track.source {
                if Arc::strong_count(&src) == 2 {
                    self.audio_source.take();
                    // TODO: We should make `AudioDeviceModule` to stop
                    //       recording.
                };
            }
        }
    }

    /// Creates a new [`VideoTrack`] from the given [`VideoSource`].
    fn create_video_track(
        &mut self,
        source: Arc<VideoSource>,
    ) -> anyhow::Result<RefMut<'_, VideoTrackId, VideoTrack>> {
        let track = if source.is_display {
            // TODO: Support screens enumeration.
            VideoTrack::create_local(
                &self.peer_connection_factory,
                source,
                VideoLabel::from("screen:0"),
            )?
        } else {
            let device_index =
                if let Some(index) = self.get_index_of_video_device(&source.device_id)? {
                    index
                } else {
                    bail!(
                        "Could not find video device with the specified ID `{}`",
                        &source.device_id,
                    );
                };

            VideoTrack::create_local(
                &self.peer_connection_factory,
                source,
                VideoLabel(self.video_device_info.device_name(device_index)?.0),
            )?
        };

        let track = self.video_tracks.entry(track.id).or_insert(track);

        Ok(track)
    }

    /// Creates a new [`VideoSource`] based on the given [`VideoConstraints`].
    fn get_or_create_video_source(
        &mut self,
        caps: &api::VideoConstraints,
    ) -> anyhow::Result<Arc<VideoSource>> {
        let (index, device_id) = if caps.is_display {
            // TODO: Support screens enumeration.
            (0, VideoDeviceId("screen:0".into()))
        } else if caps.device_id.is_empty() {
            // No device ID is provided so just pick the first available
            // device
            if self.video_device_info.number_of_devices() < 1 {
                bail!("Could not find any available video input device");
            }

            let device_id = VideoDeviceId(self.video_device_info.device_name(0)?.1);
            (0, device_id)
        } else {
            let device_id = VideoDeviceId(caps.device_id.clone());
            if let Some(index) = self.get_index_of_video_device(&device_id)? {
                (index, device_id)
            } else {
                bail!(
                    "Could not find video device with the specified ID `{}`",
                    device_id,
                );
            }
        };

        if let Some(src) = self.video_sources.get(&device_id) {
            return Ok(Arc::clone(src));
        }

        let source = if caps.is_display {
            VideoSource::new_display_source(
                &mut self.worker_thread,
                &mut self.signaling_thread,
                caps,
                device_id,
            )?
        } else {
            VideoSource::new_device_source(
                &mut self.worker_thread,
                &mut self.signaling_thread,
                caps,
                index,
                device_id,
            )?
        };
        let source = self
            .video_sources
            .entry(source.device_id.clone())
            .or_insert_with(|| Arc::new(source));

        Ok(Arc::clone(source))
    }

    /// Creates a new [`AudioTrack`] from the given
    /// [`sys::AudioSourceInterface`].
    fn create_audio_track(
        &mut self,
        source: Arc<sys::AudioSourceInterface>,
    ) -> anyhow::Result<RefMut<'_, AudioTrackId, AudioTrack>> {
        // PANIC: If there is a `sys::AudioSourceInterface` then we are sure
        //        that `current_device_id` is set in the `AudioDeviceModule`.
        let device_id = self.audio_device_module.current_device_id.clone().unwrap();
        let device_index =
            if let Some(index) = self.get_index_of_audio_recording_device(&device_id)? {
                index
            } else {
                bail!(
                    "Could not find video device with the specified ID `{}`",
                    device_id,
                );
            };

        let track = AudioTrack::new(
            &self.peer_connection_factory,
            source,
            AudioLabel(
                #[allow(clippy::cast_possible_wrap)]
                self.audio_device_module
                    .recording_device_name(device_index as i16)?
                    .0,
            ),
        )?;

        let track = self.audio_tracks.entry(track.id).or_insert(track);

        Ok(track)
    }

    /// Creates a new [`sys::AudioSourceInterface`] based on the given
    /// [`AudioConstraints`].
    fn get_or_create_audio_source(
        &mut self,
        caps: &api::AudioConstraints,
    ) -> anyhow::Result<Arc<sys::AudioSourceInterface>> {
        let device_id = if caps.device_id.is_empty() {
            // No device ID is provided so just pick the currently used.
            if self.audio_device_module.current_device_id.is_none() {
                // `AudioDeviceModule` is not capturing anything at the moment,
                // so we will use first available device (with `0` index).
                if self.audio_device_module.recording_devices()? < 1 {
                    bail!("Could not find any available audio input device");
                }

                AudioDeviceId(self.audio_device_module.recording_device_name(0)?.1)
            } else {
                // PANIC: If there is a `sys::AudioSourceInterface` then we are
                //        sure that `current_device_id` is set in the
                //        `AudioDeviceModule`.
                self.audio_device_module.current_device_id.clone().unwrap()
            }
        } else {
            AudioDeviceId(caps.device_id.clone())
        };

        let device_index =
            if let Some(index) = self.get_index_of_audio_recording_device(&device_id)? {
                index
            } else {
                bail!(
                    "Could not find audio device with the specified ID `{}`",
                    device_id,
                );
            };

        if Some(&device_id) != self.audio_device_module.current_device_id.as_ref() {
            self.audio_device_module
                .set_recording_device(device_id, device_index)?;
        }

        let src = if let Some(src) = self.audio_source.as_ref() {
            Arc::clone(src)
        } else {
            let src = Arc::new(self.peer_connection_factory.create_audio_source()?);
            self.audio_source.replace(Arc::clone(&src));

            src
        };

        Ok(src)
    }

    /// Changes the [enabled][1] property of the media track by its ID.
    ///
    /// # Panics
    ///
    /// If cannot find any track with the provided ID.
    ///
    /// [1]: https://w3.org/TR/mediacapture-streams#track-enabled
    pub fn set_track_enabled(&self, id: u64, enabled: bool) -> anyhow::Result<()> {
        if let Some(track) = self.video_tracks.get(&VideoTrackId(id)) {
            track.inner.set_enabled(enabled);
        } else if let Some(track) = self.audio_tracks.get(&AudioTrackId(id)) {
            track.set_enabled(enabled);
        } else {
            bail!("Could not find track with `{id}` ID");
        }

        Ok(())
    }

    pub fn clone_track(&mut self, id: u64) -> anyhow::Result<api::MediaStreamTrack> {
        if self.video_tracks.contains_key(&VideoTrackId(id)) {
            let source = match &self.video_tracks.get(&VideoTrackId(id)).unwrap().source {
                MediaTrackSource::Local(source) => {
                    MediaTrackSource::Local(Arc::clone(&source))
                }
                MediaTrackSource::Remote { mid, peer_id } => MediaTrackSource::Remote {
                    mid: mid.to_string(),
                    peer_id: *peer_id,
                },
            };

            match source {
                MediaTrackSource::Local(source) => Ok(api::MediaStreamTrack::from(
                    self.create_video_track(source).unwrap().value(),
                )),
                MediaTrackSource::Remote { mid, peer_id } => {
                    let peer = self
                        .peer_connections
                        .get(&PeerConnectionId(peer_id))
                        .unwrap();

                    let mut transceivers = peer.0.lock().unwrap().get_transceivers();

                    transceivers.retain(|transceiver| transceiver.mid().unwrap() == mid);

                    if transceivers.len() > 0 {
                        let track =
                            VideoTrack::wrap_remote(transceivers.get(0).unwrap(), id);

                        Ok(api::MediaStreamTrack::from(&track))
                    } else {
                        bail!("No `transceiver` has been found with this `mid: {mid}`.");
                    }
                }
            }
        } else if self.audio_tracks.contains_key(&AudioTrackId(id)) {
            let source = match &self.audio_tracks.get(&AudioTrackId(id)).unwrap().source {
                MediaTrackSource::Local(source) => {
                    MediaTrackSource::Local(Arc::clone(&source))
                }
                MediaTrackSource::Remote { mid, peer_id } => MediaTrackSource::Remote {
                    mid: mid.to_string(),
                    peer_id: *peer_id,
                },
            };

            match source {
                MediaTrackSource::Local(source) => Ok(api::MediaStreamTrack::from(
                    self.create_audio_track(source).unwrap().value(),
                )),
                MediaTrackSource::Remote { mid, peer_id } => {
                    let peer = self
                        .peer_connections
                        .get(&PeerConnectionId(peer_id))
                        .unwrap();

                    let mut transceivers = peer.0.lock().unwrap().get_transceivers();

                    transceivers.retain(|transceiver| transceiver.mid().unwrap() == mid);

                    if transceivers.len() > 0 {
                        let track =
                            VideoTrack::wrap_remote(transceivers.get(0).unwrap(), id);

                        Ok(api::MediaStreamTrack::from(&track))
                    } else {
                        bail!("No `transceiver` has been found with this `mid: {mid}`.");
                    }
                }
            }
        } else {
            bail!("There is no `track` with this `id: {id}`.")
        }
    }

    /// Registers an events observer for an [`AudioTrack`] or a [`VideoTrack`].
    ///
    /// # Warning
    ///
    /// Returns error message if cannot find any [`AudioTrack`] or
    /// [`VideoTrack`] by the specified `id`.
    pub fn register_track_observer(
        &self,
        track_id: u64,
        cb: StreamSink<TrackEvent>,
    ) -> anyhow::Result<()> {
        let mut obs = TrackEventObserver::new(Box::new(TrackEventHandler(cb)));
        if let Some(mut track) = self.video_tracks.get_mut(&VideoTrackId::from(track_id)) {
            obs.set_video_track(&track.inner);
            track.inner.register_observer(obs);
        } else if let Some(mut track) =
            self.audio_tracks.get_mut(&AudioTrackId::from(track_id))
        {
            obs.set_audio_track(&track.inner);
            track.inner.register_observer(obs);
        } else {
            bail!("Could not find track with `{track_id}` ID")
        }

        Ok(())
    }
}

/// ID of a [`MediaStream`].
#[derive(Clone, Copy, Debug, Display, Eq, From, Hash, PartialEq)]
pub struct MediaStreamId(u64);

/// ID of an video input device that provides data to some [`VideoSource`].
#[derive(AsRef, Clone, Debug, Display, Eq, Hash, PartialEq)]
#[as_ref(forward)]
pub struct VideoDeviceId(String);

/// ID of an `AudioDevice`.
#[derive(AsRef, Clone, Debug, Default, Display, Eq, Hash, PartialEq, From)]
#[as_ref(forward)]
pub struct AudioDeviceId(String);

/// ID of a [`VideoTrack`].
#[derive(Clone, Copy, Debug, Display, From, Eq, Hash, PartialEq)]
pub struct VideoTrackId(u64);

/// ID of an [`AudioTrack`].
#[derive(Clone, Copy, Debug, Display, From, Eq, Hash, PartialEq)]
pub struct AudioTrackId(u64);

/// Label identifying a video track source.
#[derive(AsRef, Clone, Debug, Default, Display, Eq, From, Hash, PartialEq)]
#[as_ref(forward)]
#[from(forward)]
pub struct VideoLabel(String);

/// Label identifying an audio track source.
#[derive(AsRef, Clone, Debug, Default, Display, Eq, From, Hash, PartialEq)]
#[as_ref(forward)]
#[from(forward)]
pub struct AudioLabel(String);

enum Message {
    SetRecordingDevice {
        index: u16,
        tx: mpsc::Sender<anyhow::Result<()>>,
    },
    SetPlayoutDevice {
        index: u16,
        tx: mpsc::Sender<anyhow::Result<()>>,
    },
    PlayoutDevices(mpsc::Sender<anyhow::Result<i16>>),
    RecordingDevices(mpsc::Sender<anyhow::Result<i16>>),
    RecordingDeviceName {
        index: i16,
        tx: mpsc::Sender<anyhow::Result<(String, String)>>,
    },
    PlayoutDeviceName {
        index: i16,
        tx: mpsc::Sender<anyhow::Result<(String, String)>>,
    },
    CreatePeerConnectionFactory(
        mpsc::Sender<anyhow::Result<CreatePeerConnectionFactoryResult>>,
    ),
}

impl Message {
    fn set_recording_device(index: u16) -> (Self, mpsc::Receiver<anyhow::Result<()>>) {
        let (tx, rx) = mpsc::channel();

        (Message::SetRecordingDevice { index, tx }, rx)
    }
    fn set_playout_device(index: u16) -> (Self, mpsc::Receiver<anyhow::Result<()>>) {
        let (tx, rx) = mpsc::channel();

        (Message::SetPlayoutDevice { index, tx }, rx)
    }
    pub fn playout_devices() -> (Self, mpsc::Receiver<anyhow::Result<i16>>) {
        let (tx, rx) = mpsc::channel();

        (Message::PlayoutDevices(tx), rx)
    }

    pub fn recording_devices() -> (Self, mpsc::Receiver<anyhow::Result<i16>>) {
        let (tx, rx) = mpsc::channel();

        (Message::RecordingDevices(tx), rx)
    }

    pub fn recording_device_name(
        index: i16,
    ) -> (Self, mpsc::Receiver<anyhow::Result<(String, String)>>) {
        let (tx, rx) = mpsc::channel();

        (Message::RecordingDeviceName { index, tx }, rx)
    }

    pub fn playout_device_name(
        index: i16,
    ) -> (Self, mpsc::Receiver<anyhow::Result<(String, String)>>) {
        let (tx, rx) = mpsc::channel();

        (Message::PlayoutDeviceName { index, tx }, rx)
    }

    pub fn create_peer_connection_factory() -> (
        Self,
        mpsc::Receiver<anyhow::Result<CreatePeerConnectionFactoryResult>>,
    ) {
        let (tx, rx) = mpsc::channel();

        (Message::CreatePeerConnectionFactory(tx), rx)
    }
}

/// [`sys::AudioDeviceModule`] wrapper tracking the currently used audio input
/// device.
pub struct AudioDeviceModule {
    /// ID of the audio input device currently used by this
    /// [`sys::AudioDeviceModule`].
    ///
    /// [`None`] if the [`AudioDeviceModule`] was not used yet to record data
    /// from the audio input device.
    current_device_id: Option<AudioDeviceId>,

    current_playout_device_id: Option<AudioDeviceId>,

    thread: Option<JoinHandle<()>>,

    tx: Option<mpsc::Sender<Message>>,
}

impl AudioDeviceModule {
    /// Creates a new [`AudioDeviceModule`] according to the passed
    /// [`sys::AudioLayer`].
    ///
    /// # Errors
    ///
    /// If could not find any available recording device.
    pub fn new(
        audio_layer: sys::AudioLayer,
        task_queue_factory: Arc<Mutex<sys::TaskQueueFactory>>,
    ) -> anyhow::Result<Self> {
        let (tx, rx) = mpsc::channel();
        let thread = std::thread::spawn(move || {
            let inner = sys::AudioDeviceModule::create(
                audio_layer,
                task_queue_factory.lock().unwrap().deref_mut(),
            )
            .unwrap();
            inner.init().unwrap();

            while let Ok(msg) = rx.recv() {
                match msg {
                    Message::SetRecordingDevice { index, tx } => {
                        tx.send(inner.set_recording_device(index)).unwrap();
                    }
                    Message::SetPlayoutDevice { index, tx } => {
                        tx.send(inner.set_playout_device(index)).unwrap();
                    }
                    Message::PlayoutDevices(tx) => {
                        tx.send(inner.playout_devices()).unwrap();
                    }
                    Message::RecordingDevices(tx) => {
                        tx.send(inner.recording_devices()).unwrap();
                    }
                    Message::RecordingDeviceName { index, tx } => {
                        tx.send(inner.recording_device_name(index)).unwrap();
                    }
                    Message::PlayoutDeviceName { index, tx } => {
                        tx.send(inner.playout_device_name(index)).unwrap();
                    }
                    Message::CreatePeerConnectionFactory(tx) => {
                        let create = || {
                            let mut network_thread = sys::Thread::create(true)?;
                            network_thread.start()?;

                            let mut worker_thread = sys::Thread::create(false)?;
                            worker_thread.start()?;

                            let mut signaling_thread = sys::Thread::create(false)?;
                            signaling_thread.start()?;

                            let peer_connection_factory =
                                sys::PeerConnectionFactoryInterface::create(
                                    Some(&network_thread),
                                    Some(&worker_thread),
                                    Some(&signaling_thread),
                                    Some(&inner),
                                )?;

                            Ok(CreatePeerConnectionFactoryResult {
                                worker_thread,
                                network_thread,
                                signaling_thread,
                                peer_connection_factory,
                            })
                        };
                        tx.send(create()).unwrap();
                    }
                }
            }
        });

        Ok(Self {
            current_device_id: None,
            current_playout_device_id: None,
            thread: Some(thread),
            tx: Some(tx),
        })
    }

    /// Changes the recording device for this [`AudioDeviceModule`].
    ///
    /// # Errors
    ///
    /// If [`sys::AudioDeviceModule::set_recording_device()`] fails.
    pub fn set_recording_device(
        &mut self,
        id: AudioDeviceId,
        index: u16,
    ) -> anyhow::Result<()> {
        let (msg, rx) = Message::set_recording_device(index);
        self.tx.as_ref().unwrap().send(msg).unwrap();
        let result = rx.recv()?;
        if result.is_ok() {
            self.current_device_id.replace(id);
        }

        result
    }

    pub fn set_playout_device(
        &mut self,
        id: AudioDeviceId,
        index: u16,
    ) -> anyhow::Result<()> {
        let (msg, rx) = Message::set_playout_device(index);
        self.tx.as_ref().unwrap().send(msg).unwrap();
        let result = rx.recv()?;
        if result.is_ok() {
            self.current_playout_device_id.replace(id);
        }

        result
    }

    /// Returns count of available audio playout devices.
    pub fn playout_devices(&self) -> anyhow::Result<i16> {
        let (msg, rx) = Message::playout_devices();
        self.tx.as_ref().unwrap().send(msg).unwrap();

        rx.recv()?
    }

    /// Returns count of available audio recording devices.
    pub fn recording_devices(&self) -> anyhow::Result<i16> {
        let (msg, rx) = Message::recording_devices();
        self.tx.as_ref().unwrap().send(msg).unwrap();

        rx.recv()?
    }

    /// Returns the `(label, id)` tuple for the given audio playout device
    /// `index`.
    pub fn playout_device_name(&self, index: i16) -> anyhow::Result<(String, String)> {
        let (msg, rx) = Message::playout_device_name(index);
        self.tx.as_ref().unwrap().send(msg).unwrap();

        rx.recv()?
    }

    /// Returns the `(label, id)` tuple for the given audio recording device
    /// `index`.
    pub fn recording_device_name(&self, index: i16) -> anyhow::Result<(String, String)> {
        let (msg, rx) = Message::recording_device_name(index);
        self.tx.as_ref().unwrap().send(msg).unwrap();

        rx.recv()?
    }

    pub fn create_peer_connection_factory(
        &self,
    ) -> anyhow::Result<CreatePeerConnectionFactoryResult> {
        let (msg, rx) = Message::create_peer_connection_factory();
        self.tx.as_ref().unwrap().send(msg).unwrap();

        rx.recv()?
    }
}

pub struct CreatePeerConnectionFactoryResult {
    pub worker_thread: sys::Thread,
    pub network_thread: sys::Thread,
    pub signaling_thread: sys::Thread,
    pub peer_connection_factory: sys::PeerConnectionFactoryInterface,
}

impl Drop for AudioDeviceModule {
    fn drop(&mut self) {
        self.tx.take();
        self.thread.take().unwrap().join().unwrap();
    }
}

/// Possible kinds of media track's source.
enum MediaTrackSource<T> {
    Local(Arc<T>),
    Remote { mid: String, peer_id: u64 },
}

/// Representation of a [`sys::VideoTrackInterface`].
#[derive(AsRef)]
pub struct VideoTrack {
    /// ID of this [`VideoTrack`].
    id: VideoTrackId,

    /// Underlying [`sys::VideoTrackInterface`].
    #[as_ref]
    inner: sys::VideoTrackInterface,

    /// [`VideoSource`] that is used by this [`VideoTrack`].
    source: MediaTrackSource<VideoSource>,

    /// [`api::TrackKind::kVideo`].
    kind: api::MediaType,

    /// [`VideoLabel`] identifying the track source, as in "HD Webcam Analog
    /// Stereo".
    label: VideoLabel,

    /// List of the [`VideoSink`]s attached to this [`VideoTrack`].
    sinks: Vec<VideoSinkId>,
}

impl VideoTrack {
    /// Creates a new [`VideoTrack`].
    fn create_local(
        pc: &sys::PeerConnectionFactoryInterface,
        src: Arc<VideoSource>,
        label: VideoLabel,
    ) -> anyhow::Result<Self> {
        let id = VideoTrackId(next_id());
        Ok(Self {
            id,
            inner: pc.create_video_track(id.to_string(), &src.inner)?,
            source: MediaTrackSource::Local(src),
            kind: api::MediaType::Video,
            label,
            sinks: Vec::new(),
        })
    }

    /// Wraps the track of the `transceiver.receiver.track()` into a
    /// [`VideoTrack`].
    pub(crate) fn wrap_remote(
        transceiver: &sys::RtpTransceiverInterface,
        peer_id: u64,
    ) -> Self {
        let receiver = transceiver.receiver();
        let track = receiver.track();
        Self {
            id: VideoTrackId(next_id()),
            inner: track.try_into().unwrap(),
            // Safe to unwrap since transceiver is guaranteed to be negotiated
            // at this point.
            source: MediaTrackSource::Remote {
                mid: transceiver.mid().unwrap(),
                peer_id,
            },
            kind: api::MediaType::Audio,
            label: VideoLabel::from("remote"),
            sinks: Vec::new(),
        }
    }

    /// Returns the [`VideoTrackId`] of this [`VideoTrack`].
    #[must_use]
    pub fn id(&self) -> VideoTrackId {
        self.id
    }

    /// Adds the provided [`VideoSink`] to this [`VideoTrack`].
    pub fn add_video_sink(&mut self, video_sink: &mut VideoSink) {
        self.inner.add_or_update_sink(video_sink.as_mut());
        self.sinks.push(video_sink.id());
    }

    /// Detaches the provided [`VideoSink`] from this [`VideoTrack`].
    pub fn remove_video_sink(&mut self, mut video_sink: VideoSink) {
        self.sinks.retain(|&sink| sink != video_sink.id());
        self.inner.remove_sink(video_sink.as_mut());
    }

    /// Changes the [enabled][1] property of the underlying
    /// [`sys::VideoTrackInterface`].
    ///
    /// [1]: https://w3.org/TR/mediacapture-streams#track-enabled
    pub fn set_enabled(&self, enabled: bool) {
        self.inner.set_enabled(enabled);
    }
}

impl From<&VideoTrack> for api::MediaStreamTrack {
    fn from(track: &VideoTrack) -> Self {
        Self {
            id: track.id.0,
            device_id: track.label.0.clone(),
            kind: track.kind,
            enabled: true,
        }
    }
}

/// Representation of a [`sys::AudioSourceInterface`].
#[derive(AsRef)]
pub struct AudioTrack {
    /// ID of this [`AudioTrack`].
    id: AudioTrackId,

    /// Underlying [`sys::AudioTrackInterface`].
    #[as_ref]
    inner: sys::AudioTrackInterface,

    /// [`sys::AudioSourceInterface`] that is used by this [`AudioTrack`].
    source: MediaTrackSource<sys::AudioSourceInterface>,

    /// [`api::TrackKind::kAudio`].
    kind: api::MediaType,

    /// [`AudioLabel`] identifying the track source, as in "internal
    /// microphone".
    label: AudioLabel,
}

impl AudioTrack {
    /// Creates a new [`AudioTrack`].
    ///
    /// # Errors
    ///
    /// Whenever [`sys::PeerConnectionFactoryInterface::create_audio_track()`]
    /// returns an error.
    pub fn new(
        pc: &sys::PeerConnectionFactoryInterface,
        src: Arc<sys::AudioSourceInterface>,
        label: AudioLabel,
    ) -> anyhow::Result<Self> {
        let id = AudioTrackId(next_id());
        Ok(Self {
            id,
            inner: pc.create_audio_track(id.to_string(), &src)?,
            source: MediaTrackSource::Local(src),
            kind: api::MediaType::Audio,
            label,
        })
    }

    /// Wraps the track of the `transceiver.receiver.track()` into an
    /// [`AudioTrack`].
    pub(crate) fn wrap_remote(
        transceiver: &sys::RtpTransceiverInterface,
        peer_id: u64,
    ) -> Self {
        let receiver = transceiver.receiver();
        let track = receiver.track();
        Self {
            id: AudioTrackId(next_id()),
            inner: track.try_into().unwrap(),
            // Safe to unwrap since transceiver is guaranteed to be negotiated
            // at this point.
            source: MediaTrackSource::Remote {
                mid: transceiver.mid().unwrap(),
                peer_id,
            },
            kind: api::MediaType::Audio,
            label: AudioLabel::from("remote"),
        }
    }

    /// Returns the [`AudioTrackId`] of this [`AudioTrack`].
    #[must_use]
    pub fn id(&self) -> AudioTrackId {
        self.id
    }

    /// Changes the [enabled][1] property of the underlying
    /// [`sys::AudioTrackInterface`].
    ///
    /// [1]: https://w3.org/TR/mediacapture-streams#track-enabled
    pub fn set_enabled(&self, enabled: bool) {
        self.inner.set_enabled(enabled);
    }
}

impl From<&AudioTrack> for api::MediaStreamTrack {
    fn from(track: &AudioTrack) -> Self {
        Self {
            id: track.id.0,
            device_id: track.label.0.clone(),
            kind: track.kind,
            enabled: true,
        }
    }
}

/// [`sys::VideoTrackSourceInterface`] wrapper.
pub struct VideoSource {
    /// Underlying [`sys::VideoTrackSourceInterface`].
    inner: sys::VideoTrackSourceInterface,

    /// ID of an video input device that provides data to this [`VideoSource`].
    device_id: VideoDeviceId,

    /// Indicates whether this [`VideoSource`] is backed by screen capturing.
    is_display: bool,
}

impl VideoSource {
    /// Creates a new [`VideoTrackSourceInterface`] from the video input device
    /// with the specified constraints.
    fn new_device_source(
        worker_thread: &mut sys::Thread,
        signaling_thread: &mut sys::Thread,
        caps: &api::VideoConstraints,
        device_index: u32,
        device_id: VideoDeviceId,
    ) -> anyhow::Result<Self> {
        Ok(Self {
            inner: sys::VideoTrackSourceInterface::create_proxy_from_device(
                worker_thread,
                signaling_thread,
                caps.width as usize,
                caps.height as usize,
                caps.frame_rate as usize,
                device_index,
            )?,
            device_id,
            is_display: false,
        })
    }

    /// Starts screen capturing and creates a new [`VideoTrackSourceInterface`]
    /// with the specified constraints.
    fn new_display_source(
        worker_thread: &mut sys::Thread,
        signaling_thread: &mut sys::Thread,
        caps: &api::VideoConstraints,
        device_id: VideoDeviceId,
    ) -> anyhow::Result<Self> {
        Ok(Self {
            inner: sys::VideoTrackSourceInterface::create_proxy_from_display(
                worker_thread,
                signaling_thread,
                caps.width as usize,
                caps.height as usize,
                caps.frame_rate as usize,
            )?,
            device_id,
            is_display: true,
        })
    }
}

/// Wrapper around [`TrackObserverInterface`] implementing
/// [`sys::TrackEventCallback`].
struct TrackEventHandler(StreamSink<TrackEvent>);

impl sys::TrackEventCallback for TrackEventHandler {
    fn on_ended(&mut self) {
        self.0.add(TrackEvent::Ended);
    }
}

#[cfg(test)]
mod test {
    use std::sync::{Arc, Mutex};

    use libwebrtc_sys::{AudioLayer, TaskQueueFactory};

    use crate::AudioDeviceId;

    use super::AudioDeviceModule;

    #[test]
    fn adm_thread_safety() {
        let task_queue_factory = Arc::new(Mutex::new(
            TaskQueueFactory::create_default_task_queue_factory(),
        ));

        let handle = std::thread::spawn(move || {
            let audio_device_module = AudioDeviceModule::new(
                AudioLayer::kPlatformDefaultAudio,
                Arc::clone(&task_queue_factory),
            )
            .unwrap();

            audio_device_module
        });

        let mut module = handle.join().unwrap();
        module.playout_devices().unwrap();
        module.recording_devices().unwrap();
        module
            .set_recording_device(AudioDeviceId::default(), 0)
            .unwrap();
    }
}
