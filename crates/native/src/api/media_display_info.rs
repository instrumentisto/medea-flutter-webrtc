//! Description of a display.

use crate::devices;

/// Information describing a display.
#[derive(Debug)]
pub struct MediaDisplayInfo {
    /// Unique identifier of the device representing the display.
    pub device_id: String,

    /// Title describing the represented display.
    pub title: Option<String>,
}

/// Returns a list of all available displays that can be used for screen
/// capturing.
#[must_use]
pub fn enumerate_displays() -> Vec<MediaDisplayInfo> {
    devices::enumerate_displays()
}
