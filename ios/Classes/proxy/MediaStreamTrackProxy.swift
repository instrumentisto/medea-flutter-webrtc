import WebRTC

public class MediaStreamTrackProxy {
    private var isStopped = false
    private let deviceId = "remote"
    private let source: MediaTrackSource? = nil
    private let track: MediaStreamTrack

    init(track: MediaStreamTrack, deviceId: String, source: MediaTrackSource?) {
        self.source = source
        self.deviceId = deviceId
        self.track = track
    }

    func id() -> String {
        abort()
    }

    func kind() -> MediaType {
        abort()
    }

    func deviceId() -> String {
        abort()
    }

    func fork() -> MediaStreamTrackProxy {
        abort()
    }

    func stop() {
        abort()
    }

    func state() -> MediaStreamTrackState {
        abort()
    }

    func setEnabled(enabled: Boolean) {
        abort()
    }
}