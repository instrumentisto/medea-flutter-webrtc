use std::env;

fn main() {
    println!("cargo:rustc-link-arg=-Wl,-undefined,dynamic_lookup");
    #[cfg(feature = "renderer_c_api")]
        {
            let crate_dir = env::var("CARGO_MANIFEST_DIR").unwrap();

            cbindgen::Builder::new()
                .with_crate(crate_dir)
                .generate()
                .expect("Unable to generate bindings")
                .write_to_file("bindings.h");
        }

    #[cfg(feature = "renderer_cpp_api")]
    cxx_build::bridge("src/renderer/cpp_api.rs").flag("-std=c++17").compile("cpp_api_bindings");
}
