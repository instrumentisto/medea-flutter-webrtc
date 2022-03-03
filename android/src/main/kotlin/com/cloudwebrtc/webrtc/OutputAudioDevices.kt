package com.cloudwebrtc.webrtc

import android.content.Context
import android.media.AudioManager
import com.cloudwebrtc.webrtc.exception.OverconstrainedException
import com.cloudwebrtc.webrtc.model.OutputAudioDeviceInfo
import com.cloudwebrtc.webrtc.model.OutputAudioDeviceKind

/**
 * Identifier for the ear speaker audio output device.
 */
const val EAR_SPEAKER_DEVICE_ID: String = "ear-speaker"

/**
 * Identifier for the speakerphone audio output device.
 */
const val SPEAKERPHONE_DEVICE_ID: String = "speakerphone"

/**
 * Output audio devices manager.
 *
 * @property state  Global state used for output audio devices management.
 */
class OutputAudioDevices(val state: State) {
    /**
     * @return  List of the available [OutputAudioDeviceInfo].
     */
    fun enumerateDevices(): List<OutputAudioDeviceInfo> {
        return listOf(
            OutputAudioDeviceInfo(
                EAR_SPEAKER_DEVICE_ID,
                "Ear-speaker",
                OutputAudioDeviceKind.EAR_SPEAKER
            ),
            OutputAudioDeviceInfo(
                SPEAKERPHONE_DEVICE_ID,
                "Speakerphone",
                OutputAudioDeviceKind.SPEAKERPHONE
            )
        )
    }

    /**
     * Switches current output audio device to the device with a provided identifier.
     *
     * @param deviceId  Identifier for the output audio device which will be selected.
     */
    fun setDevice(deviceId: String) {
        val audioManager =
                state.getAppContext().getSystemService(Context.AUDIO_SERVICE) as AudioManager
        when (deviceId) {
            EAR_SPEAKER_DEVICE_ID -> {
                audioManager.isSpeakerphoneOn = false
            }
            SPEAKERPHONE_DEVICE_ID -> {
                audioManager.isSpeakerphoneOn = true
            }
            else -> {
                throw OverconstrainedException()
            }
        }
    }
}