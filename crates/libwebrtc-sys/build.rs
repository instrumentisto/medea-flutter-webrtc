#![warn(clippy::pedantic)]

use std::{
    env, fs, io,
    path::{Path, PathBuf},
    process,
};

use anyhow::anyhow;
use dotenv::dotenv;
use walkdir::{DirEntry, WalkDir};

fn main() -> anyhow::Result<()> {
    // This won't override any env vars that already present.
    drop(dotenv());

    download_libwebrtc()?;

    let path = PathBuf::from(env::var("CARGO_MANIFEST_DIR")?);
    let cpp_files = get_cpp_files()?;

    println!("cargo:rustc-link-lib=webrtc");

    link_libs();

    let mut build = cxx_build::bridge("src/bridge.rs");
    build
        .files(&cpp_files)
        .include(path.join("include"))
        .include(path.join("lib/include"))
        .include(path.join("lib/include/third_party/abseil-cpp"))
        .include(path.join("lib/include/third_party/libyuv/include"));

    #[cfg(target_os = "windows")]
    build.flag("-DNDEBUG");

    #[cfg(not(target_os = "windows"))]
    if env::var("PROFILE").unwrap().as_str() == "release" {
        build.flag("-DNDEBUG");
    }

    #[cfg(target_os = "windows")]
    {
        build
            .flag("-DWEBRTC_WIN")
            .flag("-DNOMINMAX")
            .flag("/std:c++17");
    }
    #[cfg(target_os = "linux")]
    {
        build
            .flag("-DWEBRTC_LINUX")
            .flag("-DWEBRTC_POSIX")
            .flag("-DNOMINMAX")
            .flag("-DWEBRTC_USE_X11")
            .flag("-std=c++17");
    }
    #[cfg(feature = "fake_media")]
    {
        build.flag("-DFAKE_MEDIA");
    }

    build.compile("libwebrtc-sys");

    for file in cpp_files {
        println!("cargo:rerun-if-changed={}", file.display());
    }
    get_header_files()?.into_iter().for_each(|file| {
        println!("cargo:rerun-if-changed={}", file.display());
    });
    println!("cargo:rerun-if-changed=src/bridge.rs");
    println!("cargo:rerun-if-changed=./lib");
    println!("cargo:rerun-if-env-changed=INSTALL_WEBRTC");
    println!("cargo:rerun-if-env-changed=LIBWEBRTC_URL");

    Ok(())
}

/// Downloads and unpacks compiled `libwebrtc` library.
fn download_libwebrtc() -> anyhow::Result<()> {
    let mut libwebrtc_url = env::var("LIBWEBRTC_URL")?;
    libwebrtc_url.push('/');
    let manifest_path = PathBuf::from(env::var("CARGO_MANIFEST_DIR")?);
    let temp_dir = manifest_path.join("temp");
    let lib_dir = manifest_path.join("lib");

    let archive_name = {
        let mut archive_name = String::from("libwebrtc-");
        #[cfg(target_os = "windows")]
        archive_name.push_str("win-");
        #[cfg(target_os = "linux")]
        archive_name.push_str("linux-");
        #[cfg(target_os = "macos")]
        archive_name.push_str("macos-");

        #[cfg(target_arch = "aarch64")]
        archive_name.push_str("arm64.tar.gz");
        #[cfg(target_arch = "x86_64")]
        archive_name.push_str("x64.tar.gz");

        archive_name
    };

    libwebrtc_url.push_str(archive_name.as_str());
    let archive = temp_dir.join(archive_name);

    // Force download if `INSTALL_WEBRTC=1`.
    if env::var("INSTALL_WEBRTC").as_deref().unwrap_or("0") == "0" {
        // Skip download if already downloaded.
        if fs::read_dir(&lib_dir)?.fold(0, |acc, b| {
            if b.unwrap().file_name().to_string_lossy().starts_with('.') {
                acc
            } else {
                acc + 1
            }
        }) != 0
        {
            return Ok(());
        }
    }

    // Clear `temp` directory.
    if temp_dir.exists() {
        fs::remove_dir_all(&temp_dir)?;
    }
    fs::create_dir_all(&temp_dir)?;

    // Download compiled `libwebrtc` archive.
    {
        let mut resp = reqwest::blocking::get(&libwebrtc_url)?;
        let mut out_file = fs::File::create(&archive)?;
        io::copy(&mut resp, &mut out_file)?;
    }

    // Clear `lib` directory.
    for entry in fs::read_dir(&lib_dir)? {
        let entry = entry?;
        if !entry.file_name().to_string_lossy().starts_with('.') {
            if entry.metadata()?.is_dir() {
                fs::remove_dir_all(entry.path())?;
            } else {
                fs::remove_file(entry.path())?;
            }
        }
    }

    // Untar the downloaded archive.
    process::Command::new("tar")
        .args(&[
            "-xf",
            archive
                .to_str()
                .ok_or_else(|| anyhow!("Invalid archive path"))?,
            "-C",
            lib_dir
                .to_str()
                .ok_or_else(|| anyhow!("Invalid `lib/` dir path"))?,
        ])
        .status()?;

    fs::remove_dir_all(&temp_dir)?;

    Ok(())
}

/// Returns a list of all C++ sources that should be compiled.
fn get_cpp_files() -> anyhow::Result<Vec<PathBuf>> {
    let dir = PathBuf::from(env::var("CARGO_MANIFEST_DIR")?)
        .join("src")
        .join("cpp");

    Ok(get_files_from_dir(dir))
}

/// Returns a list of all header files that should be included.
fn get_header_files() -> anyhow::Result<Vec<PathBuf>> {
    let dir = PathBuf::from(env::var("CARGO_MANIFEST_DIR")?).join("include");

    Ok(get_files_from_dir(dir))
}

/// Performs recursive directory traversal returning all the found files.
fn get_files_from_dir<P: AsRef<Path>>(dir: P) -> Vec<PathBuf> {
    WalkDir::new(dir)
        .into_iter()
        .filter_map(Result::ok)
        .filter(|e| e.file_type().is_file())
        .map(DirEntry::into_path)
        .collect()
}

/// Emits all the required `rustc-link-lib` instructions.
fn link_libs() {
    #[cfg(target_os = "windows")]
    {
        for dep in [
            "Gdi32",
            "Secur32",
            "amstrmid",
            "d3d11",
            "dmoguids",
            "dxgi",
            "msdmo",
            "winmm",
            "wmcodecdspuuid",
        ] {
            println!("cargo:rustc-link-lib=dylib={dep}");
        }
        // TODO: `rustc` always links against non-debug Windows runtime, so we
        //       always use a release build of `libwebrtc`:
        //       https://github.com/rust-lang/rust/issues/39016
        println!(
            "cargo:rustc-link-search=native=crates/libwebrtc-sys/lib/release/",
        );
    }
    #[cfg(target_os = "linux")]
    {
        for dep in [
            "x11",
            "xfixes",
            "xdamage",
            "xext",
            "xtst",
            "xrandr",
            "xcomposite ",
        ] {
            pkg_config::Config::new().probe(dep).unwrap();
        }
        match env::var("PROFILE").unwrap().as_str() {
            "debug" => {
                println!(
                    "cargo:rustc-link-search=\
                     native=crates/libwebrtc-sys/lib/debug/",
                );
            }
            "release" => {
                println!(
                    "cargo:rustc-link-search=\
                     native=crates/libwebrtc-sys/lib/release/",
                );
            }
            _ => (),
        }
    }
}
