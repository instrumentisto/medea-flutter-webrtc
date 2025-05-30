package com.instrumentisto.medea_flutter_webrtc.controller

import org.webrtc.ThreadUtils

/** Interface for all the controllers with unique IDs. */
interface IdentifiableController {
  companion object {
    /** Last unique ID created for this [IdentifiableController]. */
    private var counter: Long = 0
  }

  /** Declares dispose order for this controller. */
  val disposeOrder: Int

  /** Frees resources allocated by this [IdentifiableController]. */
  fun dispose()

  /** @return New unique ID for this [IdentifiableController]'s channel. */
  fun nextChannelId(): Long {
    ThreadUtils.checkIsOnMainThread()
    return counter++
  }
}
