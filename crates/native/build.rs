#![warn(clippy::pedantic)]

fn main() {
    #[cfg(feature = "renderer_cpp_api")]
    cxx_build::bridge("src/renderer/cpp_api.rs").compile("cpp_api_bindings");
}
