import WebRTC

public class MediaDevices {
    private var peerConnectionFactory: RTCPeerConnectionFactory

    init(peerConnectionFactory: RTCPeerConnectionFactory) {
        self.peerConnectionFactory = peerConnectionFactory
    }

    public func enumerateDevices() -> [MediaDeviceInfo] {
        abort()
    }

    public func getUserMedia() -> [MediaStreamTrackProxy] {
        var tracks = getUserAudio()
        tracks.append(getUserVideo())
        return tracks
    }

    private func getUserAudio() -> [MediaStreamTrackProxy] {
        let track = self.peerConnectionFactory.audioTrack(withTrackId: LocalTrackIdGenerator.shared.nextId())
        return [MediaStreamTrackProxy(track: track, deviceId: nil, source: nil)]
    }

    private func getUserVideo() -> MediaStreamTrackProxy {
        let videoDevice = AVCaptureDevice.default(for: AVMediaType.video)!
        let selectedFormat = selectFormatForDevice(device: videoDevice)

        let source = peerConnectionFactory.videoSource()
        let capturer = RTCCameraVideoCapturer(delegate: VideoSourceAdapter())
        capturer.startCapture(with: videoDevice, format: selectedFormat, fps: 30)
        let videoTrackSource = VideoMediaTrackSourceProxy(peerConnectionFactory: self.peerConnectionFactory, source: source, deviceId: "camera")
        return videoTrackSource.newTrack()
    }

    private func selectFormatForDevice(device: AVCaptureDevice) -> AVCaptureDevice.Format {
        return RTCCameraVideoCapturer.supportedFormats(for: device)[0]
    }
}