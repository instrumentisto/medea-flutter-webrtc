//! Downloads [`libwebrtc-bin`] library.
//!
//! [`libwebrtc-bin`]: https://github.com/instrumentisto/libwebrtc-bin

use std::{
    borrow::Cow,
    env,
    fmt::{self, Display},
    fs,
    fs::File,
    io,
    io::{BufReader, BufWriter, Read as _},
    path::PathBuf,
};

use anyhow::Context as _;
use flate2::read::GzDecoder;
use reqwest::header::{AUTHORIZATION, HeaderMap, HeaderValue, USER_AGENT};
use serde::Deserialize;
use sha2::{Digest as _, Sha256};
use tar::Archive;
use zip::ZipArchive;

use crate::{get_target, libpath};

/// Base URL for the [`libwebrtc-bin`] GitHub.
///
/// [`libwebrtc-bin`]: https://github.com/instrumentisto/libwebrtc-bin
static LIBWEBRTC_URL: &str = "https://github.com/instrumentisto/libwebrtc-bin";

/// Release tag for downloading the [`libwebrtc-bin`].
///
/// [`libwebrtc-bin`]: https://github.com/instrumentisto/libwebrtc-bin
static LIBWEBRTC_RELEASE: &str = "138.0.7204.168";

/// Base URL for the [`libwebrtc-bin`] GitHub API.
///
/// [`libwebrtc-bin`]: https://github.com/instrumentisto/libwebrtc-bin
static GITHUB_API_URL: &str =
    "https://api.github.com/repos/instrumentisto/libwebrtc-bin";

/// Downloads and unpacks compiled `libwebrtc` library.
pub(super) fn download() -> anyhow::Result<()> {
    let repository = WebrtcRepository::build();
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
    /// Archive metadata.
    archive: ArchiveMetadata,
    /// Hash of archive's content.
    digest: Cow<'static, str>,
    /// Url for downloading the archive. It expires in 1 minute.
    download_url: String,
}

impl Artifact {
    /// Download the `libwebrtc` archive.
    fn download(
        mut self,
        lib_dir: &PathBuf,
        checksum: PathBuf,
    ) -> anyhow::Result<Option<DownloadedArtifact>> {
        let manifest_path = PathBuf::from(env::var("CARGO_MANIFEST_DIR")?);
        let temp_dir = manifest_path.join("temp");
        let archive = temp_dir.join(self.archive.to_string());

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
                io::copy(&mut &buffer[0..count], &mut out_file)?;
            }

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

/// Metadata of archive where [`Artifact`] is stored.
#[derive(Clone, Copy)]
enum ArchiveMetadata {
    /// `.tar.gz` archive.
    GZip(Platform),
    /// `.zip` archive.
    Zip(Platform),
}

impl Display for ArchiveMetadata {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::GZip(platform) => write!(f, "libwebrtc-{platform}.tar.gz"),
            Self::Zip(platform) => write!(f, "build-{platform}.zip"),
        }
    }
}

/// Supported platforms for building.
#[derive(Clone, Copy)]
enum Platform {
    /// `Linux` ARM64.
    LinuxArm64,
    /// `Linux` x64.
    LinuxX64,
    /// `MacOS` ARM64.
    MacOSArm64,
    /// `MacOS` x64.
    MacOSX64,
    /// `Windows` x64.
    WindowsX64,
}

impl Display for Platform {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let name = match self {
            Self::LinuxArm64 => "linux-arm64",
            Self::LinuxX64 => "linux-x64",
            Self::MacOSArm64 => "macos-arm64",
            Self::MacOSX64 => "macos-x64",
            Self::WindowsX64 => "windows-x64",
        };

        write!(f, "{name}")
    }
}

impl TryFrom<&str> for Platform {
    type Error = anyhow::Error;

