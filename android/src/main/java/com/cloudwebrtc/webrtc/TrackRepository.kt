package com.cloudwebrtc.webrtc

import com.cloudwebrtc.webrtc.proxy.MediaStreamTrackProxy
import java.lang.ref.WeakReference
import java.util.*
import kotlin.collections.HashMap

object TrackRepository {
    private val tracks: HashMap<String, WeakReference<MediaStreamTrackProxy>> = HashMap()

    fun addTrack(id: String, track: MediaStreamTrackProxy) {
        tracks[id] = WeakReference(track)
    }

    fun getTrack(id: String): MediaStreamTrackProxy? {
        return tracks[id]?.get()
    }
}