//! Downloads, compiles, and links [`libwebrtc-bin`] and [OpenAL] libraries.
//!
//! [`libwebrtc-bin`]: https://github.com/instrumentisto/libwebrtc-bin
//! [OpenAL]: https://github.com/kcat/openal-soft

#![deny(nonstandard_style, rustdoc::all, trivial_casts, trivial_numeric_casts)]
#![forbid(non_ascii_idents)]
#![warn(
    clippy::absolute_paths,
    clippy::allow_attributes,
    clippy::allow_attributes_without_reason,
    clippy::as_conversions,
    clippy::as_pointer_underscore,
    clippy::as_ptr_cast_mut,
    clippy::assertions_on_result_states,
    clippy::branches_sharing_code,
    clippy::cfg_not_test,
    clippy::clear_with_drain,
    clippy::clone_on_ref_ptr,
    clippy::coerce_container_to_any,
    clippy::collection_is_never_read,
    clippy::create_dir,
    clippy::dbg_macro,
    clippy::debug_assert_with_mut_call,
    clippy::decimal_literal_representation,
    clippy::default_union_representation,
    clippy::derive_partial_eq_without_eq,
    clippy::doc_include_without_cfg,
    clippy::empty_drop,
    clippy::empty_structs_with_brackets,
    clippy::equatable_if_let,
    clippy::empty_enum_variants_with_brackets,
    clippy::exit,
    clippy::expect_used,
    clippy::fallible_impl_from,
    clippy::filetype_is_file,
    clippy::float_cmp_const,
    clippy::fn_to_numeric_cast_any,
    clippy::get_unwrap,
    clippy::if_then_some_else_none,
    clippy::imprecise_flops,
    clippy::infinite_loop,
    clippy::iter_on_empty_collections,
    clippy::iter_on_single_items,
    clippy::iter_over_hash_type,
    clippy::iter_with_drain,
    clippy::large_include_file,
    clippy::large_stack_frames,
    clippy::let_underscore_untyped,
    clippy::literal_string_with_formatting_args,
    clippy::lossy_float_literal,
    clippy::map_err_ignore,
    clippy::map_with_unused_argument_over_ranges,
    clippy::mem_forget,
    clippy::missing_assert_message,
    clippy::missing_asserts_for_indexing,
    clippy::missing_const_for_fn,
    clippy::missing_docs_in_private_items,
    clippy::module_name_repetitions,
    clippy::multiple_inherent_impl,
    clippy::multiple_unsafe_ops_per_block,
    clippy::mutex_atomic,
    clippy::mutex_integer,
    clippy::needless_collect,
    clippy::needless_pass_by_ref_mut,
    clippy::needless_raw_strings,
    clippy::non_zero_suggestions,
    clippy::nonstandard_macro_braces,
    clippy::option_if_let_else,
    clippy::or_fun_call,
    clippy::panic_in_result_fn,
    clippy::partial_pub_fields,
    clippy::pathbuf_init_then_push,
    clippy::pedantic,
    clippy::precedence_bits,
    clippy::print_stderr,
    clippy::print_stdout,
    clippy::pub_without_shorthand,
    clippy::rc_buffer,
    clippy::rc_mutex,
    clippy::read_zero_byte_vec,
    clippy::redundant_clone,
    clippy::redundant_test_prefix,
    clippy::redundant_type_annotations,
    clippy::renamed_function_params,
    clippy::ref_patterns,
    clippy::rest_pat_in_fully_bound_structs,
    clippy::return_and_then,
    clippy::same_name_method,
    clippy::semicolon_inside_block,
    clippy::set_contains_or_insert,
    clippy::shadow_unrelated,
    clippy::significant_drop_in_scrutinee,
    clippy::significant_drop_tightening,
    clippy::single_option_map,
    clippy::str_to_string,
    clippy::string_add,
    clippy::string_lit_as_bytes,
    clippy::string_lit_chars_any,
    clippy::string_slice,
    clippy::string_to_string,
    clippy::suboptimal_flops,
    clippy::suspicious_operation_groupings,
    clippy::suspicious_xor_used_as_pow,
    clippy::tests_outside_test_module,
    clippy::todo,
    clippy::too_long_first_doc_paragraph,
    clippy::trailing_empty_array,
    clippy::transmute_undefined_repr,
    clippy::trivial_regex,
    clippy::try_err,
    clippy::undocumented_unsafe_blocks,
    clippy::unimplemented,
    clippy::uninhabited_references,
    clippy::unnecessary_safety_comment,
    clippy::unnecessary_safety_doc,
    clippy::unnecessary_self_imports,
    clippy::unnecessary_struct_initialization,
    clippy::unused_peekable,
    clippy::unused_result_ok,
    clippy::unused_trait_names,
    clippy::unwrap_in_result,
    clippy::unwrap_used,
    clippy::use_debug,
    clippy::use_self,
    clippy::useless_let_if_seq,
    clippy::verbose_file_reads,
    clippy::while_float,
    clippy::wildcard_enum_match_arm,
    ambiguous_negative_literals,
    closure_returning_async_block,
    future_incompatible,
    impl_trait_redundant_captures,
    let_underscore_drop,
    macro_use_extern_crate,
    meta_variable_misuse,
    missing_copy_implementations,
    missing_debug_implementations,
    missing_docs,
    redundant_lifetimes,
    rust_2018_idioms,
    single_use_lifetimes,
    unit_bindings,
    unnameable_types,
    unreachable_pub,
    unstable_features,
    unused,
    variant_size_differences
)]
#![expect(clippy::print_stdout, reason = "build script")]

