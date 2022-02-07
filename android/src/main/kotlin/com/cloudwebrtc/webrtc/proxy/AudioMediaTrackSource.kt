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
 */
class AudioMediaTrackSource(private val source: AudioSource, private val peerConnectionFactory: PeerConnectionFactory) : MediaTrackSource {
    private var aliveTracksCount: Int = 0;

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
        aliveTracksCount += 1;

        return track
    }

    private fun trackStopped() {
        aliveTracksCount--;
        if (aliveTracksCount == 0) {
            dispose()
        }
    }

    private fun dispose() {
        source.dispose()
    }
}