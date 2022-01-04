use crate::{api, Webrtc};

/// Returns a list of all available media input and output devices, such as
/// microphones, cameras, headsets, and so forth.
impl Webrtc {
    /// Returns a list of all available audio input and output devices.
    ///
    /// # Panics
    ///
    /// May panic because of `libWebRTC` inner errors.
    #[must_use]
    pub fn enumerate_devices(self: &mut Webrtc) -> Vec<api::MediaDeviceInfo> {
        // Returns a list of all available audio devices.
        let mut audio = {
            let count_playout =
                self.0.audio_device_module.playout_devices().unwrap();
            let count_recording =
                self.0.audio_device_module.recording_devices().unwrap();

            #[allow(clippy::cast_sign_loss)]
            let mut result =
                Vec::with_capacity((count_playout + count_recording) as usize);

            for kind in [
                api::MediaDeviceKind::kAudioOutput,
                api::MediaDeviceKind::kAudioInput,
            ] {
                let count = if let api::MediaDeviceKind::kAudioOutput = kind {
                    count_playout
                } else {
                    count_recording
                };

                for i in 0..count {
                    let (label, device_id) =
                        if let api::MediaDeviceKind::kAudioOutput = kind {
                            self.0
                                .audio_device_module
                                .playout_device_name(i)
                                .unwrap()
                        } else {
                            self.0
                                .audio_device_module
                                .recording_device_name(i)
                                .unwrap()
                        };

                    result.push(api::MediaDeviceInfo {
                        device_id,
                        kind,
                        label,
                    });
                }
            }

            result
        };

        // Returns a list of all available video input devices.
        let mut video = {
            let count = self.0.video_device_info.number_of_devices();
            let mut result = Vec::with_capacity(count as usize);

            for i in 0..count {
                let (label, device_id) =
                    self.0.video_device_info.device_name(i).unwrap();

                result.push(api::MediaDeviceInfo {
                    device_id,
                    kind: api::MediaDeviceKind::kVideoInput,
                    label,
                });
            }

            result
        };

        audio.append(&mut video);

        audio
    }
}
