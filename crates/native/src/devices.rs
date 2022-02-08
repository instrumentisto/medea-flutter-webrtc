use std::{
    ffi::OsStr,
    mem,
    os::windows::prelude::OsStrExt,
    ptr,
    sync::atomic::{AtomicPtr, Ordering},
};

use cxx::UniquePtr;
use libwebrtc_sys::{AudioLayer, VideoDeviceInfo};
use winapi::{
    shared::{
        minwindef::{HINSTANCE, LPARAM, LRESULT, UINT, WPARAM},
        windef::HWND,
    },
    um::{
        dbt::DBT_DEVNODES_CHANGED,
        winuser::{
            CreateWindowExW, DefWindowProcW, DispatchMessageW, GetMessageW,
            RegisterClassExW, ShowWindow, TranslateMessage, CW_USEDEFAULT, MSG,
            SW_HIDE, WM_DEVICECHANGE, WNDCLASSEXW, WS_ICONIC,
        },
    },
};

use crate::{
    api,
    internal::OnDeviceChangeCallback,
    user_media::{AudioDeviceId, VideoDeviceId},
    AudioDeviceModule, Webrtc,
};

static ON_DEVICE_CHANGE: AtomicPtr<DeviceState> =
    AtomicPtr::new(ptr::null_mut());

struct DeviceState {
    cb: UniquePtr<OnDeviceChangeCallback>,
    adm: AudioDeviceModule,
    vdi: VideoDeviceInfo,
    count: u32,
}

