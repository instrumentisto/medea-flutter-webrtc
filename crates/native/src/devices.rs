#[cfg(target_os = "windows")]
use std::{ffi::OsStr, mem, os::windows::prelude::OsStrExt, thread};
use std::{
    ptr,
    sync::atomic::{AtomicPtr, Ordering},
};

use anyhow::anyhow;
use libwebrtc_sys as sys;
#[cfg(target_os = "windows")]
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
            SW_HIDE, WM_DEVICECHANGE, WM_QUIT, WNDCLASSEXW, WS_ICONIC,
        },
    },
};

use crate::{
    api,
    stream_sink::StreamSink,
    user_media::{AudioDeviceId, VideoDeviceId},
    AudioDeviceModule, Webrtc,
};

/// Static instance of a [`DeviceState`].
static ON_DEVICE_CHANGE: AtomicPtr<DeviceState> =
    AtomicPtr::new(ptr::null_mut());

/// Struct containing the current number of media devices and some tools to
/// enumerate them (such as [`AudioDeviceModule`] and [`VideoDeviceInfo`]), and
/// generate event with [`OnDeviceChangeCallback`], if the last is needed.
struct DeviceState {
    cb: StreamSink<()>,
    adm: AudioDeviceModule,
    _thread: sys::Thread,
    vdi: sys::VideoDeviceInfo,
    count: u32,
}

impl DeviceState {
    /// Creates a new [`DeviceState`].
    fn new(
        cb: StreamSink<()>,
        tq: &mut sys::TaskQueueFactory,
    ) -> anyhow::Result<Self> {
        let mut thread = sys::Thread::create(false)?;
        thread.start()?;
        let adm = AudioDeviceModule::new(
            &mut thread,
            sys::AudioLayer::kPlatformDefaultAudio,
            tq,
        )?;

        let vdi = sys::VideoDeviceInfo::create()?;

        let mut ds = Self {
            adm,
            _thread: thread,
            vdi,
            count: 0,
            cb,
        };

        let device_count = ds.count_devices();
        ds.set_count(device_count);

        Ok(ds)
    }

    /// Counts current media device number.
    fn count_devices(&mut self) -> u32 {
        self.adm.playout_devices()
            + self.adm.recording_devices()
            + self.vdi.number_of_devices()
    }

    /// Fixes some media device count in the [`DeviceState`].
    fn set_count(&mut self, new_count: u32) {
        self.count = new_count;
    }

    /// Triggers the [`OnDeviceChangeCallback`].
    fn on_device_change(&mut self) {
        self.cb.add(());
    }
}

