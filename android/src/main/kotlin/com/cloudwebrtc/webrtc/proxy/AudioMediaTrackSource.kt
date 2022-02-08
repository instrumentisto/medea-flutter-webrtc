package com.cloudwebrtc.webrtc.proxy

import com.cloudwebrtc.webrtc.utils.LocalTrackIdGenerator
import org.webrtc.AudioSource
import org.webrtc.PeerConnectionFactory

/**
 * Object which represents source of the input audio of the user.
 *
 * This source can create new [MediaStreamTrackProxy]s with the same audio source.
 *
 * Also, this object will track all child [MediaStreamTrackProxy]s and when they all disposed,
 * will dispose underlying [AudioSource].
 *
 * @property source underlying [AudioSource] which will be used
 * for [MediaStreamTrackProxy] creation.
 * @property peerConnectionFactory factory with which new [MediaStreamTrackProxy]s will be created.
 */
class AudioMediaTrackSource(private val source: AudioSource, private val peerConnectionFactory: PeerConnectionFactory) : MediaTrackSource {
    /**
     * Count of currently alive [MediaStreamTrackProxy] created from this [AudioMediaTrackSource].
     */
    private var aliveTracksCount: Int = 0

    /**
     * Creates new [MediaStreamTrackProxy] with the underlying [AudioSource].
     *
     * @return new [MediaStreamTrackProxy]
     */
    override fun newTrack(): MediaStreamTrackProxy {
        val track = MediaStreamTrackProxy(
                peerConnectionFactory.createAudioTrack(LocalTrackIdGenerator.nextId(), source),
                "audio-1",
                this
        )
        track.onStop {
            trackStopped()
        }
        aliveTracksCount += 1

        return track
    }

    /**
     * Function which will be called when this [AudioMediaTrackSource] is stopped.
     *
     * Decrements [aliveTracksCount] and if no [MediaStreamTrackProxy]s left, then disposes
     * this [AudioMediaTrackSource].
     */
    private fun trackStopped() {
        aliveTracksCount--
        if (aliveTracksCount == 0) {
            dispose()
        }
    }

    /**
     * Disposes this [AudioMediaTrackSource].
     */
    private fun dispose() {
        source.dispose()
    }
}