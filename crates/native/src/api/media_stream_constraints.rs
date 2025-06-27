//! [MediaStreamConstraints][1] for [`Webrtc::get_media()`] configuration.
//!
//! [1]: https://w3.org/TR/mediacapture-streams#dom-mediastreamconstraints

pub mod audio_constraints;
pub mod video_constraints;

pub use self::{
    audio_constraints::{AudioConstraints, AudioProcessingConstraints},
    video_constraints::VideoConstraints,
};
#[cfg(doc)]
use crate::{Webrtc, api::MediaStreamTrack};

/// [MediaStreamConstraints][1], used to instruct what sort of
/// [`MediaStreamTrack`]s to return by the [`Webrtc::get_media()`].
///
/// [1]: https://w3.org/TR/mediacapture-streams#dom-mediastreamconstraints
#[derive(Debug)]
pub struct MediaStreamConstraints {
    /// Specifies the nature and settings of the audio [`MediaStreamTrack`].
    pub audio: Option<AudioConstraints>,

    /// Specifies the nature and settings of the video [`MediaStreamTrack`].
    pub video: Option<VideoConstraints>,
}
