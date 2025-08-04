//! Downloading pre-built [`libwebrtc-bin`] library.
//!
//! [`libwebrtc-bin`]: https://github.com/instrumentisto/libwebrtc-bin

use std::{
    env, fs,
    fs::File,
    io::{BufReader, BufWriter, Read as _, Write as _},
    path::PathBuf,
};

use anyhow::Context as _;
use derive_more::Display;
use flate2::read::GzDecoder;
use reqwest::header::{AUTHORIZATION, HeaderMap, HeaderValue, USER_AGENT};
use serde::Deserialize;
use sha2::{Digest as _, Sha256};
use tar::Archive;
use zip::ZipArchive;

use crate::libpath;

/// Base URL for the [`libwebrtc-bin`] GitHub.
///
/// [`libwebrtc-bin`]: https://github.com/instrumentisto/libwebrtc-bin
static LIBWEBRTC_URL: &str = "https://github.com/instrumentisto/libwebrtc-bin";

/// Release tag for downloading the [`libwebrtc-bin`].
///
/// [`libwebrtc-bin`]: https://github.com/instrumentisto/libwebrtc-bin
static LIBWEBRTC_RELEASE: &str = "138.0.7204.183";

/// Base URL for the [`libwebrtc-bin`] GitHub API.
///
/// [`libwebrtc-bin`]: https://github.com/instrumentisto/libwebrtc-bin
static GITHUB_API_URL: &str =
    "https://api.github.com/repos/instrumentisto/libwebrtc-bin";

/// Returns the expected `libwebrtc` archives SHA-256 hashes.
fn get_expected_libwebrtc_hash() -> anyhow::Result<&'static str> {
    Ok(match get_target()? {
        Platform::LinuxArm64 => {
            "75f6120a5541d6908c362b32ab1077eb0b0fa265cbfce9bd0eeb66919369781d"
        }
        Platform::LinuxX64 => {
            "c4d80a9df244425dd3c15cc64c8a86a425ef80ccec111271d76a774288f6976d"
        }
        Platform::MacOSArm64 => {
            "b6b71d60e7c4de608993b89e07f5a4c5b1482cb97ffee4c89b539f0203852dc0"
        }
        Platform::MacOSX64 => {
            "7fcd019d61797e640c6d593e2e25eb44f7d49cc41ac88fb3d95d7bad69d091e5"
        }
        Platform::WindowsX64 => {
            "f0195b54ff446409026c2ad34b951f7db116671122315d560ab7cee030c7d33f"
        }
    })
}

/// Downloads and unpacks a compiled `libwebrtc` library.
pub(super) fn download() -> anyhow::Result<()> {
    let platform = get_target()?;

    let repository = WebrtcRepository::new();
    let artifact = repository.artifact(platform)?;

    let lib_dir = libpath()?;

    println!("Using artifact from `{}`", artifact.download_url);
    if let Some(artifact) =
        artifact.maybe_download(&lib_dir, lib_dir.join("CHECKSUM"))?
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

    /// Path to the temp directory where the downloaded archive is stored.
    temp_dir: PathBuf,

    /// Path to the checksum file of the archive.
    checksum: PathBuf,
}

impl DownloadedArtifact {
    /// Unpacks the downloaded `libwebrtc` archive.
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

/// Built artifact from a release or a CI run.
struct Artifact {
    /// Archive metadata.
    archive: ArchiveMetadata,

    /// Hash of archive's content.
    digest: String,

