fn main() -> anyhow::Result<()> {
    cxx_build::bridge("src/lib.rs").compile("jason_flutter_webrtc");

    Ok(())
}
