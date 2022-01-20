use std::{ffi::OsStr, mem, os::windows::prelude::OsStrExt, ptr};

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
            SW_HIDE, WM_CLOSE, WM_COMMAND, WM_CTLCOLORSTATIC, WM_DEVICECHANGE,
            WM_ERASEBKGND, WM_SETFOCUS, WM_SIZE, WNDCLASSEXW, WS_ICONIC,
        },
    },
};

/// The global variable that keeps a [`Callback`].
static mut CB: Callback = Callback(None);

/// A struct that contains a `Flutter` notifier callback.
struct Callback(Option<extern "C" fn()>);

impl Callback {
    /// Calls the `Flutter` notifier callback, if it is not [`None`].
    pub fn call(&self) {
        match self.0 {
            Some(cb) => cb(),
            None => (),
        };
    }

    /// Sets the `Flutter` notifier callback.
    pub fn set_cb(&mut self, cb: extern "C" fn()) {
        self.0 = Some(cb);
    }
}

/// Sets the `Flutter` notifier callback and initiates a `System Notifier`.
#[no_mangle]
unsafe extern "C" fn register_notifier(cb: extern "C" fn()) {
    CB.set_cb(cb);
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
        // The device event when a device has been added to or removed from the system.
        if DBT_DEVNODES_CHANGED == wp {
            CB.call();
        }
    } else if msg == WM_ERASEBKGND {
    } else if msg == WM_SETFOCUS {
    } else if msg == WM_SIZE {
    } else if msg == WM_CTLCOLORSTATIC {
    } else if msg == WM_COMMAND {
    } else {
        result = DefWindowProcW(hwnd, msg, wp, lp);
    }

    result
}

/// Creates a detached [`std::thread::Thread`] that creates and register
/// system message window - [`HWND`].
pub unsafe fn init() {
    std::thread::spawn(|| {
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
