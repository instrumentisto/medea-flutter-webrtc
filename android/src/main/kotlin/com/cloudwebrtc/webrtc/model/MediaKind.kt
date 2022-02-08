package com.cloudwebrtc.webrtc.model

/**
 * Kind of media.
 *
 * @property value [Int] representation of this enum which will be expected on Flutter side.
 */
enum class MediaKind(val value: Int) {
    Audio(0),
    Video(1)
}