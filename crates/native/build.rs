use std::env;

fn main() {
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
    cxx_build::bridge("src/renderer/cpp_api.rs").compile("cpp_api_bindings");
}