impl Webrtc {
    /// Returns a list of all available audio input and output devices.
    ///
    /// # Panics
    ///
    /// Panics on any error returned from the `libWebRTC`.
    #[must_use]
    pub fn enumerate_devices(self: &mut Webrtc) -> Vec<api::MediaDeviceInfo> {
        // TODO: Dont panic but propagate errors to API users.
        // Returns a list of all available audio devices.
        let mut audio = {
            let count_playout =
                self.0.audio_device_module.inner.playout_devices().unwrap();
            let count_recording = self
                .0
                .audio_device_module
                .inner
                .recording_devices()
                .unwrap();

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
                                .inner
                                .playout_device_name(i)
                                .unwrap()
                        } else {
                            self.0
                                .audio_device_module
                                .inner
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

    /// Returns an index of a specific video device identified by the provided
    /// [`VideoDeviceId`].
    ///
    /// # Errors
    ///
    /// Errors if [`VideoDeviceInfo::device_name()`][1] returns error.
    ///
    /// [1]: [`libwebrtc_sys::VideoDeviceInfo::device_name()`]
    pub fn get_index_of_video_device(
        &mut self,
        device_id: &VideoDeviceId,
    ) -> anyhow::Result<Option<u32>> {
        let count = self.0.video_device_info.number_of_devices();
        for i in 0..count {
            let (_, id) = self.0.video_device_info.device_name(i)?;
            if id == device_id.as_ref() {
                return Ok(Some(i));
            }
        }
        Ok(None)
    }

    /// Returns an index of a specific audio input device identified by the
    /// provided [`AudioDeviceId`].
    ///
    /// # Errors
    ///
    /// Errors if [`AudioDeviceModule::recording_devices()`][1] or
    /// [`AudioDeviceModule::recording_device_name()`][2]
    /// returns error.
    ///
    /// [1]: libwebrtc_sys::AudioDeviceModule::recording_devices
    /// [2]: libwebrtc_sys::AudioDeviceModule::recording_device_name
    pub fn get_index_of_audio_recording_device(
        &mut self,
        device_id: &AudioDeviceId,
    ) -> anyhow::Result<Option<u16>> {
        let count = self.0.audio_device_module.inner.recording_devices()?;
        for i in 0..count {
            let (_, id) =
                self.0.audio_device_module.inner.recording_device_name(i)?;
            if id == device_id.as_ref() {
                #[allow(clippy::cast_sign_loss)]
                return Ok(Some(i as u16));
            }
        }
        Ok(None)
    }

    /// Sets the provided [`OnDeviceChangeCallback`] as the callback to be
    /// called whenever the set of available media devices has changed.
    ///
    /// Only one callback can be set a time, so the previous one will be
    /// dropped, if any.
    pub fn set_on_device_changed(
        self: &mut Webrtc,
        cb: UniquePtr<OnDeviceChangeCallback>,
    ) {
        let adm = AudioDeviceModule::new(
            AudioLayer::kPlatformDefaultAudio,
            &mut self.0.task_queue_factory,
        )
        .unwrap();

        let mut vdi = VideoDeviceInfo::create().unwrap();

        let device_count = TryInto::<u32>::try_into(
            adm.inner.playout_devices().unwrap()
                + adm.inner.recording_devices().unwrap(),
        )
        .unwrap()
            + vdi.number_of_devices();

        let prev = ON_DEVICE_CHANGE.swap(
            Box::into_raw(Box::new(DeviceState {
                cb,
                adm,
                vdi,
                count: device_count,
            })),
            Ordering::SeqCst,
        );

        if !prev.is_null() {
            unsafe {
                let _ = Box::from_raw(prev);
            }
        }

        unsafe {
            init();
        }
    }
}

/// The message handler for the [`HWND`].
unsafe extern "system" fn wndproc(
    hwnd: HWND,
    msg: UINT,
    wp: WPARAM,
    lp: LPARAM,
) -> LRESULT {
    let mut result: LRESULT = 0;

    // The message that notifies an application of a change to the hardware
    // configuration of a device or the computer.
    if msg == WM_DEVICECHANGE {
        // The device event when a device has been added to or removed from the
        // system.
        if DBT_DEVNODES_CHANGED == wp {
            let state = ON_DEVICE_CHANGE.load(Ordering::SeqCst);

            if !state.is_null() {
                let device_state = &mut *state;
                let new_count = TryInto::<u32>::try_into(
                    device_state.adm.inner.playout_devices().unwrap()
                        + device_state.adm.inner.recording_devices().unwrap(),
                )
                .unwrap()
                    + device_state.vdi.number_of_devices();

                if device_state.count != new_count {
                    device_state.count = new_count;

                    device_state.cb.pin_mut().on_device_change();
                }
            }
        }
    } else {
        result = DefWindowProcW(hwnd, msg, wp, lp);
    }

    result
}

/// Creates a detached [`std::thread::Thread`] that creates and register
/// system message window - [`HWND`].
pub unsafe fn init() {
    std::thread::spawn(|| {
        #[allow(clippy::cast_possible_truncation)]
        let class = WNDCLASSEXW {
            cbSize: mem::size_of::<WNDCLASSEXW>() as u32,
            style: Default::default(),
            lpfnWndProc: Some(wndproc),
            cbClsExtra: 0,
            cbWndExtra: 0,
            hInstance: ptr::null_mut(),
            hIcon: ptr::null_mut(),
            hCursor: ptr::null_mut(),
            hbrBackground: ptr::null_mut(),
            lpszMenuName: ptr::null_mut(),
            lpszClassName: OsStr::new(
                format!("{:?}", std::time::Instant::now()).as_str(),
            )
            .encode_wide()
            .chain(Some(0).into_iter())
            .collect::<Vec<u16>>()
            .as_ptr(),
            hIconSm: ptr::null_mut(),
        };
        RegisterClassExW(&class);

        let hwnd = CreateWindowExW(
            0,
            class.lpszClassName,
            OsStr::new("Notifier")
                .encode_wide()
                .chain(Some(0).into_iter())
                .collect::<Vec<u16>>()
                .as_ptr(),
            WS_ICONIC,
            0,
            0,
            CW_USEDEFAULT,
            0,
            std::ptr::null_mut(),
            std::ptr::null_mut(),
            0 as HINSTANCE,
            std::ptr::null_mut(),
        );

        ShowWindow(hwnd, SW_HIDE);

        let mut msg: MSG = mem::zeroed();

        while GetMessageW(&mut msg, hwnd, 0, 0) > 0 {
            TranslateMessage(&msg);
            DispatchMessageW(&msg);
        }
    });
}
