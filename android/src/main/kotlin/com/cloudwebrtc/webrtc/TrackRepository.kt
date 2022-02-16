package com.cloudwebrtc.webrtc

import com.cloudwebrtc.webrtc.proxy.MediaStreamTrackProxy
import java.lang.ref.WeakReference

/**
 * Repository for the all [MediaStreamTrackProxy]s.
 *
 * All created in the flutter_webrtc [MediaStreamTrackProxy]s will be stored here as weak
 * reference. So if, [MediaStreamTrackProxy] was disposed, then it will be `null` here.
 */
object TrackRepository {
    /**
     * All [MediaStreamTrackProxy]s created in flutter_webrtc.
     */
    private val tracks: HashMap<String, WeakReference<MediaStreamTrackProxy>> =
        HashMap()

    /**
     * Adds new [MediaStreamTrackProxy].
     *
     * @param track actual [MediaStreamTrackProxy] which will be stored here.
     */
    fun addTrack(track: MediaStreamTrackProxy) {
        tracks[track.id()] = WeakReference(track)
    }

    /**
     * Lookups [MediaStreamTrackProxy] with a provided unique ID.
     *
     * @param id unique [MediaStreamTrackProxy] ID by which lookup will be performed.
     * @return found [MediaStreamTrackProxy] with a provided ID.
     * @return null if [MediaStreamTrackProxy] isn't found or was disposed.
     */
    fun getTrack(id: String): MediaStreamTrackProxy? {
        return tracks[id]?.get()
    }
}