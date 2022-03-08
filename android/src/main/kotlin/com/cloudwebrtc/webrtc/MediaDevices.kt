package com.cloudwebrtc.webrtc

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothProfile
import android.content.Context
import android.media.AudioManager
import com.cloudwebrtc.webrtc.exception.OverconstrainedException
import com.cloudwebrtc.webrtc.model.*
import com.cloudwebrtc.webrtc.proxy.AudioMediaTrackSource
import com.cloudwebrtc.webrtc.proxy.MediaStreamTrackProxy
import com.cloudwebrtc.webrtc.proxy.VideoMediaTrackSource
import com.cloudwebrtc.webrtc.utils.EglUtils
import org.webrtc.*
import java.util.*

/**
 * Default device video width.
 *
 * This width will be used, if no width provided in the constraints.
 *
 * SD resolution used by default.
 */
private const val DEFAULT_WIDTH = 720

/**
 * Default device video height.
 *
 * This width will be used, if no height provided in the constraints.
 *
 * SD resolution used by default.
 */
private const val DEFAULT_HEIGHT = 576

/**
 * Default device video FPS.
 *
 * This width will be used, if no FPS provided in the constraints.
 */
private const val DEFAULT_FPS = 30

/**
 * Identifier for the ear speaker audio output device.
 */
private const val EAR_SPEAKER_DEVICE_ID: String = "ear-speaker"

/**
 * Identifier for the speakerphone audio output device.
 */
private const val SPEAKERPHONE_DEVICE_ID: String = "speakerphone"

/**
 * Identifier for the bluetooth headset audio output device.
 */
private const val BLUETOOTH_HEADSET_DEVICE_ID: String = "bluetooth-headset"

/**
 * Processor for `getUserMedia` requests.
 *
 * @property state  Global state used for enumerating devices and creation new
 *                  [MediaStreamTrackProxy]s.
 */
class MediaDevices(val state: State) {
    /**
     * [BluetoothAdapter] used for detecting that bluetooth headset is connected or not.
     */
    private val bluetoothAdapter: BluetoothAdapter = BluetoothAdapter.getDefaultAdapter()

    /**
     * Indicator of bluetooth headset connection state.
     */
    private var isBluetoothHeadsetConnected: Boolean = false

    /**
     * Enumerator for the camera devices, based on which new video
     * [MediaStreamTrackProxy]s will be created.
     */
    private val cameraEnumerator: CameraEnumerator =
        getCameraEnumerator(state.getAppContext())

    companion object {
        /**
         * Creates a new [CameraEnumerator] instance based on the supported
         * Camera API version.
         *
         * @param context  Android context which needed for the
         *                 [CameraEnumerator] creation.
         *
         * @return  [CameraEnumerator] based on the available Camera API
         *          version.
         */
        private fun getCameraEnumerator(context: Context): CameraEnumerator {
            return if (Camera2Enumerator.isSupported(context)) {
                Camera2Enumerator(context)
            } else {
                Camera1Enumerator(false)
            }
        }
    }

    init {
        bluetoothAdapter.getProfileProxy(
            state.getAppContext(),
            object : BluetoothProfile.ServiceListener {
                override fun onServiceConnected(profile: Int, proxy: BluetoothProfile?) {
                    isBluetoothHeadsetConnected = true
                }

                override fun onServiceDisconnected(profile: Int) {
                    isBluetoothHeadsetConnected = false
                }
            },
            BluetoothProfile.HEADSET
        )
    }

    /**
     * Creates local audio and video [MediaStreamTrackProxy]s based on the
     * provided [Constraints].
     *
     * @param constraints  Parameters based on which [MediaDevices] will select
     *                     most suitable device.
     *
     * @return  List of [MediaStreamTrackProxy]s most suitable based on the
     *          provided [Constraints].
     */
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

    /**
     * @return  List of [MediaDeviceInfo]s for the currently available devices.
     */
    fun enumerateDevices(): List<MediaDeviceInfo> {
        return enumerateAudioDevices() + enumerateVideoDevices()
    }

    /**
     * Switches current output audio device to the device with a provided identifier.
     *
     * @param deviceId  Identifier for the output audio device which will be selected.
     */
    fun setOutputAudioId(deviceId: String) {
        val audioManager =
                state.getAppContext().getSystemService(Context.AUDIO_SERVICE) as AudioManager
        when (deviceId) {
            EAR_SPEAKER_DEVICE_ID -> {
                audioManager.isBluetoothScoOn = false
                audioManager.stopBluetoothSco()
                audioManager.isSpeakerphoneOn = false
            }
            SPEAKERPHONE_DEVICE_ID -> {
                audioManager.isBluetoothScoOn = false
                audioManager.stopBluetoothSco()
                audioManager.isSpeakerphoneOn = true
            }
            BLUETOOTH_HEADSET_DEVICE_ID -> {
                audioManager.isSpeakerphoneOn = false
                audioManager.isBluetoothScoOn = true
                audioManager.startBluetoothSco()
            }
            else -> {
                throw OverconstrainedException()
            }
        }
    }

