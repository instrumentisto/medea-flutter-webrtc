use std::{
    ffi::OsStr, mem, os::windows::prelude::OsStrExt, ptr, thread::JoinHandle,
};

use winapi::{
    shared::{
        minwindef::{HINSTANCE, LPARAM, LRESULT, UINT, WPARAM},
        windef::HWND,
    },
    um::winuser::{
        CreateWindowExW, DefWindowProcW, DispatchMessageW, GetMessageW,
        RegisterClassExW, ShowWindow, TranslateMessage, CW_USEDEFAULT, MSG,
        SW_HIDE, WM_CLOSE, WM_COMMAND, WM_CTLCOLORSTATIC, WM_DEVICECHANGE,
        WM_ERASEBKGND, WM_SETFOCUS, WM_SIZE, WNDCLASSEXW, WS_ICONIC,
    },
};

static mut ASD: Exampl = Exampl { pupa: None };

struct Exampl {
    pub pupa: Option<extern "C" fn()>,
}

impl Exampl {
    pub fn kek(&self) {
        println!("l;m;mmomo");
        match self.pupa {
            Some(cb) => cb(),
            None => (),
        };
    }
}

#[no_mangle]
unsafe extern "C" fn register_notifier_cb(cb: extern "C" fn()) {
    println!("123123wqe");

    ASD.pupa = Some(cb);
    asd();
}

unsafe extern "system" fn wndproc(
    hwnd: HWND,
    msg: UINT,
    wp: WPARAM,
    lp: LPARAM,
) -> LRESULT {
    let mut result: LRESULT = 0;

    println!("kl");

    if msg == WM_CLOSE {
        std::process::exit(0);
    } else if msg == WM_DEVICECHANGE {
        ASD.kek();
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

pub unsafe fn asd() -> JoinHandle<()> {
    let a = std::thread::spawn(move || {
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
            OsStr::new("dsa")
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
    a
}