mod openal;
mod webrtc;
#[cfg(target_os = "windows")]
mod wil;

use std::{
    env, fs,
    path::{Path, PathBuf},
};
#[cfg(not(target_os = "windows"))]
use std::{ffi::OsString, process::Command};

#[cfg(target_os = "linux")]
use anyhow::anyhow;
#[cfg(target_os = "linux")]
use anyhow::bail;
use dotenvy::dotenv;
#[cfg(target_os = "linux")]
use regex_lite::Regex;
use walkdir::{DirEntry, WalkDir};

fn main() -> anyhow::Result<()> {
    drop(dotenv());

    let lib_dir = libpath()?;
    if lib_dir.exists() {
        fs::create_dir_all(&lib_dir)?;
    }
    webrtc::download()?;
    #[cfg(target_os = "windows")]
    wil::download()?;
    openal::compile()?;

    let path = PathBuf::from(env::var("CARGO_MANIFEST_DIR")?);
    let libpath = libpath()?;
    let cpp_files = get_cpp_files()?;

    println!("cargo:rustc-link-lib=webrtc");

    link_libs()?;

    let mut build = cxx_build::bridge("src/bridge.rs");
    build
        .files(&cpp_files)
        .include(path.join("include"))
        .include(libpath.join("include"))
        .include(libpath.join("include/third_party/abseil-cpp"))
        .include(libpath.join("include/third_party/libyuv/include"))
        .flag("-DNOMINMAX");

    #[cfg(target_os = "windows")]
    build.flag("-DNDEBUG");
    #[cfg(not(target_os = "windows"))]
    if env::var_os("PROFILE") == Some(OsString::from("release")) {
        build.flag("-DNDEBUG");
    }

    #[cfg(target_os = "linux")]
    {
        if get_lld_version()?.0 < 19 {
            bail!(
                "Compilation of the `libwebrtc-sys` crate requires `ldd` \
                 version 19 or higher, as the `libwebrtc` library it depends \
                 on is linked using CREL (introduced in version 19)",
            );
        }
        println!("cargo:rustc-link-arg=-fuse-ld=lld");

        // Prefer `clang` over `gcc`, because Chromium uses `clang` and `gcc` is
        // known to have issues, is not guaranteed to run and not tested by
        // bots. See:
        // https://issues.chromium.org/issues/40565911
        // https://chromium.googlesource.com/chromium/src/+/main/docs/clang.md
        build.compiler("clang");
        build
            .flag("-DWEBRTC_LINUX")
            .flag("-DWEBRTC_POSIX")
            .flag("-DWEBRTC_USE_X11")
            .flag("-std=c++17");
    }
    #[cfg(target_os = "macos")]
    {
        println!("cargo:rustc-env=MACOSX_DEPLOYMENT_TARGET=10.15");
        build
            .include(libpath.join("include/sdk/objc/base"))
            .include(libpath.join("include/sdk/objc"));
        build
            .flag("-DWEBRTC_POSIX")
            .flag("-DWEBRTC_MAC")
            .flag("-DWEBRTC_ENABLE_OBJC_SYMBOL_EXPORT")
            .flag("-DWEBRTC_LIBRARY_IMPL")
            .flag("-std=c++17")
            .flag("-objC")
            .flag("-fobjc-arc");
    }
    #[cfg(target_os = "windows")]
    {
        println!("cargo:rustc-link-lib=OpenAL32");
        build.flag("-DWEBRTC_WIN").flag("/std:c++20");
    }

    #[cfg(feature = "fake-media")]
    {
        build.flag("-DFAKE_MEDIA");
    }

    build.compile("libwebrtc-sys");

    for file in cpp_files {
        println!("cargo:rerun-if-changed={}", file.display());
    }
    get_header_files()?.into_iter().for_each(|file| {
        println!("cargo:rerun-if-changed={}", file.display());
    });
    println!("cargo:rerun-if-changed=src/bridge.rs");
    println!("cargo:rerun-if-changed=./lib");
    println!("cargo:rerun-if-env-changed=INSTALL_WEBRTC");
    println!("cargo:rerun-if-env-changed=INSTALL_OPENAL");
    println!("cargo:rerun-if-env-changed=WEBRTC_BRANCH");

    Ok(())
}