impl Webrtc {
    /// Returns a list of all available audio input and output devices.
    ///
    /// # Panics
    ///
    /// On any error returned from `libWebRTC`.
    pub fn enumerate_devices(
        &mut self,
    ) -> anyhow::Result<Vec<api::MediaDeviceInfo>> {
        let mut audio = {
            let count_playout = self.audio_device_module.playout_devices();
            let count_recording = self.audio_device_module.recording_devices();

            #[allow(clippy::cast_sign_loss)]
            let mut result =
                Vec::with_capacity((count_playout + count_recording) as usize);

            for kind in [
                api::MediaDeviceKind::AudioOutput,
                api::MediaDeviceKind::AudioInput,
            ] {
                let count: i16 =
                    if let api::MediaDeviceKind::AudioOutput = kind {
                        count_playout
                    } else {
                        count_recording
                    }
                    .try_into()?;

                for i in 0..count {
                    let (label, device_id) =
                        if let api::MediaDeviceKind::AudioOutput = kind {
                            self.audio_device_module.playout_device_name(i)?
                        } else {
                            self.audio_device_module.recording_device_name(i)?
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
            let count = self.video_device_info.number_of_devices();
            let mut result = Vec::with_capacity(count as usize);

            for i in 0..count {
                let (label, device_id) =
                    self.video_device_info.device_name(i)?;

                result.push(api::MediaDeviceInfo {
                    device_id,
                    kind: api::MediaDeviceKind::VideoInput,
                    label,
                });
            }

            result
        };

        audio.append(&mut video);

        Ok(audio)
    }

    /// Returns an index of the specific video device identified by the provided
    /// [`VideoDeviceId`].
    ///
    /// # Errors
    ///
    /// Whenever [`VideoDeviceInfo::device_name()`][1] returns an error.
    ///
    /// [1]: libwebrtc_sys::VideoDeviceInfo::device_name
    pub fn get_index_of_video_device(
        &mut self,
        device_id: &VideoDeviceId,
    ) -> anyhow::Result<Option<u32>> {
        let count = self.video_device_info.number_of_devices();
        for i in 0..count {
            let (_, id) = self.video_device_info.device_name(i)?;
            if id == device_id.to_string() {
                return Ok(Some(i));
            }
        }
        Ok(None)
    }

    /// Returns an index of the specific audio input device identified by the
    /// provided [`AudioDeviceId`].
    ///
    /// # Errors
    ///
    /// Whenever [`AudioDeviceModule::recording_devices()`][1] or
    /// [`AudioDeviceModule::recording_device_name()`][2] returns an error.
    ///
    /// [1]: libwebrtc_sys::AudioDeviceModule::recording_devices
    /// [2]: libwebrtc_sys::AudioDeviceModule::recording_device_name
    pub fn get_index_of_audio_recording_device(
        &mut self,
        device_id: &AudioDeviceId,
    ) -> anyhow::Result<Option<u16>> {
        let count: i16 =
            self.audio_device_module.recording_devices().try_into()?;
        for i in 0..count {
            let (_, id) = self.audio_device_module.recording_device_name(i)?;
            if id == device_id.to_string() {
                #[allow(clippy::cast_sign_loss)]
                return Ok(Some(i as u16));
            }
        }
        Ok(None)
    }

    /// Returns an index of the specific audio input device identified by the
    /// provided [`AudioDeviceId`].
    ///
    /// # Errors
    ///
    /// Whenever [`AudioDeviceModule::playout_devices()`][1] or
    /// [`AudioDeviceModule::playout_device_name()`][2] returns an error.
    ///
    /// [1]: libwebrtc_sys::AudioDeviceModule::playout_devices
    /// [2]: libwebrtc_sys::AudioDeviceModule::playout_device_name
    pub fn get_index_of_audio_playout_device(
        &mut self,
        device_id: &AudioDeviceId,
    ) -> anyhow::Result<Option<u16>> {
        let count: i16 =
            self.audio_device_module.playout_devices().try_into()?;
        for i in 0..count {
            let (_, id) = self.audio_device_module.playout_device_name(i)?;
            if id == device_id.to_string() {
                #[allow(clippy::cast_sign_loss)]
                return Ok(Some(i as u16));
            }
        }
        Ok(None)
    }

    /// Sets the specified `audio playout` device.
    pub fn set_audio_playout_device(
        &mut self,
        device_id: String,
    ) -> anyhow::Result<()> {
        let device_id = AudioDeviceId::from(device_id);
        let index = self.get_index_of_audio_playout_device(&device_id)?;

        if let Some(index) = index {
            self.audio_device_module.set_playout_device(index)
        } else {
            Err(anyhow!("Cannot find playout device with ID `{device_id}`"))
        }
    }

    /// Sets the provided [`OnDeviceChangeCallback`] as the callback to be
    /// called whenever the set of available media devices changes.
    ///
    /// Only one callback can be set at a time, so the previous one will be
    /// dropped, if any.
    pub fn set_on_device_changed(
        &mut self,
        cb: StreamSink<()>,
    ) -> anyhow::Result<()> {
        let prev = ON_DEVICE_CHANGE.swap(
            Box::into_raw(Box::new(DeviceState::new(
                cb,
                &mut self.task_queue_factory,
            )?)),
            Ordering::SeqCst,
        );

        if prev.is_null() {
            unsafe {
                init();
            }
        } else {
            unsafe {
                drop(Box::from_raw(prev));
            }
        }

        Ok(())
    }
}

#[cfg(target_os = "windows")]
/// Creates a detached [`Thread`] creating and registering a system message
/// window - [`HWND`].
///
/// [`Thread`]: thread::Thread
pub unsafe fn init() {
    /// Message handler for an [`HWND`].
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
            // The device event when a device has been added to or removed from
            // the system.
            if DBT_DEVNODES_CHANGED == wp {
                let state = ON_DEVICE_CHANGE.load(Ordering::SeqCst);

                if !state.is_null() {
                    let device_state = &mut *state;
                    let new_count = device_state.count_devices();

                    if device_state.count != new_count {
                        device_state.set_count(new_count);
                        device_state.on_device_change();
                    }
                }
            }
        } else {
            result = DefWindowProcW(hwnd, msg, wp, lp);
        }

        result
    }

    thread::spawn(|| {
        let lpsz_class_name = OsStr::new("EventWatcher")
            .encode_wide()
            .chain(Some(0).into_iter())
            .collect::<Vec<u16>>()
            .as_ptr();

        #[allow(clippy::cast_possible_truncation)]
        let class = WNDCLASSEXW {
            cbSize: mem::size_of::<WNDCLASSEXW>() as u32,
            lpfnWndProc: Some(wndproc),
            lpszClassName: lpsz_class_name,
            ..WNDCLASSEXW::default()
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
            if msg.message == WM_QUIT {
                break;
            }

            TranslateMessage(&msg);
            DispatchMessageW(&msg);
        }
    });
}

#[cfg(target_os = "linux")]
mod linux_device_change {
    pub mod udev {
        use libc::{c_int, c_short, c_ulong, c_void, timespec};
        use libudev::EventType;
        use std::{
            io, os::unix::prelude::AsRawFd, ptr, sync::atomic::Ordering,
        };

