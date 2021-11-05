use libwebrtc_sys::system_time_millis;
use std::{ffi::CString, os::raw::c_char, ptr};

#[no_mangle]
pub extern "C" fn SystemTimeMillis() -> ptr::NonNull<c_char> {
    string_into_c_str(system_time_millis())
}

/// # Safety
///
/// Pupa and lupa go for salary
#[no_mangle]
pub unsafe extern "C" fn string_free(s: ptr::NonNull<c_char>) {
    CString::from_raw(s.as_ptr());
}

fn string_into_c_str(string: String) -> ptr::NonNull<c_char> {
    ptr::NonNull::new(CString::new(string).unwrap().into_raw()).unwrap()
}