#[cfg(target_os = "linux")]
/// Returns version of `ld.lld` binary.
fn get_lld_version() -> anyhow::Result<(u8, u8, u8)> {
    let lld_result = Command::new("ld.lld").arg("--version").output()?;
    let output = String::from_utf8(lld_result.stdout)?;

    Regex::new(r"LLD (\d+)\.(\d+)\.(\d+)")?
        .captures(&output)
        .and_then(|caps| {
            let major = caps.get(1)?.as_str().parse::<u8>().ok()?;
            let minor = caps.get(2)?.as_str().parse::<u8>().ok()?;
            let patch = caps.get(3)?.as_str().parse::<u8>().ok()?;
            Some((major, minor, patch))
        })
        .ok_or_else(|| anyhow!("Failed to parse `lld` version"))
}

/// Returns target architecture to build the library for.
fn get_target() -> anyhow::Result<String> {
    env::var("TARGET").map_err(Into::into)
}

/// Returns [`PathBuf`] to the directory containing the library.
fn libpath() -> anyhow::Result<PathBuf> {
    let target = get_target()?;
    let manifest_path = PathBuf::from(env::var("CARGO_MANIFEST_DIR")?);
    Ok(manifest_path.join("lib").join(target))
}

/// Returns a list of all C++ sources that should be compiled.
fn get_cpp_files() -> anyhow::Result<Vec<PathBuf>> {
    let dir =
        PathBuf::from(env::var("CARGO_MANIFEST_DIR")?).join("src").join("cpp");

    #[cfg_attr(target_os = "macos", expect(unused_mut, reason = "cfg"))]
    let mut files = get_files_from_dir(dir);

    #[cfg(not(target_os = "macos"))]
    files.retain(|e| !e.to_str().is_some_and(|n| n.contains(".mm")));

    Ok(files)
}

/// Returns a list of all header files that should be included.
fn get_header_files() -> anyhow::Result<Vec<PathBuf>> {
    let dir = PathBuf::from(env::var("CARGO_MANIFEST_DIR")?).join("include");

    Ok(get_files_from_dir(dir))
}

/// Performs recursive directory traversal returning all the found files.
fn get_files_from_dir<P: AsRef<Path>>(dir: P) -> Vec<PathBuf> {
    WalkDir::new(dir)
        .into_iter()
        .filter_map(Result::ok)
        .filter(|e| !e.file_type().is_dir())
        .map(DirEntry::into_path)
        .collect()
}

