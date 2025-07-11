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

#[cfg(not(target_os = "windows"))]
use std::ffi::OsString;
#[cfg(target_os = "macos")]
use std::process;
use std::{
    borrow::Cow,
    env, fs,
    fs::File,
    io::{BufReader, BufWriter, Read as _, Write as _},
    path::{Path, PathBuf},
    process::Command,
};

use anyhow::Context as _;
#[cfg(target_os = "linux")]
use anyhow::anyhow;
#[cfg(target_os = "linux")]
use anyhow::bail;
use flate2::read::GzDecoder;
#[cfg(target_os = "linux")]
use regex_lite::Regex;
use serde::Deserialize;
use sha2::{Digest as _, Sha256};
use tar::Archive;
use walkdir::{DirEntry, WalkDir};
use zip::ZipArchive;

/// Base URL for the [`libwebrtc-bin`] GitHub.
///
/// [`libwebrtc-bin`]: https://github.com/instrumentisto/libwebrtc-bin
static LIBWEBRTC_URL: &str = "https://github.com/instrumentisto/libwebrtc-bin";

/// Release tag for downloading the [`libwebrtc-bin`].
///
/// [`libwebrtc-bin`]: https://github.com/instrumentisto/libwebrtc-bin
static LIBWEBRTC_RELEASE: &str = "138.0.7204.92";

/// Base URL for the [`libwebrtc-bin`] GitHub API.
///
/// [`libwebrtc-bin`]: https://github.com/instrumentisto/libwebrtc-bin
static GITHUB_API_URL: &str =
    "https://api.github.com/repos/instrumentisto/libwebrtc-bin";

/// URL for downloading `openal-soft` source code.
static OPENAL_URL: &str =
    "https://github.com/kcat/openal-soft/archive/refs/tags/1.24.3";