    fn try_from(value: &str) -> Result<Self, Self::Error> {
        Ok(match value {
            "aarch64-unknown-linux-gnu" => Self::LinuxArm64,
            "x86_64-unknown-linux-gnu" => Self::LinuxX64,
            "aarch64-apple-darwin" => Self::MacOSArm64,
            "x86_64-apple-darwin" => Self::MacOSX64,
            "x86_64-pc-windows-msvc" => Self::WindowsX64,
            arch => return Err(anyhow::anyhow!("Unsupported target: {arch}")),
        })
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
    },
}

impl WebrtcRepository {
    /// Create a new `libwebrtc` GitHub repository representation.
    fn build() -> Self {
        if let Ok(branch) = env::var("WEBRTC_BRANCH") {
            return Self::Branch { name: branch };
        }

        Self::Release
    }

    /// Get an artifact from the repository.
    fn artifact(&self) -> anyhow::Result<Artifact> {
        let platform = get_target()?.as_str().try_into()?;

        match self {
            Self::Release => {
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
            Self::Branch { name } => {
                let archive = ArchiveMetadata::Zip(platform);
                let client = Self::client()?;

                let workflow_run = Self::workflow_run(&client, name.as_str())?;
                let metadata =
                    Self::artifact_metadata(&client, &workflow_run, platform)?;

                let response = client
                    .get(metadata.archive_download_url)
                    .query(&[("archive_format", "zip")])
                    .send()?;

                Ok(Artifact {
                    archive,
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
                })
            }
        }
    }

    /// Set up HTTP client.
    fn client() -> anyhow::Result<reqwest::blocking::Client> {
        let mut headers = HeaderMap::new();
        headers.insert(USER_AGENT, "instrumentisto".parse()?);
        let mut authorization = HeaderValue::from_str(&format!(
            "Bearer {}",
            Self::github_token()?
        ))?;
        authorization.set_sensitive(true);
        headers.insert(AUTHORIZATION, authorization);

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

    /// Get libwebrtc build artifact from workflow run.
    fn artifact_metadata(
        client: &reqwest::blocking::Client,
        workflow_run: &WorkflowRun,
        platform: Platform,
    ) -> anyhow::Result<ArtifactMetadata> {
        let response = client
            .get(workflow_run.artifacts_url.as_str())
            .query(&[
                ("name", format!("build-{platform}").as_str()),
                ("per_page", "1"),
            ])
            .send()?;

        let mut response: ArtifactsResponse = response.json()?;

        response.artifacts.pop().ok_or_else(|| {
            anyhow::anyhow!("Artifact was not found in GitHub API.")
        })
    }

    /// Get GitHub API token from environment variables.
    fn github_token() -> anyhow::Result<String> {
        env::var("GH_TOKEN").or_else(|_| env::var("GITHUB_TOKEN")).context(
            "libwebrtc branch was selected but github token isn't set.",
        )
    }
}

/// Returns expected `libwebrtc` archives SHA-256 hashes.
fn get_expected_libwebrtc_hash() -> anyhow::Result<&'static str> {
    Ok(match get_target()?.as_str() {
        "aarch64-unknown-linux-gnu" => {
            "85993256ee37f27e26efa80594be19eb02c60d345f7e676c9f56a53aa5857ea7"
        }
        "x86_64-unknown-linux-gnu" => {
            "7c5ec76c2f54bf6d44f8c2f84cf35b36b30f421afc349983de4f04cb5c2f1674"
        }
        "aarch64-apple-darwin" => {
            "4cd38564031f502ac4e3b26d2b4cb0e7bd4e0846e328865dce5990da12d34ce0"
        }
        "x86_64-apple-darwin" => {
            "72ddd24898cd8695e6ea187e6d6a27926bc67d0c613bcda70b27224ae0131fa4"
        }
        "x86_64-pc-windows-msvc" => {
            "d2962737109ec7415747a878d6193c5ef9a14c9b163b7ffe9e17aed90a953987"
        }
        arch => return Err(anyhow::anyhow!("Unsupported target: {arch}")),
    })
}
