//! Platform initialization and clean-up handler.

#[cfg(target_os = "windows")]
pub use windows::Platform;

#[cfg(not(target_os = "windows"))]
pub struct Platform;

#[cfg(not(target_os = "windows"))]
#[expect(
    clippy::unnecessary_wraps,
    clippy::missing_const_for_fn,
    reason = "platform specific"
)]
impl Platform {
    pub fn new() -> anyhow::Result<Self> {
        Ok(Self)
    }
}

#[cfg(target_os = "windows")]
mod windows {
    use anyhow::anyhow;
    use windows::Win32::System::Com::{self, COINIT_MULTITHREADED};

    pub struct Platform;

    impl Platform {
        pub fn new() -> anyhow::Result<Self> {
            init()?;

            Ok(Self)
        }
    }

    impl Drop for Platform {
        fn drop(&mut self) {
            uninit();
        }
    }

    fn init() -> anyhow::Result<()> {
        unsafe {
            Com::CoInitializeEx(None, COINIT_MULTITHREADED)
                .ok()
                .map_err(|e| anyhow!("Failed to initialize COM.").context(e))
        }
    }

    fn uninit() {
        unsafe {
            Com::CoUninitialize();
        }
    }
}
