import WebRTC
import AVFoundation
import OSLog
import os

public class MediaDevices {
    private var state: State
    private var videoCapturers: [RTCCameraVideoCapturer] = []

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
        return tracks
    }

    private func getUserAudio() -> [MediaStreamTrackProxy] {
        let track = self.state.getPeerFactory().audioTrack(withTrackId: LocalTrackIdGenerator.shared.nextId())
        let audioSource = AudioMediaTrackSourceProxy()
        let t = MediaStreamTrackProxy(track: track, deviceId: "audio", source: audioSource)
        audioSource.setTrack(track: t)
        return [t]
    }

    private func getUserVideo() -> MediaStreamTrackProxy {
        os_log(OSLogType.error, "getUserVideo was called")
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front)
        let videoDevice = discoverySession.devices[0];
        os_log(OSLogType.error, "getUserVideo: found video device: %@", videoDevice.localizedName)
        let selectedFormat = selectFormatForDevice(device: videoDevice)

        let source = self.state.getPeerFactory().videoSource()
        let capturer = RTCCameraVideoCapturer(delegate: source)
        capturer.startCapture(with: videoDevice, format: selectedFormat, fps: 30)
        self.videoCapturers.append(capturer)
        let videoTrackSource = VideoMediaTrackSourceProxy(peerConnectionFactory: self.state.getPeerFactory(), source: source, deviceId: "camera")
        return videoTrackSource.newTrack()
    }

    private func selectFormatForDevice(device: AVCaptureDevice) -> AVCaptureDevice.Format {
        os_log(OSLogType.error, "Supported formats for device: %@", RTCCameraVideoCapturer.supportedFormats(for: device))
        // [8]
        return RTCCameraVideoCapturer.supportedFormats(for: device)[8]
    }
}