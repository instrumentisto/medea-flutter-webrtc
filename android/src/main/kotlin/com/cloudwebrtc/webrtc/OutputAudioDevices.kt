package com.cloudwebrtc.webrtc

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothProfile
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
 * Identifier for the bluetooth headset audio output device.
 */
const val BLUETOOTH_HEADSET_DEVICE_ID: String = "bluetooth-headset"

/**
 * Output audio devices manager.
 *
 * @property state  Global state used for output audio devices management.
 */
class OutputAudioDevices(val state: State) {
    /**
     * [BluetoothAdapter] used for detecting that bluetooth headset is connected or not.
     */
    private val bluetoothAdapter: BluetoothAdapter = BluetoothAdapter.getDefaultAdapter()

    /**
     * Indicator of bluetooth headset connection state.
     */
    private var isBluetoothHeadsetConnected: Boolean = false

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
     * @return  List of the available [OutputAudioDeviceInfo].
     */
    fun enumerateDevices(): List<OutputAudioDeviceInfo> {
        val devices = mutableListOf(
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
        if (isBluetoothHeadsetConnected) {
            devices.add(
                OutputAudioDeviceInfo(
                    BLUETOOTH_HEADSET_DEVICE_ID,
                    "Bluetooth headset",
                   OutputAudioDeviceKind.BLUETOOTH_HEADSET
                )
            )
        }
        return devices
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
}
