use libwebrtc_sys::*;
use std::{ffi::CString, os::raw::c_char, ptr};

#[no_mangle]
pub extern "C" fn SystemTimeMillis() -> ptr::NonNull<c_char> {
    string_into_c_str(system_time_millis())
}

#[no_mangle]
pub extern "C" fn VideoInfoTest() -> DeviceInfo {
    let video_device_module = init_video_device_module();
    let video_device_info = get_video_device_info(video_device_module, 0);
    drop_video_device_module(video_device_module);
    video_device_info
}

/// # Safety
///
/// No safety
#[no_mangle]
pub unsafe extern "C" fn string_free(s: ptr::NonNull<c_char>) {
    CString::from_raw(s.as_ptr());
}

fn string_into_c_str(string: String) -> ptr::NonNull<c_char> {
    ptr::NonNull::new(CString::new(string).unwrap().into_raw()).unwrap()
}
