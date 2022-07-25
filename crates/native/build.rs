#![warn(clippy::pedantic)]

use std::{
    env,
    path::{Path, PathBuf},
};

use walkdir::{DirEntry, WalkDir};

fn main() -> anyhow::Result<()> {
    #[cfg(target_os = "macos")]
    {
        println!("cargo:rustc-link-arg=-Wl,-undefined,dynamic_lookup");

        let path = PathBuf::from(env::var("CARGO_MANIFEST_DIR")?);
        let cpp_files = get_cpp_files()?;

        link_libs();

        let mut build = cc::Build::new();
        build
            .files(&cpp_files)
            .include(path.join("include"))
            .flag("-DNOMINMAX")
            .flag("-objC")
            .flag("-fobjc-arc");
        build.compile("flutter-webrtc-native");
    }

    #[cfg(feature = "renderer_cpp_api")]
    cxx_build::bridge("src/renderer.rs").compile("cpp_api_bindings");

    Ok(())
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

/// Returns a list of all sources that should be compiled.
fn get_cpp_files() -> anyhow::Result<Vec<PathBuf>> {
    let dir = PathBuf::from(env::var("CARGO_MANIFEST_DIR")?)
        .join("src")
        .join("extern");

    #[allow(unused_mut)]
    let mut files = get_files_from_dir(dir);

    #[cfg(not(target_os = "macos"))]
    files.retain(|e| !e.to_str().unwrap().contains(".m"));

    Ok(files)
}

/// Emits all the required `rustc-link-lib` instructions.
#[cfg(target_os = "macos")]
fn link_libs() {
    {
        println!("cargo:rustc-link-lib=framework=AVFoundation");
        if let Some(path) = macos_link_search_path() {
            println!("cargo:rustc-link-lib=clang_rt.osx");
            println!("cargo:rustc-link-search={}", path);
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
            &_ => unreachable!(),
        }
    }
}

/// Links MacOS libraries needed for building.
#[cfg(target_os = "macos")]
fn macos_link_search_path() -> Option<String> {
    let output = std::process::Command::new("clang")
        .arg("--print-search-dirs")
        .output()
        .ok()?;
    if !output.status.success() {
        return None;
    }

    let stdout = String::from_utf8_lossy(&output.stdout);
    stdout
        .lines()
        .filter(|l| l.contains("libraries: ="))
        .find_map(|l| {
            let path = l.split('=').nth(1)?;
            if path.is_empty() {
                None
            } else {
                Some(format!("{}/lib/darwin", path))
            }
        })
}
