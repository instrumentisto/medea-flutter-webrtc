use std::{
    ffi::OsStr,
    mem,
    os::windows::prelude::OsStrExt,
    ptr::{self},
    sync::atomic::{AtomicPtr, Ordering},
};

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
            SW_HIDE, WM_CLOSE, WM_DEVICECHANGE, WNDCLASSEXW, WS_ICONIC,
        },
    },
};

/// The global variable that keeps a `Flutter` notifier callback.
static mut CB: AtomicPtr<extern "C" fn()> = AtomicPtr::new(ptr::null_mut());

/// Sets the `Flutter` notifier callback and initiates a `System Notifier`.
#[no_mangle]
unsafe extern "C" fn register_notifier(cb: extern "C" fn()) {
    CB.store(Box::into_raw(Box::new(cb)), Ordering::SeqCst);
    init();
}

/// The message handler for the [`HWND`].
unsafe extern "system" fn wndproc(
    hwnd: HWND,
    msg: UINT,
    wp: WPARAM,
    lp: LPARAM,
) -> LRESULT {
    let mut result: LRESULT = 0;

    if msg == WM_CLOSE {
        std::process::exit(0);
        // The message that notifies an application of a change to the hardware
        // configuration of a device or the computer.
    } else if msg == WM_DEVICECHANGE {
        // The device event when a device has been added to or removed from the
        // system.
        if DBT_DEVNODES_CHANGED == wp {
            let cb = CB.load(Ordering::SeqCst);

            if !cb.is_null() {
                (*cb)();
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
