#![warn(clippy::pedantic)]

fn main() {
    cxx_build::bridge("src/cpp_api.rs").flag("-std=c++17").compile("cpp_api_bindings");
}