    /// URL for downloading the archive.
    ///
    /// It expires in 1 minute.
    download_url: String,
}

impl Artifact {
    /// Downloads the `libwebrtc` archive of this [`Artifact`].
    fn maybe_download(
        mut self,
        lib_dir: &PathBuf,
        checksum: PathBuf,
    ) -> anyhow::Result<Option<DownloadedArtifact>> {
        let manifest_path = PathBuf::from(env::var("CARGO_MANIFEST_DIR")?);
        let temp_dir = manifest_path.join("temp");
        let archive = temp_dir.join(self.archive.to_string());

        // Force download if `INSTALL_WEBRTC=1`.
        if env::var("INSTALL_WEBRTC").as_deref().unwrap_or("0") == "0" {
            // Skip download if already downloaded and the checksum matches.
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
            out_file.flush()?;

            if format!("{:x}", hasher.finalize()).as_str() != self.digest {
                anyhow::bail!("SHA-256 checksum doesn't match");
            }
        }

        self.unpack(&archive, &temp_dir)?;

        Ok(Some(DownloadedArtifact {
            path: temp_dir.join(self.archive.to_string()),
            temp_dir,
            checksum,
            artifact: self,
        }))
    }

    /// Unpacks the [`Artifact`] from the wrapper archive.
    fn unpack(
        &mut self,
        archive_path: &PathBuf,
        temp_dir: &PathBuf,
    ) -> anyhow::Result<()> {
        match self.archive {
            ArchiveMetadata::GZip(_) => (),
            ArchiveMetadata::Zip(platform) => {
                ZipArchive::new(File::open(archive_path)?)?
                    .extract(temp_dir)?;
                self.archive = ArchiveMetadata::GZip(platform);
            }
        }

        Ok(())
    }
}

/// Metadata of an archive where an [`Artifact`] is stored.
#[derive(Clone, Copy, Display)]
enum ArchiveMetadata {
    /// `.tar.gz` archive.
    #[display("libwebrtc-{}.tar.gz", _0)]
    GZip(Platform),

    /// `.zip` archive.
    #[display("build-{}.zip", _0)]
    Zip(Platform),
}

/// Supported platforms for building.
#[derive(Clone, Copy, Display)]
enum Platform {
    /// `Linux` ARM64.
    #[display("linux-arm64")]
    LinuxArm64,

    /// `Linux` x64.
    #[display("linux-x64")]
    LinuxX64,

    /// `macOS` ARM64.
    #[display("macos-arm64")]
    MacOSArm64,

    /// `macOS` x64.
    #[display("macos-x64")]
    MacOSX64,

    /// `Windows` x64.
    #[display("windows-x64")]
    WindowsX64,
}

impl TryFrom<&str> for Platform {
    type Error = anyhow::Error;

    fn try_from(value: &str) -> Result<Self, Self::Error> {
        Ok(match value {
            "aarch64-unknown-linux-gnu" | "linux-arm64" => Self::LinuxArm64,
            "x86_64-unknown-linux-gnu" | "linux-x64" => Self::LinuxX64,
            "aarch64-apple-darwin" | "macos-arm64" => Self::MacOSArm64,
            "x86_64-apple-darwin" | "macos-x64" => Self::MacOSX64,
            "x86_64-pc-windows-msvc" | "windows-x64" => Self::WindowsX64,
            arch => return Err(anyhow::anyhow!("Unsupported target: {arch}")),
        })
    }
}

/// Representation of an artifact from GitHub API.
#[derive(Deserialize)]
struct ArtifactMetadata {
    /// Hash of artifact's archive content.
    digest: String,

    /// URL to REST API for getting artifact's download link.
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
    /// Workflow run ID.
    id: u64,

    /// REST API URL to list all artifacts in this [`WorkflowRun`].
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
    /// Artifact will be fetched from the release assets.
    Release,

    /// Artifact will be fetched from the latest workflow run on a specified
    /// branch.
    Branch(String),
}

impl WebrtcRepository {
    /// Creates a new [`WebrtcRepository`] based on the environment variables.
    fn new() -> Self {
        if let Ok(branch) = env::var("WEBRTC_BRANCH") {
            return Self::Branch(branch);
        }

        Self::Release
    }

