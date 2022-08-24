import WebRTC

public class VideoMediaTrackSourceProxy : MediaTrackSource {
    private var peerConnectionFactory: RTCPeerConnectionFactory;
    private var source: RTCVideoSource;
    private var deviceId: String;

    init(peerConnectionFactory: RTCPeerConnectionFactory, source: RTCVideoSource, deviceId: String) {
        self.peerConnectionFactory = peerConnectionFactory
        self.source = source
        self.deviceId = deviceId;
    }

    func newTrack() -> MediaStreamTrackProxy {
        let track = peerConnectionFactory.videoTrack(with: source, trackId: LocalTrackIdGenerator.shared.nextId())
        return MediaStreamTrackProxy(track: track, deviceId: self.deviceId, source: self)
    }
}