use std::{env, fs, io, path::PathBuf};

use dotenv::dotenv;

fn main() {
    // This won't override any env vars that already present.
    let _ = dotenv();
    download_libwebrtc();

    let path = PathBuf::from(env::var("CARGO_MANIFEST_DIR").unwrap());

    // TODO: `rustc` always links against non-debug Windows runtime, so we
    //       always use a release build of `libwebrtc`:
    //       https://github.com/rust-lang/rust/issues/39016
    println!(
        "cargo:rustc-link-search=native=crates/libwebrtc-sys/lib/release/"
    );
    println!("cargo:rustc-link-lib=webrtc");
    println!("cargo:rustc-link-lib=dylib=winmm");
    println!("cargo:rustc-link-lib=dylib=secur32");
    println!("cargo:rustc-link-lib=dylib=dmoguids");
    println!("cargo:rustc-link-lib=dylib=wmcodecdspuuid");
    println!("cargo:rustc-link-lib=dylib=amstrmid");
    println!("cargo:rustc-link-lib=dylib=msdmo");
    println!("cargo:rustc-link-lib=dylib=gdi32");
    println!("cargo:rustc-link-lib=dylib=d3d11");
    println!("cargo:rustc-link-lib=dylib=dxgi");

    cxx_build::bridge("src/bridge.rs")
        .file("src/bridge.cc")
        .include(path.join("lib/include"))
        .include(path.join("lib/include/third_party/abseil-cpp"))
        .define("WEBRTC_WIN", "1")
        .define("NOMINMAX", "1")
        .define("WEBRTC_USE_BUILTIN_ISAC_FLOAT", "1")
        .compile("libwebrtc-sys");

    println!("cargo:rerun-if-changed=src/bridge.cc");
    println!("cargo:rerun-if-changed=src/bridge.rs");
    println!("cargo:rerun-if-changed=include/bridge.h");
    println!("cargo:rerun-if-changed=./lib");
}

/// Downloads and unpacks compiled `libwebrtc` library.
fn download_libwebrtc() {
    let mut libwebrtc_url = env::var("LIBWEBRTC_URL")
        .expect("`LIBWEBRTC_URL` env var should be present");
    libwebrtc_url.push_str("/libwebrtc-win-x64.tar.gz");
    let manifest_path = PathBuf::from(env::var("CARGO_MANIFEST_DIR").unwrap());
    let temp_dir = manifest_path.join("temp");
    let archive = temp_dir.join("libwebrtc-win-x64.tar.gz");
    let lib_dir = manifest_path.join("lib");

    // Clear `temp` directory.
    if temp_dir.exists() {
        fs::remove_dir_all(&temp_dir).unwrap();
    }
    fs::create_dir(&temp_dir).unwrap();

    // Download compiled `libwebrtc` archive.
    {
        let mut resp = reqwest::blocking::get(&libwebrtc_url).unwrap();
        let mut out_file = fs::File::create(&archive).unwrap();
        io::copy(&mut resp, &mut out_file).unwrap();
    }

    // Clear `lib` directory.
    fs::read_dir(&lib_dir)
        .unwrap()
        .map(Result::unwrap)
        .filter(|entry| {
            // Skip hidden files.
            !entry.file_name().to_str().unwrap().starts_with('.')
        })
        .for_each(|entry| {
            if entry.metadata().unwrap().is_dir() {
                fs::remove_dir_all(entry.path()).unwrap();
            } else {
                fs::remove_file(entry.path()).unwrap();
            }
        });

    // Untar the downloaded archive.
    std::process::Command::new("tar")
        .args(&[
            "-xf",
            archive.to_str().unwrap(),
            "-C",
            lib_dir.to_str().unwrap(),
        ])
        .status()
        .unwrap();

    fs::remove_dir_all(&temp_dir).unwrap();
}