    /// Returns an [`Artifact`] for the specified [`Platform`].
    fn artifact(&self, platform: Platform) -> anyhow::Result<Artifact> {
        match self {
            Self::Release => {
                println!("Using artifacts from release `{LIBWEBRTC_RELEASE}`");

                let archive = ArchiveMetadata::GZip(platform);
                let download_url = format!(
                    "{LIBWEBRTC_URL}/releases/download\
                                    /{LIBWEBRTC_RELEASE}/{archive}",
                );

                Ok(Artifact {
                    archive,
                    download_url,
                    digest: get_expected_libwebrtc_hash()?.into(),
                })
            }
            Self::Branch(branch) => {
                println!("Using artifacts from branch `{branch}`");

                let archive = ArchiveMetadata::Zip(platform);
                let client = Self::client()?;

                let workflow_run =
                    Self::workflow_run(&client, branch.as_str())?;
                let metadata =
                    Self::artifact_metadata(&client, &workflow_run, platform)?;

                let response = client
                    .get(metadata.archive_download_url)
                    .query(&[("archive_format", "zip")])
                    .send()?;

                let digest = {
                    let mut split = metadata.digest.split(':');

                    if split.next() != Some("sha256") {
                        return Err(anyhow::anyhow!(
                            "Expected SHA-256 digest, got {}",
                            metadata.digest,
                        ));
                    }

                    split
                        .next()
                        .ok_or_else(|| {
                            anyhow::anyhow!(
                                "Expected SHA-256 digest, got {}",
                                metadata.digest,
                            )
                        })?
                        .to_owned()
                };

                Ok(Artifact {
                    archive,
                    digest,
                    download_url: response
                        .headers()
                        .get("Location")
                        .ok_or_else(|| {
                            anyhow::anyhow!(
                                "Got invalid `Location` from Github API",
                            )
                        })?
                        .to_str()?
                        .into(),
                })
            }
        }
    }

    /// Sets up an HTTP client.
    fn client() -> anyhow::Result<reqwest::blocking::Client> {
        let mut headers = HeaderMap::new();
        headers.insert(USER_AGENT, "instrumentisto".parse()?);
        let mut authorization = HeaderValue::from_str(&format!(
            "Bearer {}",
            Self::github_token()?,
        ))?;
        authorization.set_sensitive(true);
        headers.insert(AUTHORIZATION, authorization);

        Ok(reqwest::blocking::Client::builder()
            .default_headers(headers)
            .redirect(reqwest::redirect::Policy::none())
            .build()?)
    }

    /// Returns the latest [`WorkflowRun`] for the specified `branch`.
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

        let run = response.workflow_runs.pop().ok_or_else(|| anyhow::anyhow!(
            "No successful workflow runs found for selected `libwebrtc-bin` \
             branch",
        ))?;

        println!("Using artifacts from workflow run `{}`", run.id);

        Ok(run)
    }

    /// Finds [`ArtifactMetadata`] for the provided [`Platform`] in the
    /// specified [`WorkflowRun`].
    fn artifact_metadata(
        client: &reqwest::blocking::Client,
        workflow_run: &WorkflowRun,
        platform: Platform,
    ) -> anyhow::Result<ArtifactMetadata> {
        let artifact_name = format!("build-{platform}");
        println!(
            "Trying to find artifact `{artifact_name}` in \
             the workflow run `{}`",
            workflow_run.id
        );
        let response = client
            .get(workflow_run.artifacts_url.as_str())
            .query(&[("name", artifact_name.as_str()), ("per_page", "1")])
            .send()?;

        let mut response: ArtifactsResponse = response.json()?;

        response.artifacts.pop().ok_or_else(|| {
            anyhow::anyhow!("Artifact was not found in GitHub API")
        })
    }

    /// Get GitHub API token from environment variables.
    fn github_token() -> anyhow::Result<String> {
        env::var("GH_TOKEN").or_else(|_| env::var("GITHUB_TOKEN")).context(
            "`WEBRTC_BRANCH` is set but no GitHub token is found: \
             set `GH_TOKEN` env var",
        )
    }
}

/// Returns the [`Platform`] to build the library for, based on the currently
/// set `target`.
fn get_target() -> anyhow::Result<Platform> {
    super::get_target()?.as_str().try_into()
}
