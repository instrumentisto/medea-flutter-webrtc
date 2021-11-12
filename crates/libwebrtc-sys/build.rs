use std::{env, path::PathBuf};

fn main() {
    let path = PathBuf::from(env::var("CARGO_MANIFEST_DIR").unwrap());

    // TODO: rustc always links against non-debug Windows runtime, so we always
    //       use release build of libwebrtc.
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