/// Emits all the required `rustc-link-lib` instructions.
fn link_libs() -> anyhow::Result<()> {
    let target = get_target()?;
    #[cfg(target_os = "linux")]
    {
        for dep in
            ["x11", "xfixes", "xdamage", "xext", "xtst", "xrandr", "xcomposite"]
        {
            drop(pkg_config::Config::new().probe(dep)?);
        }
        match env::var("PROFILE").unwrap_or_default().as_str() {
            "debug" => {
                println!(
                    "cargo:rustc-link-search=\
                     native=crates/libwebrtc-sys/lib/{target}/debug/",
                );
            }
            "release" => {
                println!(
                    "cargo:rustc-link-search=\
                     native=crates/libwebrtc-sys/lib/{target}/release/",
                );
            }
            _ => unreachable!("`PROFILE` env var is corrupted or wrong"),
        }
    }
    #[cfg(target_os = "macos")]
    {
        for framework in [
            "AudioUnit",
            "CoreServices",
            "CoreFoundation",
            "AudioToolbox",
            "CoreGraphics",
            "CoreAudio",
            "IOSurface",
            "ApplicationServices",
            "Foundation",
            "AVFoundation",
            "AppKit",
            "System",
        ] {
            println!("cargo:rustc-link-lib=framework={framework}");
        }
        if let Some(path) = macos_link_search_path() {
            println!("cargo:rustc-link-lib=clang_rt.osx");
            println!("cargo:rustc-link-search={path}");
        }
        match env::var("PROFILE").unwrap_or_default().as_str() {
            "debug" => {
                println!(
                    "cargo:rustc-link-search=\
                     native=crates/libwebrtc-sys/lib/{target}/debug/",
                );
            }
            "release" => {
                println!(
                    "cargo:rustc-link-search=\
                     native=crates/libwebrtc-sys/lib/{target}/release/",
                );
            }
            _ => unreachable!("`PROFILE` env var is corrupted or wrong"),
        }
    }
    #[cfg(target_os = "windows")]
    {
        for dep in [
            "Dwmapi",
            "Gdi32",
            "Mmdevapi",
            "Secur32",
            "amstrmid",
            "d3d11",
            "dmoguids",
            "dxgi",
            "msdmo",
            "winmm",
            "wmcodecdspuuid",
        ] {
            println!("cargo:rustc-link-lib=dylib={dep}");
        }
        // TODO: `rustc` always links against non-debug Windows runtime, so we
        //       always use a release build of `libwebrtc`:
        //       https://github.com/rust-lang/rust/issues/39016
        println!(
            "cargo:rustc-link-search=\
             native=crates/libwebrtc-sys/lib/{target}/release/",
        );
    }
    Ok(())
}

#[cfg(target_os = "macos")]
/// Links macOS libraries needed for building.
fn macos_link_search_path() -> Option<String> {
    let output =
        Command::new("clang").arg("--print-search-dirs").output().ok()?;
    if !output.status.success() {
        return None;
    }

    let stdout = String::from_utf8_lossy(&output.stdout);
    stdout.lines().filter(|l| l.contains("libraries: =")).find_map(|l| {
        let path = l.split('=').nth(1)?;
        (!path.is_empty()).then(|| format!("{path}/lib/darwin"))
    })
}

/// Recursively copies `src` directory to the provided `dst` [`Path`].
fn copy_dir_all(
    src: impl AsRef<Path>,
    dst: impl AsRef<Path>,
) -> anyhow::Result<()> {
    fs::create_dir_all(&dst)?;
    for entry in fs::read_dir(src)? {
        let entry = entry?;
        let ty = entry.file_type()?;
        if ty.is_dir() {
            copy_dir_all(entry.path(), dst.as_ref().join(entry.file_name()))?;
        } else {
            fs::copy(entry.path(), dst.as_ref().join(entry.file_name()))?;
        }
    }
    Ok(())
}
