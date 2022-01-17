package com.cloudwebrtc.webrtc.model

import org.webrtc.MediaStreamTrack.MediaType as WMediaType;

enum class MediaType {
    AUDIO,
    VIDEO;

    fun intoWebRtc(): WMediaType {
        return when (this) {
            AUDIO -> WMediaType.MEDIA_TYPE_AUDIO
            VIDEO -> WMediaType.MEDIA_TYPE_VIDEO
        }
    }
}