use libwebrtc_sys::{
    AudioDeviceModule, AudioLayer, TaskQueueFactory, VideoDeviceInfo,
};

use crate::{api, Webrtc};

/// Returns a list of all available media input and output devices, such as
/// microphones, cameras, headsets, and so forth.
impl Webrtc {
    #[must_use]
    pub fn enumerate_devices(self: &mut Webrtc) -> Vec<api::MediaDeviceInfo> {
        let mut audio = audio_devices_info(&mut self.0.task_queue_factory);
        let mut video = video_devices_info();

        audio.append(&mut video);

        audio
    }
}

/// Returns a list of all available audio input and output devices.
fn audio_devices_info(
    task_queue: &mut TaskQueueFactory,
) -> Vec<api::MediaDeviceInfo> {
    // TODO: Do not unwrap.
    let adm = AudioDeviceModule::create(
        AudioLayer::kPlatformDefaultAudio,
        task_queue,
    )
    .unwrap();
    adm.init().unwrap();

    let count_playout = adm.playout_devices().unwrap();
    let count_recording = adm.recording_devices().unwrap();

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
                    adm.playout_device_name(i).unwrap()
                } else {
                    adm.recording_device_name(i).unwrap()
                };

            result.push(api::MediaDeviceInfo {
                device_id,
                kind,
                label,
            });
        }
    }

    result
}

/// Returns a list of all available video input devices.
fn video_devices_info() -> Vec<api::MediaDeviceInfo> {
    // TODO: Do not unwrap.
    let mut vdi = VideoDeviceInfo::create().unwrap();
    let count = vdi.number_of_devices();
    let mut result = Vec::with_capacity(count as usize);

    for i in 0..count {
        let (label, device_id) = vdi.device_name(i).unwrap();

        result.push(api::MediaDeviceInfo {
            device_id,
            kind: api::MediaDeviceKind::kVideoInput,
            label,
        });
    }

    result
}
