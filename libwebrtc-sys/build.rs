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

    let path = PathBuf::from(env::var("CARGO_MANIFEST_DIR").unwrap());

    cxx_build::bridge("src/lib.rs")
        .file("src/bridge.cc")
        .include(path.join("include"))
        .include(path.join("include/third_party/abseil-cpp"))
        .include(path.join("include/third_party/googletest/src/googletest/include"))
        .include(path.join("include/third_party/googletest/src/googlemock/include"))
        .define("WEBRTC_WIN", None)
        .define("NOMINMAX", None)
        .define("WEBRTC_USE_BUILTIN_ISAC_FLOAT", None)
        .compile("libwebrtc-sys");

    println!("cargo:rerun-if-changed=src/lib.rs.rs");
    println!("cargo:rerun-if-changed=src/bridge.cc");
    println!("cargo:rerun-if-changed=../libwebrtc/libwebrtc.cc");
    println!("cargo:rerun-if-changed=../libwebrtc/libwebrtc.lib");
    println!("cargo:rerun-if-changed=src/bridge.h");
}