        use crate::devices::ON_DEVICE_CHANGE;

        #[repr(C)]
        struct pollfd {
            fd: c_int,
            events: c_short,
            revents: c_short,
        }

        #[repr(C)]
        struct sigset_t {
            __private: c_void,
        }

        #[allow(non_camel_case_types)]
        type nfds_t = c_ulong;

        const POLLIN: c_short = 0x0001;

        extern "C" {
            fn ppoll(
                fds: *mut pollfd,
                nfds: nfds_t,
                timeout_ts: *mut timespec,
                sigmask: *const sigset_t,
            ) -> c_int;
        }

        pub fn monitor(context: &libudev::Context) -> io::Result<()> {
            let mut monitor = libudev::Monitor::new(context)?;
            monitor.match_subsystem("video4linux")?;
            let mut socket = monitor.listen()?;

            let mut fds = vec![pollfd {
                fd: socket.as_raw_fd(),
                events: POLLIN,
                revents: 0,
            }];

            loop {
                let result = unsafe {
                    ppoll(
                        (&mut fds[..]).as_mut_ptr(),
                        fds.len() as nfds_t,
                        ptr::null_mut(),
                        ptr::null(),
                    )
                };

                if result < 0 {
                    return Err(io::Error::last_os_error());
                }

                let event = match socket.receive_event() {
                    Some(evt) => evt,
                    None => {
                        continue;
                    }
                };

                if event.event_type() == EventType::Add
                    || event.event_type() == EventType::Remove
                {
                    let state = ON_DEVICE_CHANGE.load(Ordering::SeqCst);
                    if !state.is_null() {
                        let device_state = unsafe { &mut *state };
                        let new_count = device_state.count_devices();

                        if device_state.count != new_count {
                            device_state.set_count(new_count);
                            device_state.on_device_change();
                        }
                    }
                }
            }
        }
    }

