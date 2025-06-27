//! A single media input or output device description.

use crate::api::WEBRTC;

/// Possible kinds of media devices.
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum MediaDeviceKind {
    /// Audio input device (for example, a microphone).
    AudioInput,

    /// Audio output device (for example, a pair of headphones).
    AudioOutput,

    /// Video input device (for example, a webcam).
    VideoInput,
}

/// Information describing a single media input or output device.
#[derive(Debug)]
pub struct MediaDeviceInfo {
    /// Unique identifier for the represented device.
    pub device_id: String,

    /// Kind of the represented device.
    pub kind: MediaDeviceKind,

    /// Label describing the represented device.
    pub label: String,
}

/// Returns a list of all available media input and output devices, such as
/// microphones, cameras, headsets, and so forth.
pub fn enumerate_devices() -> anyhow::Result<Vec<MediaDeviceInfo>> {
    WEBRTC.lock().unwrap().enumerate_devices()
}
