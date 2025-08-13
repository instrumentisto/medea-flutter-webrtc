//! Downloading [wil] library.
//!
//! [wil]: https://github.com/instrumentisto/libwebrtc-bin

use std::{
    env, fs,
    fs::File,
    io::{self, BufReader, Write as _},
    path::PathBuf,
};

use flate2::read::GzDecoder;
use tar::Archive;

use crate::{copy_dir_all, get_target};

// TODO: Skip `v1.0.250325.1` cause https://github.com/microsoft/wil/issues/512
//       Wait for https://github.com/microsoft/wil/pull/516 release.
/// URL for downloading [`wil`] third party library.
///
/// [`wil`]: https://github.com/microsoft/wil
static WIL_URL: &str =
    "https://github.com/microsoft/wil/archive/refs/tags/v1.0.240803.1";

/// Download Windows [`wil`] header-only library.
///
/// [`wil`]: https://github.com/microsoft/wil
pub(super) fn download() -> anyhow::Result<()> {
    let wil_version = WIL_URL.split('/').next_back().unwrap_or_default();
    let manifest_path = PathBuf::from(env::var("CARGO_MANIFEST_DIR")?);
    let temp_dir = manifest_path.join("temp");

    let archive = temp_dir.join(format!("{wil_version}.tar.gz"));

    let is_already_installed = fs::metadata(
        manifest_path.join("include").join("third_party").join("wil"),
    )
    .is_ok();
    let is_force_install =
        env::var("INSTALL_WIL").as_deref().unwrap_or("0") == "1";

    if !is_force_install && is_already_installed {
        return Ok(());
    }

    if temp_dir.exists() {
        fs::remove_dir_all(&temp_dir)?;
    }
    fs::create_dir_all(&temp_dir)?;

    {
        let mut resp = BufReader::new(reqwest::blocking::get(format!(
            "{WIL_URL}.tar.gz",
        ))?);
        let mut out_file = File::create(&archive)?;

        io::copy(&mut resp, &mut out_file)?;
        out_file.flush()?;
    }

    let mut archive = Archive::new(GzDecoder::new(File::open(archive)?));
    archive.unpack(&temp_dir)?;

    let unprefixed_version: String = wil_version.chars().skip(1).collect();
    let src_path = temp_dir.join(format!("wil-{unprefixed_version}"));

    copy_dir_all(
        src_path.join("include"),
        manifest_path
            .join("lib")
            .join(get_target()?.as_str())
            .join("include")
            .join("third_party"),
    )?;

    Ok(())
}
