//! Media types of a [`MediaStreamTrack`].

use libwebrtc_sys as sys;

#[cfg(doc)]
use crate::api::MediaStreamTrack;

/// Possible media types of a [`MediaStreamTrack`].
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum MediaType {
    /// Audio [`MediaStreamTrack`].
    Audio,

    /// Video [`MediaStreamTrack`].
    Video,
}

impl From<MediaType> for sys::MediaType {
    fn from(state: MediaType) -> Self {
        match state {
            MediaType::Audio => Self::AUDIO,
            MediaType::Video => Self::VIDEO,
        }
    }
}

impl From<sys::MediaType> for MediaType {
    fn from(state: sys::MediaType) -> Self {
        match state {
            sys::MediaType::AUDIO => Self::Audio,
            sys::MediaType::VIDEO => Self::Video,
            _ => unreachable!(),
        }
    }
}
