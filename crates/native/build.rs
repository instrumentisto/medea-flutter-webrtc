use std::{env, path::PathBuf};

use cbindgen::Config;

fn main() {
    let crate_dir = env::var("CARGO_MANIFEST_DIR").unwrap();
    let target_dir = {
        let mut out_dir = PathBuf::from(env::var("OUT_DIR").unwrap());
        // Pop to the `CARGO_TARGET_DIR`
        for _ in 0..4 {
            assert!(out_dir.pop());
        }

        out_dir.to_str().unwrap().to_owned()
    };
    let package_name = env::var("CARGO_PKG_NAME").unwrap().replace("-", "_");

    let config = Config {
        namespace: Some(package_name.clone()),
        ..cbindgen::Config::default()
    };

    cbindgen::generate_with_config(&crate_dir, config)
        .unwrap()
        .write_to_file(format!("{}/{}.hpp", target_dir, package_name));
}