    pub mod pulse_audio {
        use std::{ffi::CString, mem, ptr, sync::atomic::Ordering};

        use libc::{c_char, c_void};
        use libpulse_sys::{
            pa_context, pa_context_connect, pa_context_disconnect,
            pa_context_get_server_info, pa_context_get_sink_info_by_index,
            pa_context_get_source_info_by_index, pa_context_get_state,
            pa_context_is_good, pa_context_new,
            pa_context_set_subscribe_callback, pa_context_state_t,
            pa_context_subscribe, pa_context_unref, pa_mainloop,
            pa_mainloop_free, pa_mainloop_get_api, pa_mainloop_iterate,
            pa_mainloop_new, pa_sink_info, pa_source_info,
            pa_subscription_event_type_t, pa_subscription_mask_t,
            PA_SUBSCRIPTION_EVENT_CHANGE, PA_SUBSCRIPTION_EVENT_FACILITY_MASK,
            PA_SUBSCRIPTION_EVENT_NEW, PA_SUBSCRIPTION_EVENT_REMOVE,
            PA_SUBSCRIPTION_EVENT_SERVER, PA_SUBSCRIPTION_EVENT_SINK,
            PA_SUBSCRIPTION_EVENT_SOURCE, PA_SUBSCRIPTION_EVENT_TYPE_MASK,
            PA_SUBSCRIPTION_MASK_SINK, PA_SUBSCRIPTION_MASK_SOURCE,
        };

        use crate::devices::ON_DEVICE_CHANGE;

        extern "C" fn context_subscribe_cb(
            context: *mut pa_context,
            type_: pa_subscription_event_type_t,
            idx: u32,
            userdata: *mut c_void,
        ) {
            unsafe {
                let facility: pa_subscription_event_type_t =
                    type_ & PA_SUBSCRIPTION_EVENT_FACILITY_MASK;
                let event_type: pa_subscription_event_type_t =
                    type_ & PA_SUBSCRIPTION_EVENT_TYPE_MASK;

                if facility == PA_SUBSCRIPTION_EVENT_SERVER
                    || facility != PA_SUBSCRIPTION_EVENT_CHANGE
                {
                    pa_context_get_server_info(context, None, userdata);
                }

                if facility != PA_SUBSCRIPTION_EVENT_SOURCE
                    && facility != PA_SUBSCRIPTION_EVENT_SINK
                {
                    return;
                }

                if event_type == PA_SUBSCRIPTION_EVENT_NEW {
                    /* Microphone in the source output has changed */

                    if facility == PA_SUBSCRIPTION_EVENT_SOURCE {
                        pa_context_get_source_info_by_index(
                            context,
                            idx,
                            Some(get_source_info_cb),
                            userdata,
                        );
                    } else if facility == PA_SUBSCRIPTION_EVENT_SINK {
                        pa_context_get_sink_info_by_index(
                            context,
                            idx,
                            Some(get_sink_info_cb),
                            userdata,
                        );
                    }
                } else if event_type == PA_SUBSCRIPTION_EVENT_REMOVE {
                    let state = ON_DEVICE_CHANGE.load(Ordering::SeqCst);
                    if !state.is_null() {
                        let device_state = &mut *state;
                        let new_count = device_state.count_devices();

                        if device_state.count != new_count {
                            device_state.set_count(new_count);
                            device_state.on_device_change();
                        }
                    }
                }
            }
        }

        extern "C" fn get_source_info_cb(
            _ctx: *mut pa_context,
            _info: *const pa_source_info,
            eol: i32,
            _userdata: *mut c_void,
        ) {
            if eol != 0 {
                return;
            }
            let state = ON_DEVICE_CHANGE.load(Ordering::SeqCst);
            if !state.is_null() {
                let device_state = unsafe { &mut *state };
                let new_count = device_state.count_devices();

                if device_state.count != new_count {
                    device_state.set_count(new_count);
                    device_state.on_device_change();
                }
            }
        }

