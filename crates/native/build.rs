fn main() {
    cxx_build::bridge("src/lib.rs").compile("jason_flutter_webrtc");
}
