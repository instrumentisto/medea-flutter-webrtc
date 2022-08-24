import WebRTC

public class MediaStreamTrackProxy {
    private var isStopped = false
    private var deviceId = "remote"
    private var source: MediaTrackSource?;
    private var track: RTCMediaStreamTrack
    private var onStopSubscribers: Array<() -> Void> = []

    init(track: RTCMediaStreamTrack, deviceId: String?, source: MediaTrackSource?) {
        self.source = source
        if (deviceId != nil) {
            self.deviceId = deviceId!
        }
        self.track = track
    }

    func id() -> String {
        return track.trackId;
    }

    func kind() -> MediaType {
        let kind = track.kind;
        switch kind {
            case "audio":
                return MediaType.audio
            case "video":
                return MediaType.video
            default:
                abort()
        }
    }

    func getDeviceId() -> String {
        return self.deviceId;
    }

    func fork() -> MediaStreamTrackProxy {
        if (self.source == nil) {
            // TODO: Remote MediaStreamTracks can't be cloned exception
            abort()
        } else {
            return source!.newTrack()
        }
    }

    func stop() {
        self.isStopped = true
        for cb in onStopSubscribers {
            cb()
        }
    }

    func state() -> MediaStreamTrackState {
        let state = track.readyState;
        switch state {
            case .live:
                return MediaStreamTrackState.live
            case .ended:
                return MediaStreamTrackState.ended
            default:
                abort()
        }
    }

    func setEnabled(enabled: Bool) {
        self.track.isEnabled = enabled;
    }

    func onEnded(cb: @escaping () -> Void) {
        self.onStopSubscribers.append(cb)
    }

    func obj() -> RTCMediaStreamTrack {
        return self.track
    }
}