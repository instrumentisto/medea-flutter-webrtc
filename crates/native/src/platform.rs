//! Platform initialization and clean-up handler.

#[cfg(target_os = "windows")]
pub use windows::*;

#[cfg(not(target_os = "windows"))]
pub use default::*;

#[cfg(not(target_os = "windows"))]
mod default {
    pub fn init() -> anyhow::Result<()> {
        Ok(())
    }

    pub fn uninit() {}
}

#[cfg(target_os = "windows")]
mod windows {
    use anyhow::anyhow;
    use windows::Win32::System::Com::{self, COINIT_MULTITHREADED};

    pub fn init() -> anyhow::Result<()> {
        unsafe {
            Com::CoInitializeEx(None, COINIT_MULTITHREADED)
                .ok()
                .map_err(|e| anyhow!("Failed to initialize COM.").context(e))
        }
    }

    pub fn uninit() {
        unsafe {
            Com::CoUninitialize();
        }
    }
}
