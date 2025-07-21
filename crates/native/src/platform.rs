pub struct Platform;

impl Platform {
    pub fn new() -> anyhow::Result<Self> {
        #[cfg(target = "windows")]
        unsafe {
            windows::init()?
        };

        Ok(Self)
    }
}

impl Drop for Platform {
    fn drop(&mut self) {
        println!("Dropping Platform");
        #[cfg(target = "windows")]
        unsafe {
            windows::uninit()
        };
    }
}

#[cfg(target = "windows")]
mod windows {
    use anyhow::anyhow;
    use windows::Win32::System::Com::{self, COINIT_MULTITHREADED};

    pub unsafe fn init() -> anyhow::Result<()> {
        Com::CoInitializeEx(None, COINIT_MULTITHREADED)
            .ok()
            .map_err(|e| anyhow!("Failed to initialize COM.").context(e))
    }

    pub unsafe fn uninit() {
        Com::CoUninitialize();
    }
}
