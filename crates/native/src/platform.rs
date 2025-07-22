pub struct Platform;

impl Platform {
    pub fn new() -> anyhow::Result<Self> {
        #[cfg(target_os = "windows")]
        windows::init()?;

        Ok(Self)
    }
}

impl Drop for Platform {
    fn drop(&mut self) {
        #[cfg(target_os = "windows")]
        windows::uninit();
    }
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
