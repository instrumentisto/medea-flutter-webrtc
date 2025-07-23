//! Downloads [`libwebrtc-bin`] library.
//!
//! [`libwebrtc-bin`]: https://github.com/instrumentisto/libwebrtc-bin

use std::{
    borrow::Cow,
    fs,
    fs::File,
    io::{BufReader, BufWriter, Read as _, Write as _},
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
static LIBWEBRTC_RELEASE: &str = "138.0.7204.157";

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
        let manifest_path = PathBuf::from(dotenv::var("CARGO_MANIFEST_DIR")?);
        let temp_dir = manifest_path.join("temp");
        let archive = temp_dir.join(&self.name);

        // Force download if `INSTALL_WEBRTC=1`.
        if dotenv::var("INSTALL_WEBRTC").as_deref().unwrap_or("0") == "0" {
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
    },
}

impl WebrtcRepository {
    /// Create a new `libwebrtc` GitHub repository representation.
    fn build() -> Self {
        if let Ok(branch) = dotenv::var("WEBRTC_BRANCH") {
            return Self::Branch { name: branch };
        }

        Self::Release
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
            Self::Branch { name } => {
                let client = Self::client()?;

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

    /// Get GitHub API token from environment variables.
    fn github_token() -> anyhow::Result<String> {
        dotenv::var("GH_TOKEN")
            .or_else(|_| dotenv::var("GITHUB_TOKEN"))
            .context(
                "libwebrtc branch was selected but github token isn't set.",
            )
    }
}

/// Returns expected `libwebrtc` archives SHA-256 hashes.
fn get_expected_libwebrtc_hash() -> anyhow::Result<&'static str> {
    Ok(match get_target()?.as_str() {
        "aarch64-unknown-linux-gnu" => {
            "79ccf20cfa8d83ecd22b6124908efcca921897c90cc330a3a6f2f64f4ba90073"
        }
        "x86_64-unknown-linux-gnu" => {
            "2f33dfbdbeac9ebce717423cb5408b761ce408fe4c00e8027e47b31b611462fe"
        }
        "aarch64-apple-darwin" => {
            "878d96986e062dddfa01ddb145ab2a961ecba5a2d387373198ad25e23cb8fb3f"
        }
        "x86_64-apple-darwin" => {
            "fb94a3ab5e3507ef945e279b2dad4645b1b9db875be1f77092644b40c27ade36"
        }
        "x86_64-pc-windows-msvc" => {
            "5a38f475023877d071c068d9ddb0bf8f508de9e6a71c9f61fdec48065110d72d"
        }
        arch => return Err(anyhow::anyhow!("Unsupported target: {arch}")),
    })
}
