package com.cloudwebrtc.webrtc

import android.content.Context
import com.cloudwebrtc.webrtc.exception.OverconstrainedException
import com.cloudwebrtc.webrtc.model.*
import com.cloudwebrtc.webrtc.proxy.MediaStreamTrackProxy
import com.cloudwebrtc.webrtc.utils.EglUtils
import org.webrtc.*
import java.util.*

class MediaDevices(val state: State) {
    private val cameraEnumerator: CameraEnumerator = getCameraEnumerator(state.getAppContext())
    private var lastLocalTrackId: Int = 0;

    companion object {
        private fun getCameraEnumerator(context: Context): CameraEnumerator {
            return if (Camera2Enumerator.isSupported(context)) {
                Camera2Enumerator(context)
            } else {
                // TODO(evdokimovs): Why captureToTexture is false?
                Camera1Enumerator(false)
            }
        }
    }

    fun getUserMedia(constraints: Constraints): List<MediaStreamTrackProxy> {
        val tracks = mutableListOf<MediaStreamTrackProxy>()
        if (constraints.audio != null) {
            tracks.add(getUserAudioTrack(constraints.audio))
        }
        if (constraints.video != null) {
            tracks.add(getUserVideoTrack(constraints.video))
        }
        return tracks
    }

    fun enumerateDevices(): List<MediaDeviceInfo> {
        return enumerateAudioDevices() + enumerateVideoDevices()
    }

    private fun enumerateAudioDevices(): List<MediaDeviceInfo> {
        return listOf(MediaDeviceInfo("default", "default", MediaDeviceKind.AUDIO_INPUT))
    }

    private fun enumerateVideoDevices(): List<MediaDeviceInfo> {
        return cameraEnumerator.deviceNames.map { deviceId ->
            MediaDeviceInfo(deviceId, deviceId, MediaDeviceKind.VIDEO_INPUT)
        }.toList()
    }

    private fun findDeviceMatchingConstraints(constraints: VideoConstraints): String? {
        val scoreTable = TreeMap<Int, String>();
        for (deviceId in cameraEnumerator.deviceNames) {
            val deviceScore = constraints.calculateScoreForDeviceId(cameraEnumerator, deviceId)
            if (deviceScore != null) {
                scoreTable[deviceScore] = deviceId
            }
        }

        return scoreTable.lastEntry()?.value
    }

    private fun getNextTrackId(): String {
        return "local-" + lastLocalTrackId++.toString()
    }

    // TODO(evdokimovs): Adapt width, height and fps based on constraints
    private fun getUserVideoTrack(constraints: VideoConstraints): MediaStreamTrackProxy {
        val deviceId =
            findDeviceMatchingConstraints(constraints) ?: throw OverconstrainedException()

        val videoSource = state.getPeerConnectionFactory().createVideoSource(false)
        // TODO(evdokimovs): This is optional function call as I know, so
        //                   call it only when some constraints was provided
        // TODO: Remove this line and if all continues to work then yep, it's okay
        videoSource.adaptOutputFormat(1280, 720, 30)

        val surfaceTextureRenderer = SurfaceTextureHelper.create(
            Thread.currentThread().name,
            EglUtils.rootEglBaseContext
        )
        // TODO(evdokimovs): Maybe we need some implementation in CameraEventsHandler?
        val videoCapturer = cameraEnumerator.createCapturer(
            deviceId,
            object : CameraVideoCapturer.CameraEventsHandler {
                override fun onCameraError(p0: String?) {}
                override fun onCameraDisconnected() {}
                override fun onCameraFreezed(p0: String?) {}
                override fun onCameraOpening(p0: String?) {}
                override fun onFirstFrameAvailable() {}
                override fun onCameraClosed() {}
            }
        )
        videoCapturer.initialize(
            surfaceTextureRenderer,
            state.getAppContext(),
            videoSource.capturerObserver
        )
        // Just use width and height of the selected device here
        videoCapturer.startCapture(1280, 720, 30)

        val videoTrack = MediaStreamTrackProxy(
            state.getPeerConnectionFactory().createVideoTrack(getNextTrackId(), videoSource),
            deviceId
        )
        videoTrack.onStop {
            videoCapturer.stopCapture()
            videoSource.dispose()
            videoCapturer.dispose()
            surfaceTextureRenderer.dispose()
        }

        return videoTrack
    }

    private fun getUserAudioTrack(constraints: AudioConstraints): MediaStreamTrackProxy {
        val trackId = getNextTrackId()
        val source = state.getPeerConnectionFactory().createAudioSource(constraints.intoWebRtc())
        // TODO(evdokimovs): Provide real deviceId when this mechanism will be implemented.
        val track = MediaStreamTrackProxy(
            state.getPeerConnectionFactory().createAudioTrack(trackId, source),
            "audio-1"
        )
        track.onStop {
            source.dispose()
        }

        return track
    }
}