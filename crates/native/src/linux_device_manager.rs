use std::{ffi::CString, mem, ptr, sync::atomic::Ordering};

use libc::{c_char, c_void};
use libpulse_sys::{
    pa_context, pa_context_connect, pa_context_get_server_info,
    pa_context_get_sink_info_by_index, pa_context_get_source_info_by_index,
    pa_context_get_state, pa_context_new, pa_context_set_subscribe_callback,
    pa_context_state_t, pa_mainloop, pa_mainloop_get_api, pa_mainloop_iterate,
    pa_mainloop_new, pa_sink_info, pa_source_info,
    pa_subscription_event_type_t, PA_SUBSCRIPTION_EVENT_CHANGE,
    PA_SUBSCRIPTION_EVENT_FACILITY_MASK, PA_SUBSCRIPTION_EVENT_NEW,
    PA_SUBSCRIPTION_EVENT_REMOVE, PA_SUBSCRIPTION_EVENT_SERVER,
    PA_SUBSCRIPTION_EVENT_SINK, PA_SUBSCRIPTION_EVENT_SOURCE,
    PA_SUBSCRIPTION_EVENT_TYPE_MASK, pa_context_is_good, pa_subscription_mask_t, PA_SUBSCRIPTION_MASK_SOURCE, PA_SUBSCRIPTION_MASK_SINK, pa_context_subscribe, pa_context_disconnect, pa_context_unref, pa_mainloop_free,
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
        
                if device_state.count() != new_count {
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

        if device_state.count() != new_count {
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

        if device_state.count() != new_count {
            device_state.set_count(new_count);
            device_state.on_device_change();
        }
    }
}

pub struct Monitor {
    context: *mut pa_context,
    main_loop: *mut pa_mainloop,
}

impl Monitor {
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

        pa_context_set_subscribe_callback(ctx, Some(context_subscribe_cb), ud);

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

impl Drop for Monitor {
    fn drop(&mut self) {
        unsafe {
            pa_context_disconnect(self.context);
            pa_context_unref(self.context);
            pa_mainloop_free(self.main_loop);
        }
    }
}