        extern "C" fn get_sink_info_cb(
            _ctx: *mut pa_context,
            _info: *const pa_sink_info,
            eol: i32,
            _userdata: *mut c_void,
        ) {
            if eol != 0 {
                return;
            }

            let state = ON_DEVICE_CHANGE.load(Ordering::SeqCst);
            if !state.is_null() {
                let device_state = unsafe { &mut *state };
                let new_count = device_state.count_devices();

                if device_state.count != new_count {
                    device_state.set_count(new_count);
                    device_state.on_device_change();
                }
            }
        }

        pub struct AudioMonitor {
            context: *mut pa_context,
            main_loop: *mut pa_mainloop,
        }

        impl AudioMonitor {
            pub fn iterate(&mut self) -> anyhow::Result<()> {
                let mut retval = 0;
                unsafe {
                    if pa_mainloop_iterate(self.main_loop, 1, &mut retval) < 0 {
                        anyhow::bail!("mainloop iterate error {retval}");
                    }
                }
                Ok(())
            }

            pub unsafe fn new(id: u64) -> anyhow::Result<Self> {
                let ml = pa_mainloop_new();
                if ml.is_null() {
                    anyhow::bail!("mainloop is null");
                }

                let name = format!("webrtc-desktop{id}");
                let c_str = CString::new(name).unwrap();
                let c_world: *const c_char = c_str.as_ptr() as *const c_char;

                let api = pa_mainloop_get_api(ml);
                let ctx = pa_context_new(api, c_world);
                if ctx.is_null() {
                    anyhow::bail!("context start error");
                }

                let ud: *mut c_void = mem::transmute(ctx);

                pa_context_set_subscribe_callback(
                    ctx,
                    Some(context_subscribe_cb),
                    ud,
                );

                if pa_context_connect(ctx, ptr::null(), 0, ptr::null()) < 0 {
                    anyhow::bail!("context connect error");
                }

                loop {
                    let state: pa_context_state_t;

                    state = pa_context_get_state(ctx);

                    if !pa_context_is_good(state) {
                        anyhow::bail!("context connect error");
                    }

                    if state == pa_context_state_t::Ready {
                        break;
                    }

                    let mut retval = 0;
                    if pa_mainloop_iterate(ml, 1, &mut retval) < 0 {
                        anyhow::bail!("mainloop iterate error");
                    }
                }

                let mask: pa_subscription_mask_t = PA_SUBSCRIPTION_MASK_SOURCE
                    | PA_SUBSCRIPTION_MASK_SINK
                    | PA_SUBSCRIPTION_EVENT_SERVER
                    | PA_SUBSCRIPTION_EVENT_CHANGE;

                pa_context_subscribe(ctx, mask, None, ptr::null_mut());

                return Ok(Self {
                    context: ctx,
                    main_loop: ml,
                });
            }
        }

        impl Drop for AudioMonitor {
            fn drop(&mut self) {
                unsafe {
                    pa_context_disconnect(self.context);
                    pa_context_unref(self.context);
                    pa_mainloop_free(self.main_loop);
                }
            }
        }
    }
}

#[cfg(target_os = "linux")]
/// Creates a detached [`Thread`] creating a devices monitor
/// and polls for events.
///
/// [`Thread`]: thread::Thread
pub unsafe fn init() {
    use std::thread;

    use crate::devices::linux_device_change::{
        pulse_audio::AudioMonitor, udev::monitor,
    };

    thread::spawn(move || {
        let context = libudev::Context::new().unwrap();
        monitor(&context).unwrap();
    });

    thread::spawn(move || {
        let mut m = AudioMonitor::new(42).unwrap();
        loop {
            if let Err(e) = m.iterate() {
                println!("{e}");
            }
        }
    });
}
