import WebRTC
import AVFoundation
import OSLog
import os

public class MediaDevices {
    private var state: State

    init(state: State) {
        self.state = state
    }

    public func enumerateDevices() -> [MediaDeviceInfo] {
        var devices = AVCaptureDevice.devices(for: AVMediaType.video).map { device -> MediaDeviceInfo in
            os_log(OSLogType.error, "enumerateDevices 2")
            return MediaDeviceInfo(deviceId: device.uniqueID, label: device.localizedName, kind: MediaDeviceKind.audioInput)
        }
        let videoDevices = AVCaptureDevice.devices(for: AVMediaType.audio).map { device -> MediaDeviceInfo in 
            os_log(OSLogType.error, "enumerateDevices 3")
            return MediaDeviceInfo(deviceId: device.uniqueID, label: device.localizedName, kind: MediaDeviceKind.videoInput)
        }
        devices.append(contentsOf: videoDevices)
        return devices
    }

    public func getUserMedia() -> [MediaStreamTrackProxy] {
        var tracks = getUserAudio()
        tracks.append(getUserVideo())
        tracks.forEach {
            MediaStreamTrackStore.tracks[$0.id()] = $0
        }
        return tracks
    }

    private func getUserAudio() -> [MediaStreamTrackProxy] {
        let track = self.state.getPeerFactory().audioTrack(withTrackId: LocalTrackIdGenerator.shared.nextId())
        return [MediaStreamTrackProxy(track: track, deviceId: nil, source: nil)]
    }

    private func getUserVideo() -> MediaStreamTrackProxy {
        let videoDevice = AVCaptureDevice.default(for: AVMediaType.video)!
        let selectedFormat = selectFormatForDevice(device: videoDevice)

        let source = self.state.getPeerFactory().videoSource()
        let capturer = RTCCameraVideoCapturer(delegate: VideoSourceAdapter())
        capturer.startCapture(with: videoDevice, format: selectedFormat, fps: 30)
        let videoTrackSource = VideoMediaTrackSourceProxy(peerConnectionFactory: self.state.getPeerFactory(), source: source, deviceId: "camera")
        return videoTrackSource.newTrack()
    }

    private func selectFormatForDevice(device: AVCaptureDevice) -> AVCaptureDevice.Format {
        return RTCCameraVideoCapturer.supportedFormats(for: device)[0]
    }
}