fn main() -> anyhow::Result<()> {
    let lib_dir = libpath()?;
    if lib_dir.exists() {
        fs::create_dir_all(&lib_dir)?;
    }
    download_libwebrtc()?;
    compile_openal()?;

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
    println!("cargo:rerun-if-env-changed=WEBRTC_BRANCH");
    println!("cargo:rerun-if-env-changed=INSTALL_OPENAL");

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

/// Returns a [`PathBuf`] to the [OpenAL] dynamic library destination within
/// Flutter files.
///
/// [OpenAL]: https://github.com/kcat/openal-soft
fn get_path_to_openal() -> anyhow::Result<PathBuf> {
    let mut workspace_path = PathBuf::from(env::var("CARGO_MANIFEST_DIR")?);
    workspace_path.pop();
    workspace_path.pop();

    Ok(match get_target()?.as_str() {
        "aarch64-apple-darwin" | "x86_64-apple-darwin" => {
            workspace_path.join("macos").join("rust").join("lib")
        }
        "x86_64-unknown-linux-gnu" => workspace_path
            .join("linux")
            .join("rust")
            .join("lib")
            .join(get_target()?.as_str()),
        "x86_64-pc-windows-msvc" => workspace_path
            .join("windows")
            .join("rust")
            .join("lib")
            .join(get_target()?.as_str()),
        _ => return Err(anyhow::anyhow!("Platform isn't supported")),
    })
}

/// Downloads and compiles [OpenAL] dynamic library.
///
/// Copies [OpenAL] headers and compiled library to the required locations.
///
/// [OpenAL]: https://github.com/kcat/openal-soft
#[expect(clippy::too_many_lines, reason = "not matters here")]
fn compile_openal() -> anyhow::Result<()> {
    let openal_version = OPENAL_URL.split('/').next_back().unwrap_or_default();
    let manifest_path = PathBuf::from(env::var("CARGO_MANIFEST_DIR")?);
    let temp_dir = manifest_path.join("temp");
    let openal_path = get_path_to_openal()?;

    let archive = temp_dir.join(format!("{openal_version}.tar.gz"));

    let is_already_installed = fs::metadata(
        manifest_path
            .join("lib")
            .join(get_target()?.as_str())
            .join("include")
            .join("AL"),
    )
    .is_ok();
    let is_install_openal =
        env::var("INSTALL_OPENAL").as_deref().unwrap_or("0") == "0";

    if is_install_openal && is_already_installed {
        return Ok(());
    }

    if temp_dir.exists() {
        fs::remove_dir_all(&temp_dir)?;
    }
    fs::create_dir_all(&temp_dir)?;

    {
        let mut resp = BufReader::new(reqwest::blocking::get(format!(
            "{OPENAL_URL}/{openal_version}.tar.gz",
        ))?);
        let mut out_file = BufWriter::new(File::create(&archive)?);

        let mut buffer = [0; 512];
        loop {
            let count = resp.read(&mut buffer)?;
            if count == 0 {
                break;
            }
            _ = out_file.write(&buffer[0..count])?;
        }
    }

    let mut archive = Archive::new(GzDecoder::new(File::open(archive)?));
    archive.unpack(&temp_dir)?;

    let openal_src_path =
        temp_dir.join(format!("openal-soft-{openal_version}"));

    copy_dir_all(
        openal_src_path.join("include"),
        manifest_path.join("lib").join(get_target()?.as_str()).join("include"),
    )?;

    let mut cmake_cmd = Command::new("cmake");
    cmake_cmd.current_dir(&openal_src_path).args([
        ".",
        ".",
        "-DCMAKE_BUILD_TYPE=Release",
    ]);
    #[cfg(target_os = "macos")]
    cmake_cmd.arg("-DCMAKE_OSX_ARCHITECTURES=arm64;x86_64");
    drop(cmake_cmd.output()?);

    drop(
        Command::new("cmake")
            .current_dir(&openal_src_path)
            .args(["--build", ".", "--config", "Release"])
            .output()?,
    );

    fs::create_dir_all(&openal_path)?;

    match get_target()?.as_str() {
        "aarch64-apple-darwin" | "x86_64-apple-darwin" => {
            fs::copy(
                openal_src_path.join("libopenal.dylib"),
                openal_path.join("libopenal.1.dylib"),
            )?;
        }
        "x86_64-unknown-linux-gnu" => {
            drop(
                Command::new("strip")
                    .arg("libopenal.so.1")
                    .current_dir(&openal_src_path)
                    .output()?,
            );
            fs::copy(
                openal_src_path.join("libopenal.so.1"),
                openal_path.join("libopenal.so.1"),
            )?;
        }
        "x86_64-pc-windows-msvc" => {
            fs::copy(
                openal_src_path.join("Release").join("OpenAL32.dll"),
                openal_path.join("OpenAL32.dll"),
            )?;
            fs::copy(
                openal_src_path.join("Release").join("OpenAL32.lib"),
                openal_path.join("OpenAL32.lib"),
            )?;
            let path = manifest_path
                .join("lib")
                .join(get_target()?.as_str())
                .join("release")
                .join("OpenAL32.lib");
            fs::copy(
                openal_src_path.join("Release").join("OpenAL32.lib"),
                path,
            )?;
        }
        _ => (),
    }

    fs::remove_dir_all(&temp_dir)?;

    Ok(())
}

/// Downloads and unpacks compiled `libwebrtc` library.
fn download_libwebrtc() -> anyhow::Result<()> {
    let repository = WebrtcRepository::build()?;
    let artifact = repository.artifact()?;

    let lib_dir = libpath()?;

    if let Some(artifact) =
        artifact.download(&lib_dir, lib_dir.join("CHECKSUM"))?
    {
        artifact.unpack(&lib_dir)?;
    }

    Ok(())
}

/// Downloaded artifact.
struct DownloadedArtifact {
    /// Inner artifact.
    artifact: Artifact,
    /// Path to the archive.
    path: PathBuf,
    /// Path to temp directory where downloaded archive is stored.
    temp_dir: PathBuf,
    /// Path to checksum of the archive.
    checksum: PathBuf,
}

impl DownloadedArtifact {
    /// Unpack the downloaded `libwebrtc` archive.
    fn unpack(&self, destination: &PathBuf) -> anyhow::Result<()> {
        Archive::new(GzDecoder::new(File::open(&self.path)?))
            .unpack(destination)?;

        // Clean up the downloaded `libwebrtc` archive.
        fs::remove_dir_all(&self.temp_dir)?;

        // Write checksum of the unpacked archive.
        fs::write(&self.checksum, self.artifact.digest.as_bytes())?;

        Ok(())
    }
}

/// Build artifact from release or workflow run.
struct Artifact {
    /// Name of the artifact
    name: String,
    /// Hash of archive's content.
    digest: Cow<'static, str>,
    /// Url for downloading the archive. It expires in 1 minute.
    download_url: String,
    /// Is artifact wrapped in another archive.
    is_wrapped: bool,
}

impl Artifact {
    /// Download the `libwebrtc` archive.
    fn download(
        self,
        lib_dir: &PathBuf,
        checksum: PathBuf,
    ) -> anyhow::Result<Option<DownloadedArtifact>> {
        let manifest_path = PathBuf::from(env::var("CARGO_MANIFEST_DIR")?);
        let temp_dir = manifest_path.join("temp");
        let archive = temp_dir.join(&self.name);

        // Force download if `INSTALL_WEBRTC=1`.
        if env::var("INSTALL_WEBRTC").as_deref().unwrap_or("0") == "0" {
            // Skip download if already downloaded and checksum matches.
            if fs::metadata(lib_dir).is_ok_and(|m| m.is_dir())
                && fs::read(&checksum).unwrap_or_default().as_slice()
                    == self.digest.as_bytes()
            {
                return Ok(None);
            }
        }

        // Clean up `temp` directory.
        if temp_dir.exists() {
            fs::remove_dir_all(&temp_dir)?;
        }
        fs::create_dir_all(&temp_dir)?;

        {
            let mut resp =
                BufReader::new(reqwest::blocking::get(&self.download_url)?);
            let mut out_file = BufWriter::new(File::create(&archive)?);
            let mut hasher = Sha256::new();

            let mut buffer = [0; 512];
            loop {
                let count = resp.read(&mut buffer)?;
                if count == 0 {
                    break;
                }
                hasher.update(&buffer[0..count]);
                _ = out_file.write(&buffer[0..count])?;
            }
        }

        if self.is_wrapped {
            ZipArchive::new(File::open(&archive)?)?.extract(&temp_dir)?;
        }

        Ok(Some(DownloadedArtifact {
            path: temp_dir.join(Self::archive_name()?),
            temp_dir,
            checksum,
            artifact: self,
        }))
    }

    /// Get name of the libwebrtc archive.
    fn archive_name() -> anyhow::Result<String> {
        let mut name = String::from("libwebrtc-");

        #[cfg(target_os = "windows")]
        name.push_str("windows-x64");
        #[cfg(target_os = "linux")]
        name.push_str("linux-x64");

        match get_target()?.as_str() {
            "aarch64-apple-darwin" => {
                name.push_str("macos-arm64");
            }
            "x86_64-apple-darwin" => {
                name.push_str("macos-x64");
            }
            _ => (),
        }

        name.push_str(".tar.gz");

        Ok(name)
    }
}

/// Representation of an artifact from GitHub API.
#[derive(Deserialize)]
struct ArtifactMetadata {
    /// Hash of artifact's archive content.
    digest: Cow<'static, str>,
    /// Url to REST API for getting artifact's download link.
    archive_download_url: String,
}

/// Response from list artifacts [endpoint][1] of GitHub API.
///
/// [1]: https://docs.github.com/en/rest/actions/artifacts
#[derive(Deserialize)]
struct ArtifactsResponse {
    /// List of artifacts metadata.
    artifacts: Vec<ArtifactMetadata>,
}

/// Representation of a workflow run from GitHub API.
#[derive(Deserialize)]
struct WorkflowRun {
    /// Url of REST API for getting list of artifacts.
    artifacts_url: String,
}

/// Response from list workflow runs [endpoint][1] of GitHub API.
///
/// [1]: https://docs.github.com/en/rest/actions/workflow-runs
#[derive(Deserialize)]
struct WorkflowRunsResponse {
    /// List of workflow runs.
    workflow_runs: Vec<WorkflowRun>,
}

/// Representation of GitHub repository with build artifacts.
enum WebrtcRepository {
    /// Release representation.
    Release,
    /// Branch representation.
    Branch {
        /// Name of the branch.
        name: String,
        /// GitHub token to download the archive.
        github_token: String,
    },
}

impl WebrtcRepository {
    /// Create a new `libwebrtc` GitHub repository representation.
    fn build() -> anyhow::Result<Self> {
        if let Ok(branch) = env::var("WEBRTC_BRANCH") {
            return Ok(Self::Branch {
                name: branch,
                github_token: env::var("GH_TOKEN").context(
                    "libwebrtc branch was selected but GH_TOKEN isn't set.",
                )?,
            });
        }

        Ok(Self::Release)
    }

    /// Get an artifact from the repository.
    fn artifact(&self) -> anyhow::Result<Artifact> {
        match self {
            Self::Release => {
                let name = Artifact::archive_name()?;
                let download_url = format!(
                    "{LIBWEBRTC_URL}/releases/download\
                                    /{LIBWEBRTC_RELEASE}/{name}",
                );

                Ok(Artifact {
                    download_url,
                    name,
                    digest: get_expected_libwebrtc_hash()?.into(),
                    is_wrapped: false,
                })
            }
            Self::Branch { name, github_token } => {
                let client = Self::client(github_token)?;

                let workflow_run = Self::workflow_run(&client, name.as_str())?;
                let metadata = Self::artifact_metadata(&client, &workflow_run)?;

                let response = client
                    .get(metadata.archive_download_url)
                    .query(&[("archive_format", "zip")])
                    .send()?;

                let mut artifact_name = Self::artifact_name()?.to_owned();
                artifact_name.push_str(".zip");

                Ok(Artifact {
                    name: artifact_name,
                    digest: metadata
                        .digest
                        .split(':')
                        .next_back()
                        .ok_or_else(|| {
                            anyhow::anyhow!(
                                "Got invalid artifact digest from Github API."
                            )
                        })?
                        .to_owned()
                        .into(),
                    download_url: response
                        .headers()
                        .get("Location")
                        .ok_or_else(|| {
                            anyhow::anyhow!(
                                "Got invalid Location from Github API."
                            )
                        })?
                        .to_str()?
                        .into(),
                    is_wrapped: true,
                })
            }
        }
    }

    /// Set up HTTP client.
    fn client(github_token: &str) -> anyhow::Result<reqwest::blocking::Client> {
        let mut headers = reqwest::header::HeaderMap::new();
        headers.insert(reqwest::header::USER_AGENT, "instrumentisto".parse()?);
        headers.insert(
            reqwest::header::AUTHORIZATION,
            format!("Bearer {github_token}").parse()?,
        );

        Ok(reqwest::blocking::Client::builder()
            .default_headers(headers)
            .redirect(reqwest::redirect::Policy::none())
            .build()?)
    }

    /// Get latest workflow run from branch of the `libwebrtc` repository.
    fn workflow_run(
        client: &reqwest::blocking::Client,
        branch: &str,
    ) -> anyhow::Result<WorkflowRun> {
        let response = client
            .get(format!("{GITHUB_API_URL}/actions/runs"))
            .query(&[
                ("branch", branch),
                ("per_page", "1"),
                ("status", "success"),
            ])
            .send()?;

        let mut response: WorkflowRunsResponse = response.json()?;

        response.workflow_runs.pop().ok_or_else(|| anyhow::anyhow!(
            "No successful workflow runs found for selected libwebrtc branch."
        ))
    }

    /// Get libwebrtc build artifact from wokflow run.
    fn artifact_metadata(
        client: &reqwest::blocking::Client,
        workflow_run: &WorkflowRun,
    ) -> anyhow::Result<ArtifactMetadata> {
        let response = client
            .get(workflow_run.artifacts_url.as_str())
            .query(&[("name", Self::artifact_name()?), ("per_page", "1")])
            .send()?;

        let mut response: ArtifactsResponse = response.json()?;

        response.artifacts.pop().ok_or_else(|| {
            anyhow::anyhow!("Artifact was not found in GitHub API.")
        })
    }

    /// Get name of the branch artifact.
    fn artifact_name() -> anyhow::Result<&'static str> {
        Ok(match get_target()?.as_str() {
            "aarch64-unknown-linux-gnu" => "build-linux-arm64",
            "x86_64-unknown-linux-gnu" => "build-linux-x64",
            "aarch64-apple-darwin" => "build-macos-arm64",
            "x86_64-apple-darwin" => "build-macos-x64",
            "x86_64-pc-windows-msvc" => "build-windows-x64",
            arch => return Err(anyhow::anyhow!("Unsupported target: {arch}")),
        })
    }
}

