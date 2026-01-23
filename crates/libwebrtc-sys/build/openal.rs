//! Downloading and compiling [OpenAL] library.
//!
//! [OpenAL]: https://github.com/kcat/openal-soft

use std::{
    env, fs,
    fs::File,
    io::{self, Write as _},
    path::{Path, PathBuf},
    process::Command,
};

use anyhow::bail;
use flate2::read::GzDecoder;
use tar::Archive;

#[cfg(target_os = "macos")]
use crate::MACOS_MIN_VER;
use crate::{copy_dir_all, get_target};

/// URL for downloading `openal-soft` source code.
static OPENAL_URL: &str =
    "https://github.com/kcat/openal-soft/archive/refs/tags/1.25.1";

/// Downloads and builds [OpenAL] dynamic library.
///
/// Copies [OpenAL] headers and moves the compiled library to the required
/// locations.
///
/// [OpenAL]: https://github.com/kcat/openal-soft
pub(super) fn build() -> anyhow::Result<()> {
    let manifest_path = PathBuf::from(env::var("CARGO_MANIFEST_DIR")?);
    let temp_dir = manifest_path.join("temp");
    let openal_path = get_path_to_openal()?;

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

    let openal_src = download(&manifest_path, &temp_dir)?;
    cmake_configure(&openal_src)?;
    cmake_build(&openal_src)?;
    copy_artifacts(&openal_src, &manifest_path, &openal_path)?;

    fs::remove_dir_all(&temp_dir)?;

    Ok(())
}

/// Downloads and unpacks [OpenAL] sources into provided `dest_dir`.
///
/// Returns [`Path`] to the unpacked [OpenAL] source directory.
///
/// [OpenAL]: https://github.com/kcat/openal-soft
fn download(manifest_path: &Path, dest_dir: &Path) -> anyhow::Result<PathBuf> {
    let openal_version = OPENAL_URL.split('/').next_back().unwrap_or_default();

    let archive = dest_dir.join(format!("{openal_version}.tar.gz"));

    if dest_dir.exists() {
        fs::remove_dir_all(dest_dir)?;
    }
    fs::create_dir_all(dest_dir)?;

    {
        let mut resp = reqwest::blocking::get(format!(
            "{OPENAL_URL}/{openal_version}.tar.gz",
        ))?;
        let mut out_file = File::create(&archive)?;

        io::copy(&mut resp, &mut out_file)?;
        out_file.flush()?;
    }

    let mut archive = Archive::new(GzDecoder::new(File::open(archive)?));
    archive.unpack(dest_dir)?;

    let openal_src_path =
        dest_dir.join(format!("openal-soft-{openal_version}"));
    if !openal_src_path.exists() {
        bail!(
            "OpenAL sources weren't unpacked to expected path `{}`",
            openal_src_path.display(),
        );
    }

    // Copy OpenAL headers (needed by `libwebrtc` bindings compilation).
    copy_dir_all(
        openal_src_path.join("include"),
        manifest_path.join("lib").join(get_target()?.as_str()).join("include"),
    )?;

    Ok(openal_src_path)
}

/// Runs [CMake] configure step for [OpenAL] in the provided `src_path`.
///
/// [CMake]: https://cmake.org
/// [OpenAL]: https://github.com/kcat/openal-soft
fn cmake_configure(src_path: &Path) -> anyhow::Result<()> {
    let mut cmake_cmd = Command::new("cmake");
    cmake_cmd.current_dir(src_path).args([
        ".",
        ".",
        "-DCMAKE_BUILD_TYPE=Release",
    ]);
    #[cfg(target_os = "macos")]
    {
        cmake_cmd.arg("-DCMAKE_OSX_ARCHITECTURES=arm64;x86_64");
        cmake_cmd.arg(format!("-DCMAKE_OSX_DEPLOYMENT_TARGET={MACOS_MIN_VER}"));
    }
    #[cfg(target_os = "linux")]
    {
        // TODO: Remove on migrating to newer toolchain.
        //       ld v2.42 and g++ 13.3.0 work fine.
        cmake_cmd.arg("-DHAVE_GCC_PROTECTED_VISIBILITY=OFF");
        cmake_cmd.arg("-DHAVE_GCC_DEFAULT_VISIBILITY=ON");
    }
    let configure_result = cmake_cmd.output()?;
    if !configure_result.status.success() {
        bail!(
            "OpenAL `cmake` configure failed with status `{}` and stderr:\n{}",
            configure_result.status,
            String::from_utf8_lossy(&configure_result.stderr),
        );
    }

    Ok(())
}

/// Runs [CMake] build step for [OpenAL] in the provided `src_path`.
///
/// [CMake]: https://cmake.org
/// [OpenAL]: https://github.com/kcat/openal-soft
fn cmake_build(src_path: &Path) -> anyhow::Result<()> {
    let build_result = Command::new("cmake")
        .current_dir(src_path)
        .args(["--build", ".", "--config", "Release"])
        .output()?;

    if !build_result.status.success() {
        bail!(
            "OpenAL `cmake` build failed with status `{}` and stderr:\n{}",
            build_result.status,
            String::from_utf8_lossy(&build_result.stderr),
        );
    }

    Ok(())
}

/// Copies the built [OpenAL] library artifacts to the [Flutter] project layout.
///
/// [Flutter]: https://www.flutter.dev
/// [OpenAL]: https://github.com/kcat/openal-soft
fn copy_artifacts(
    openal_src_path: &Path,
    manifest_path: &Path,
    openal_path: &Path,
) -> anyhow::Result<()> {
    fs::create_dir_all(openal_path)?;

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
                    .current_dir(openal_src_path)
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
