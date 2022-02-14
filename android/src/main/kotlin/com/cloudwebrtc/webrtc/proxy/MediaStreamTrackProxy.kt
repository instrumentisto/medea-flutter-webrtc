package com.cloudwebrtc.webrtc.proxy

import android.util.Log
import com.cloudwebrtc.webrtc.TrackRepository
import com.cloudwebrtc.webrtc.model.MediaKind
import com.cloudwebrtc.webrtc.model.MediaStreamTrackState
import org.webrtc.MediaStreamTrack

/**
 * Wrapper around [MediaStreamTrack].
 *
 * @param track underlying [MediaStreamTrack].
 * @property deviceId unique ID of device on which this [MediaStreamTrackProxy] is based.
 * @property source [MediaTrackSource] from which this [MediaStreamTrackProxy] is created.
 * `null` for [MediaStreamTrackProxy]s received from the remote side.
 */
class MediaStreamTrackProxy(
    track: MediaStreamTrack,
    private val deviceId: String = "remote",
    private val source: MediaTrackSource? = null
) :
    IWebRTCProxy<MediaStreamTrack> {
    /**
     * Actual underlying [MediaStreamTrack].
     */
    override var obj: MediaStreamTrack = track

    /**
     * ID of underlying [MediaStreamTrack].
     */
    private val id = track.id()

    /**
     * Subsribers for the [onStop] callback.
     *
     * Will be called once on [stop] call.
     */
    private var onStopSubscribers: MutableList<() -> Unit> = mutableListOf()

    /**
     * Indicates that this [stop] was called on this [MediaStreamTrackProxy].
     */
    private var isStopped: Boolean = false

    init {
        TrackRepository.addTrack(id, this)
    }

    override fun syncWithObject() {}

    /**
     * Returns ID of the underlying [MediaStreamTrack].
     *
     * @return ID of the underlying [MediaStreamTrack].
     */
    fun id(): String {
        return id
    }

    /**
     * @return [MediaKind] of the underlying [MediaStreamTrack].
     */
    fun kind(): MediaKind {
        return when (obj.kind()) {
            MediaStreamTrack.VIDEO_TRACK_KIND -> MediaKind.Video
            MediaStreamTrack.AUDIO_TRACK_KIND -> MediaKind.Audio
            else -> throw Exception("LibWebRTC provided unknown MediaKind value")
        }
    }

    /**
     * @return unique device ID of the underlying [MediaStreamTrack].
     */
    fun deviceId(): String {
        return deviceId
    }

    /**
     * Creates new [MediaStreamTrackProxy] based on the same [MediaTrackSource] as
     * this [MediaStreamTrackProxy].
     *
     * Can be called only on local [MediaStreamTrackProxy]s.
     *
     * @throws Exception if called on remote [MediaStreamTrackProxy].
     * @return created [MediaStreamTrackProxy].
     */
    fun clone(): MediaStreamTrackProxy {
        if (this.source == null) {
            throw Exception("Remote MediaStreamTracks can't be cloned")
        } else {
            return source.newTrack()
        }
    }

    /**
     * Stops this [MediaStreamTrackProxy].
     *
     * Media source will be disposed only if there is no another [MediaStreamTrackProxy]
     * depending on [MediaTrackSource].
     */
    fun stop() {
        if (!isStopped) {
            isStopped = true
            onStopSubscribers.forEach { sub -> sub() }
        } else {
            Log.w("FlutterWebRTC", "Double stop detected [deviceId: $deviceId]!")
        }
    }

    /**
     * @return [MediaStreamTrackState] of the underlying [MediaStreamTrack].
     */
    fun state(): MediaStreamTrackState {
        return MediaStreamTrackState.fromWebRtcState(obj.state())
    }

    /**
     * Sets enabled state of the underlying [MediaStreamTrack].
     *
     * @param enabled state which will be set to the underlying [MediaStreamTrack].
     */
    fun setEnabled(enabled: Boolean) {
        obj.setEnabled(enabled)
    }

    /**
     * Subscribes to the [stop] event of this [MediaStreamTrackProxy].
     *
     * This callback guaranteed to be called only once.
     */
    fun onStop(f: () -> Unit) {
        onStopSubscribers.add(f)
    }
}