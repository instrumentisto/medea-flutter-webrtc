use std::env;

use cbindgen::Config;

fn main() {
    let crate_dir = env::var("CARGO_MANIFEST_DIR").unwrap();
    let target_dir = env::var("CARGO_TARGET_DIR").unwrap();
    let package_name = env::var("CARGO_PKG_NAME").unwrap().replace("-", "_");

    let config = Config {
        namespace: Some(package_name.clone()),
        ..cbindgen::Config::default()
    };

    cbindgen::generate_with_config(&crate_dir, config)
        .unwrap()
        .write_to_file(format!("{}/{}.hpp", target_dir, package_name));
}