/// Returns expected `libwebrtc` archives SHA-256 hashes.
fn get_expected_libwebrtc_hash() -> anyhow::Result<&'static str> {
    Ok(match get_target()?.as_str() {
        "aarch64-unknown-linux-gnu" => {
            "c34f443c583959c1a04f35eb5121c4a137a8cb38b48ba0b13f4b0e381e013e0f"
        }
        "x86_64-unknown-linux-gnu" => {
            "3a9a969f87293f4ffdb7255c464851d716076131679465f4fd16bedffd4dd86c"
        }
        "aarch64-apple-darwin" => {
            "ca56ec93a14975d61bf201b52c1307b58894e8b1f5e34aac53c507a8c5546230"
        }
        "x86_64-apple-darwin" => {
            "29c33f13a2606b783c5e197aa6d29c0b54f593beedc4a92fb2b876f876210003"
        }
        "x86_64-pc-windows-msvc" => {
            "aa018da90d48e9decac8dae72b98202697869f268fd96e3d7930078e0488c082"
        }
        arch => return Err(anyhow::anyhow!("Unsupported target: {arch}")),
    })
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
            "Gdi32",
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
    let output = process::Command::new("clang")
        .arg("--print-search-dirs")
        .output()
        .ok()?;
    if !output.status.success() {
        return None;
    }

    let stdout = String::from_utf8_lossy(&output.stdout);
    stdout.lines().filter(|l| l.contains("libraries: =")).find_map(|l| {
        let path = l.split('=').nth(1)?;
        (!path.is_empty()).then(|| format!("{path}/lib/darwin"))
    })
}
