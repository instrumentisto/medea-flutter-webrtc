//! Downloading and compiling [OpenAL] library.
//!
//! [OpenAL]: https://github.com/kcat/openal-soft

use std::{
    env, fs,
    fs::File,
    io::{self, Write as _},
    path::PathBuf,
    process::Command,
};

use flate2::read::GzDecoder;
use tar::Archive;

#[cfg(target_os = "macos")]
use crate::MACOS_MIN_VER;
use crate::{copy_dir_all, get_target};

/// URL for downloading `openal-soft` source code.
static OPENAL_URL: &str =
    "https://github.com/kcat/openal-soft/archive/refs/tags/1.24.3";

/// Downloads and compiles [OpenAL] dynamic library.
///
/// Copies [OpenAL] headers and moves the compiled library to the required
/// locations.
///
/// [OpenAL]: https://github.com/kcat/openal-soft
pub(super) fn compile() -> anyhow::Result<()> {
    let openal_version = OPENAL_URL.split('/').next_back().unwrap_or_default();
    let manifest_path = PathBuf::from(env::var("CARGO_MANIFEST_DIR")?);
    let temp_dir = manifest_path.join("temp");
    let openal_path = get_path_to_openal()?;

    let archive = temp_dir.join(format!("{openal_version}.tar.gz"));

    let is_already_installed = fs::metadata(
        manifest_path
            .join("lib")
            .join(get_target()?.as_str())
            .join("include")
            .join("AL"),
    )
    .is_ok();
    let is_install_openal =
        env::var("INSTALL_OPENAL").as_deref().unwrap_or("0") == "0";

    if is_install_openal && is_already_installed {
        return Ok(());
    }

    if temp_dir.exists() {
        fs::remove_dir_all(&temp_dir)?;
    }
    fs::create_dir_all(&temp_dir)?;

    {
        let mut resp = reqwest::blocking::get(format!(
            "{OPENAL_URL}/{openal_version}.tar.gz",
        ))?;
        let mut out_file = File::create(&archive)?;

        io::copy(&mut resp, &mut out_file)?;
        out_file.flush()?;
    }

    let mut archive = Archive::new(GzDecoder::new(File::open(archive)?));
    archive.unpack(&temp_dir)?;

    let openal_src_path =
        temp_dir.join(format!("openal-soft-{openal_version}"));

    copy_dir_all(
        openal_src_path.join("include"),
        manifest_path.join("lib").join(get_target()?.as_str()).join("include"),
    )?;

    let mut cmake_cmd = Command::new("cmake");
    cmake_cmd.current_dir(&openal_src_path).args([
        ".",
        ".",
        "-DCMAKE_BUILD_TYPE=Release",
    ]);
    #[cfg(target_os = "macos")]
    {
        cmake_cmd.arg("-DCMAKE_OSX_ARCHITECTURES=arm64;x86_64");
        cmake_cmd.arg(format!("-DCMAKE_OSX_DEPLOYMENT_TARGET={MACOS_MIN_VER}"));
    }
    drop(cmake_cmd.output()?);

    drop(
        Command::new("cmake")
            .current_dir(&openal_src_path)
            .args(["--build", ".", "--config", "Release"])
            .output()?,
    );

    fs::create_dir_all(&openal_path)?;

    match get_target()?.as_str() {
        "aarch64-apple-darwin" | "x86_64-apple-darwin" => {
            fs::copy(
                openal_src_path.join("libopenal.dylib"),
                openal_path.join("libopenal.1.dylib"),
            )?;
        }
        "x86_64-unknown-linux-gnu" => {
            drop(
                Command::new("strip")
                    .arg("libopenal.so.1")
                    .current_dir(&openal_src_path)
                    .output()?,
            );
            fs::copy(
                openal_src_path.join("libopenal.so.1"),
                openal_path.join("libopenal.so.1"),
            )?;
        }
        "x86_64-pc-windows-msvc" => {
            fs::copy(
                openal_src_path.join("Release").join("OpenAL32.dll"),
                openal_path.join("OpenAL32.dll"),
            )?;
            fs::copy(
                openal_src_path.join("Release").join("OpenAL32.lib"),
                openal_path.join("OpenAL32.lib"),
            )?;
            let path = manifest_path
                .join("lib")
                .join(get_target()?.as_str())
                .join("release")
                .join("OpenAL32.lib");
            fs::copy(
                openal_src_path.join("Release").join("OpenAL32.lib"),
                path,
            )?;
        }
        _ => (),
    }

    fs::remove_dir_all(&temp_dir)?;

    Ok(())
}

/// Returns a [`PathBuf`] to the [OpenAL] dynamic library destination within
/// Flutter files.
///
/// [OpenAL]: https://github.com/kcat/openal-soft
fn get_path_to_openal() -> anyhow::Result<PathBuf> {
    let mut workspace_path = PathBuf::from(env::var("CARGO_MANIFEST_DIR")?);
    workspace_path.pop();
    workspace_path.pop();

    Ok(match get_target()?.as_str() {
        "aarch64-apple-darwin" | "x86_64-apple-darwin" => {
            workspace_path.join("macos").join("rust").join("lib")
        }
        "x86_64-unknown-linux-gnu" => workspace_path
            .join("linux")
            .join("rust")
            .join("lib")
            .join(get_target()?.as_str()),
        "x86_64-pc-windows-msvc" => workspace_path
            .join("windows")
            .join("rust")
            .join("lib")
            .join(get_target()?.as_str()),
        _ => return Err(anyhow::anyhow!("Platform isn't supported")),
    })
}
