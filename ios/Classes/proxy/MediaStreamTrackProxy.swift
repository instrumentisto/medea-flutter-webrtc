public class MediaStreamTrackProxy {
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