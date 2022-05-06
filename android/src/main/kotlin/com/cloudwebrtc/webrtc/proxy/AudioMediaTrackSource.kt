package com.cloudwebrtc.webrtc.proxy

import android.util.Log
import com.cloudwebrtc.webrtc.utils.LocalTrackIdGenerator
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import org.webrtc.AudioSource
import org.webrtc.PeerConnectionFactory
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch

/**
 * Object representing a source of an input audio of an user.
 *
 * This source can create new [MediaStreamTrackProxy]s with the same audio source.
 *
 * Also, this object will track all child [MediaStreamTrackProxy]s and when they all disposed, will
 * dispose the underlying [AudioSource].
 *
 * @property source Underlying [AudioSource] which will be used for a [MediaStreamTrackProxy]
 * creation.
 * @property peerConnectionFactory Factory with which new [MediaStreamTrackProxy]s will be created.
 */
class AudioMediaTrackSource(
    private val source: AudioSource,
    private val peerConnectionFactory: PeerConnectionFactory
) : MediaTrackSource {
  /**
   * Count of currently alive [MediaStreamTrackProxy]s created from this [AudioMediaTrackSource].
   */
  private var aliveTracksCount: Int = 0

  /**
   * Creates a new [MediaStreamTrackProxy] with the underlying [AudioSource].
   *
   * @return Newly created [MediaStreamTrackProxy].
   */
  override fun newTrack(): MediaStreamTrackProxy {
      val audioTrack = peerConnectionFactory.createAudioTrack(LocalTrackIdGenerator.nextId(), source)
      GlobalScope.launch(Dispatchers.Main) {
        while (true) {
            var i = 0
            while (i < 100) {
                i += 20
                audioTrack.setVolume(i.toDouble())
                delay(2000)
                Log.d("FOOBAR", "Volume set: " + i.toString());
            }
            while (i > 0) {
                i -= 20
                audioTrack.setVolume(i.toDouble())
                delay(2000)
                Log.d("FOOBAR", "Volume set: " + i.toString());
            }
        }
    }
    val track =
        MediaStreamTrackProxy(
            audioTrack,
            "audio-1",
            this)
    track.onStop { trackStopped() }
    aliveTracksCount += 1

    return track
  }

  /**
   * Function, called when this [AudioMediaTrackSource] is stopped.
   *
   * Decrements [aliveTracksCount] and if no [MediaStreamTrackProxy]s left, then disposes this
   * [AudioMediaTrackSource].
   */
  private fun trackStopped() {
    aliveTracksCount--
    if (aliveTracksCount == 0) {
      dispose()
    }
  }

  /** Disposes this [AudioMediaTrackSource]. */
  private fun dispose() {
    source.dispose()
  }
}
