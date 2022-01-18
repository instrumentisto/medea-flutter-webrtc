package com.cloudwebrtc.webrtc.model

import org.webrtc.MediaStreamTrack.MediaType as WMediaType;

enum class MediaType(val value: Int) {
    AUDIO(0),
    VIDEO(1);

    companion object {
        fun fromInt(value: Int) = values().first { it.value == value }
    }

    fun intoWebRtc(): WMediaType {
        return when (this) {
            AUDIO -> WMediaType.MEDIA_TYPE_AUDIO
            VIDEO -> WMediaType.MEDIA_TYPE_VIDEO
        }
    }
}