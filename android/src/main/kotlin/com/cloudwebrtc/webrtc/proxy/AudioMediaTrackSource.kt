package com.cloudwebrtc.webrtc.proxy

import android.util.Log
import com.cloudwebrtc.webrtc.utils.LocalTrackIdGenerator
import org.webrtc.AudioSource
import org.webrtc.PeerConnectionFactory

class AudioMediaTrackSource(private val source: AudioSource, private val peerConnectionFactory: PeerConnectionFactory) : MediaTrackSource {
    private var aliveTracksCount: Int = 0;

    override fun newTrack(): MediaStreamTrackProxy {
        val track = MediaStreamTrackProxy(
            peerConnectionFactory.createAudioTrack(LocalTrackIdGenerator.nextId(), source),
            "audio-1",
            this
        )
        track.onStop {
            Log.d("FOOBAR", "LocalTrack stopped");
            trackStopped()
        }
        aliveTracksCount += 1;

        return track
    }

    private fun trackStopped() {
        aliveTracksCount--;
        Log.d("FOOBAR", "Alive Audio tracks count: $aliveTracksCount")
        if (aliveTracksCount == 0) {
            Log.d("FOOBAR", "Audio source disposed");
            dispose()
        }
    }

    private fun dispose() {
        source.dispose()
    }
}