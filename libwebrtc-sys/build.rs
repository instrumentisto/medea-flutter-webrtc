use std::{env, path::PathBuf};

fn main() {
    println!("cargo:rustc-link-search=native=./webrtc/");
    println!("cargo:rustc-link-lib=static=webrtc");
    println!("cargo:rustc-link-lib=dylib=winmm");
    println!("cargo:rustc-link-lib=dylib=secur32");
    println!("cargo:rustc-link-lib=dylib=dmoguids");
    println!("cargo:rustc-link-lib=dylib=wmcodecdspuuid");
    println!("cargo:rustc-link-lib=dylib=amstrmid");
    println!("cargo:rustc-link-lib=dylib=msdmo");
    println!("cargo:rustc-link-lib=dylib=gdi32");
    println!("cargo:rustc-link-lib=dylib=d3d11");
    println!("cargo:rustc-link-lib=dylib=dxgi");
    println!("cargo:rustc-link-lib=dylib=ole32");
    println!("cargo:rustc-link-lib=dylib=oleaut32");
    println!("cargo:rustc-link-lib=dylib=user32");

    let path = PathBuf::from(env::var("CARGO_MANIFEST_DIR").unwrap());

    cxx_build::bridge("src/lib.rs")
        .file("src/bridge.cc")
        .include(path.join("include"))
        .include(path.join("include/third_party/abseil-cpp"))
        .define("WEBRTC_WIN", "1")
        .define("NOMINMAX", "1")
        .define("WEBRTC_USE_BUILTIN_ISAC_FLOAT", "1")
        .compile("libwebrtc-sys");

    println!("cargo:rerun-if-changed=src/lib.rs");
    println!("cargo:rerun-if-changed=src/bridge.cc");
    println!("cargo:rerun-if-changed=webrtc/webrtc.lib");
    println!("cargo:rerun-if-changed=src/bridge.h");
}
