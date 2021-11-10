use cbindgen::Config;
use std::{env, path::PathBuf};

fn main() {
    let crate_dir = env::var("CARGO_MANIFEST_DIR").unwrap();

    let package_name = env::var("CARGO_PKG_NAME").unwrap();
    let output_file = PathBuf::from("../windows/rust/include")
        .join(format!("{}.hpp", package_name))
        .display()
        .to_string();

    let config = Config {
        namespace: Some(String::from("jason_flutter_webrtc")),
        ..cbindgen::Config::default()
    };

    cbindgen::generate_with_config(&crate_dir, config)
        .unwrap()
        .write_to_file(&output_file);

    println!("cargo:rerun-if-changed=../libwebrtc-sys/src/lib.rs");
    println!("cargo:rerun-if-changed=../libwebrtc-sys/src/bridge.cc");
    println!("cargo:rerun-if-changed=../libwebrtc-sys/webrtc/webrtc.lib");
    println!("cargo:rerun-if-changed=../libwebrtc-sys/src/bridge.h");
}
