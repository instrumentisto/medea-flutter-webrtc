#![warn(clippy::pedantic)]

fn main() {
    // println!("cargo:rustc-link-arg=dynamic_lookup");
    println!("cargo:rustc-link-arg=-Wl,-undefined,dynamic_lookup");
    // println!("cargo:rustc-link-arg=undefined");
    #[cfg(feature = "renderer_cpp_api")]
    cxx_build::bridge("src/renderer/cpp_api.rs").flag("-std=c++17").compile("cpp_api_bindings");
}
