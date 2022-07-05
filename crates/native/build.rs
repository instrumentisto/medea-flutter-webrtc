#![warn(clippy::pedantic)]

fn main() {
    #[cfg(target_os = "macos")]
    {
        println!("cargo:rustc-link-arg=-Wl,-undefined,dynamic_lookup");
    }

    #[cfg(feature = "renderer_cpp_api")]
    cxx_build::bridge("src/renderer.rs").compile("cpp_api_bindings");
}
