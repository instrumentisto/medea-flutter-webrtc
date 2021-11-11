use cbindgen::Config;
use std::env;

fn main() {
    let crate_dir = env::var("CARGO_MANIFEST_DIR").unwrap();
    let package_name = env::var("CARGO_PKG_NAME").unwrap();

    let config = Config {
        namespace: Some(String::from("flutter_webrtc_native")),
        ..cbindgen::Config::default()
    };

    cbindgen::generate_with_config(&crate_dir, config)
        .unwrap()
        .write_to_file(format!(
            "target/{}.hpp",
            package_name.replace("-", "_")
        ));
}