    /**
     * @return  List of [MediaDeviceInfo]s for the currently available audio
     *          devices.
     */
    private fun enumerateAudioDevices(): List<MediaDeviceInfo> {
        val devices = mutableListOf(
            MediaDeviceInfo(
                EAR_SPEAKER_DEVICE_ID,
            "Ear-speaker",
                MediaDeviceKind.AUDIO_OUTPUT
            ),
            MediaDeviceInfo(
                SPEAKERPHONE_DEVICE_ID,
                "Speakerphone",
                MediaDeviceKind.AUDIO_OUTPUT
            )
        )
        if (isBluetoothHeadsetConnected) {
            devices.add(
                MediaDeviceInfo(
                    BLUETOOTH_HEADSET_DEVICE_ID,
                    "Bluetooth headset",
                    MediaDeviceKind.AUDIO_OUTPUT
                )
            )
        }
        devices.add(
            MediaDeviceInfo(
                "default",
                "default",
                MediaDeviceKind.AUDIO_INPUT
            )
        )
        return devices
    }

    /**
     * @return  List of [MediaDeviceInfo]s for the currently available video
     *          devices.
     */
    private fun enumerateVideoDevices(): List<MediaDeviceInfo> {
        return cameraEnumerator.deviceNames.map { deviceId ->
            MediaDeviceInfo(deviceId, deviceId, MediaDeviceKind.VIDEO_INPUT)
        }.toList()
    }

    /**
     * Lookups ID of the video device most suitable basing on the provided
     * [VideoConstraints].
     *
     * @param constraints  [VideoConstraints] based on which lookup will be
     *                     performed.
     *
     * @return  `null` if all devices are not suitable for the provided
     *          [VideoConstraints], or most suitable device ID for the provided
     *          [VideoConstraints].
     */
    private fun findDeviceMatchingConstraints(constraints: VideoConstraints): String? {
        val scoreTable = TreeMap<Int, String>()
        for (deviceId in cameraEnumerator.deviceNames) {
            val deviceScore = constraints.calculateScoreForDeviceId(
                cameraEnumerator,
                deviceId
            )
            if (deviceScore != null) {
                scoreTable[deviceScore] = deviceId
            }
        }

        return scoreTable.lastEntry()?.value
    }

    /**
     * Creates a video [MediaStreamTrackProxy] for the provided [VideoConstraints].
     *
     * @param constraints  [VideoConstraints] to perform the lookup with.
     *
     * @return  Most suitable [MediaStreamTrackProxy] for the provided
     *          [VideoConstraints].
     */
    private fun getUserVideoTrack(constraints: VideoConstraints): MediaStreamTrackProxy {
        val deviceId =
            findDeviceMatchingConstraints(constraints)
                ?: throw OverconstrainedException()
        val width = constraints.width ?: DEFAULT_WIDTH
        val height = constraints.height ?: DEFAULT_HEIGHT
        val fps = constraints.fps ?: DEFAULT_FPS

        val videoSource =
            state.getPeerConnectionFactory().createVideoSource(false)
        videoSource.adaptOutputFormat(width, height, fps)

        val surfaceTextureRenderer = SurfaceTextureHelper.create(
            Thread.currentThread().name,
            EglUtils.rootEglBaseContext
        )
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
        videoCapturer.startCapture(width, height, fps)

        val videoTrackSource = VideoMediaTrackSource(
            videoCapturer,
            videoSource,
            surfaceTextureRenderer,
            state.getPeerConnectionFactory(),
            deviceId
        )

        return videoTrackSource.newTrack()
    }

    /**
     * Creates an audio [MediaStreamTrackProxy] basing on the provided
     * [AudioConstraints].
     *
     * @param constraints  [AudioConstraints] to perform the lookup with.
     *
     * @return  Most suitable [MediaStreamTrackProxy] for the provided
     *          [AudioConstraints].
     */
    private fun getUserAudioTrack(constraints: AudioConstraints): MediaStreamTrackProxy {
        val source = state.getPeerConnectionFactory()
            .createAudioSource(constraints.intoWebRtc())
        val audioTrackSource =
            AudioMediaTrackSource(source, state.getPeerConnectionFactory())
        return audioTrackSource.newTrack()
    }
}
