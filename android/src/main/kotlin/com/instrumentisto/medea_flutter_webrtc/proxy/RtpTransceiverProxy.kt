package com.instrumentisto.medea_flutter_webrtc.proxy

import com.instrumentisto.medea_flutter_webrtc.model.RtpTransceiverDirection
import org.webrtc.RtpTransceiver

/** Wrapper around an [RtpTransceiver]. */
class RtpTransceiverProxy(obj: RtpTransceiver) : Proxy<RtpTransceiver>(obj) {
  /** [RtpSenderProxy] of this [RtpTransceiverProxy]. */
  private lateinit var sender: RtpSenderProxy

  /** [RtpReceiverProxy] of this [RtpTransceiverProxy]. */
  private lateinit var receiver: RtpReceiverProxy

  /** TODO */
  private var disposed: Boolean = false

  /** TODO */
  private var mid: String? = null

  init {
    syncSender()
    syncReceiver()
    addOnSyncListener {
      syncSender()
      syncReceiver()
    }
  }

  /** TODO */
  fun setDisposed() {
    disposed = true
    receiver.setDisposed()
    sender.setDisposed()
  }

  /** @return [RtpSenderProxy] of this [RtpTransceiverProxy]. */
  fun getSender(): RtpSenderProxy {
    return sender
  }

  /** @return [RtpReceiverProxy] of this [RtpTransceiverProxy]. */
  fun getReceiver(): RtpReceiverProxy {
    return receiver
  }

  /** Sets [RtpTransceiverDirection] of the underlying [RtpTransceiver]. */
  fun setDirection(direction: RtpTransceiverDirection) {
    if (!disposed) {
      obj.direction = direction.intoWebRtc()
    }
  }

  /** Sets receive of the underlying [RtpTransceiver]. */
  fun setRecv(recv: Boolean) {
    if (!disposed) {
      var currentDirection = RtpTransceiverDirection.fromWebRtc(obj)
      var newDirection =
          if (recv) {
            when (currentDirection) {
              RtpTransceiverDirection.INACTIVE -> RtpTransceiverDirection.RECV_ONLY
              RtpTransceiverDirection.RECV_ONLY -> RtpTransceiverDirection.RECV_ONLY
              RtpTransceiverDirection.SEND_RECV -> RtpTransceiverDirection.SEND_RECV
              RtpTransceiverDirection.SEND_ONLY -> RtpTransceiverDirection.SEND_RECV
              else -> {
                RtpTransceiverDirection.STOPPED
              }
            }
          } else {
            when (currentDirection) {
              RtpTransceiverDirection.INACTIVE -> RtpTransceiverDirection.INACTIVE
              RtpTransceiverDirection.RECV_ONLY -> RtpTransceiverDirection.INACTIVE
              RtpTransceiverDirection.SEND_RECV -> RtpTransceiverDirection.SEND_ONLY
              RtpTransceiverDirection.SEND_ONLY -> RtpTransceiverDirection.SEND_ONLY
              else -> {
                RtpTransceiverDirection.STOPPED
              }
            }
          }
      if (newDirection != RtpTransceiverDirection.STOPPED) {
        setDirection(newDirection)
      }
    }
  }

  /** Sets send of the underlying [RtpTransceiver]. */
  fun setSend(send: Boolean) {
    if (!disposed) {
      var currentDirection = RtpTransceiverDirection.fromWebRtc(obj)
      var newDirection =
          if (send) {
            when (currentDirection) {
              RtpTransceiverDirection.INACTIVE -> RtpTransceiverDirection.SEND_ONLY
              RtpTransceiverDirection.SEND_ONLY -> RtpTransceiverDirection.SEND_ONLY
              RtpTransceiverDirection.SEND_RECV -> RtpTransceiverDirection.SEND_RECV
              RtpTransceiverDirection.RECV_ONLY -> RtpTransceiverDirection.SEND_RECV
              else -> {
                RtpTransceiverDirection.STOPPED
              }
            }
          } else {
            when (currentDirection) {
              RtpTransceiverDirection.INACTIVE -> RtpTransceiverDirection.INACTIVE
              RtpTransceiverDirection.SEND_ONLY -> RtpTransceiverDirection.INACTIVE
              RtpTransceiverDirection.SEND_RECV -> RtpTransceiverDirection.RECV_ONLY
              RtpTransceiverDirection.RECV_ONLY -> RtpTransceiverDirection.RECV_ONLY
              else -> {
                RtpTransceiverDirection.STOPPED
              }
            }
          }
      if (newDirection != RtpTransceiverDirection.STOPPED) {
        setDirection(newDirection)
      }
    }
  }

  /** @return mID of the underlying [RtpTransceiver]. */
  fun getMid(): String? {
    if (!disposed) {
      mid = obj.mid
    }
    return mid
  }

  /** @return Preferred [RtpTransceiverDirection] of the underlying [RtpTransceiver]. */
  fun getDirection(): RtpTransceiverDirection {
    if (!disposed) {
      return RtpTransceiverDirection.fromWebRtc(obj)
    }
    return RtpTransceiverDirection.STOPPED
  }

  /** Stops the underlying [RtpTransceiver]. */
  fun stop() {
    receiver.notifyRemoved()
    if (!disposed) {
      obj.stop()
    }
  }

  /**
   * Synchronizes the [RtpSenderProxy] of this [RtpTransceiverProxy] with the underlying
   * [RtpTransceiver].
   */
  private fun syncSender() {
    val newSender = obj.sender
    if (this::sender.isInitialized) {
      sender.replace(newSender)
    } else {
      sender = RtpSenderProxy(newSender)
    }
  }

  /**
   * Synchronizes the [RtpReceiverProxy] of this [RtpTransceiverProxy] with the underlying
   * [RtpTransceiver].
   */
  private fun syncReceiver() {
    val newReceiver = obj.receiver
    if (this::receiver.isInitialized) {
      receiver.replace(newReceiver)
    } else {
      receiver = RtpReceiverProxy(newReceiver)
    }
  }
}
