package com.cloudwebrtc.webrtc.proxy

interface MediaTrackSource {
    fun newTrack(): MediaStreamTrackProxy
}