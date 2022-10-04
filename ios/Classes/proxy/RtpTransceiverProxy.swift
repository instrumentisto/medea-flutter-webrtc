import OSLog
import WebRTC
import os

public class RtpTransceiverProxy {
  private var transceiver: RTCRtpTransceiver
  private var sender: RtpSenderProxy
  private var receiver: RtpReceiverProxy

  init(transceiver: RTCRtpTransceiver) {
    self.sender = RtpSenderProxy(sender: transceiver.sender)
    self.receiver = RtpReceiverProxy(receiver: transceiver.receiver)
    self.transceiver = transceiver
  }

  func getSender() -> RtpSenderProxy {
    return self.sender
  }

  func getReceiver() -> RtpReceiverProxy {
    return self.receiver
  }

  func setDirection(direction: TransceiverDirection) {
    self.transceiver.setDirection(direction.intoWebRtc(), error: nil)
  }

  func setRecv(recv: Bool) {
    let direction = self.getDirection()
    var newDirection = RTCRtpTransceiverDirection.stopped
    if recv {
      switch direction {
      case .inactive:
        newDirection = RTCRtpTransceiverDirection.recvOnly
      case .recvOnly:
        newDirection = RTCRtpTransceiverDirection.recvOnly
      case .sendRecv:
        newDirection = RTCRtpTransceiverDirection.sendRecv
      case .sendOnly:
        newDirection = RTCRtpTransceiverDirection.sendRecv
      default:
        newDirection = RTCRtpTransceiverDirection.stopped
      }
    } else {
      switch direction {
      case .inactive:
        newDirection = RTCRtpTransceiverDirection.inactive
      case .recvOnly:
        newDirection = RTCRtpTransceiverDirection.inactive
      case .sendRecv:
        newDirection = RTCRtpTransceiverDirection.sendOnly
      case .sendOnly:
        newDirection = RTCRtpTransceiverDirection.sendOnly
      default:
        newDirection = RTCRtpTransceiverDirection.stopped
      }
    }

    if newDirection != RTCRtpTransceiverDirection.stopped {
      setDirection(direction: direction)
    }
  }

  func setSend(send: Bool) {
    let direction = self.getDirection()
    var newDirection = RTCRtpTransceiverDirection.stopped
    if send {
      switch direction {
      case .inactive:
        newDirection = RTCRtpTransceiverDirection.sendOnly
      case .sendOnly:
        newDirection = RTCRtpTransceiverDirection.sendOnly
      case .sendRecv:
        newDirection = RTCRtpTransceiverDirection.sendRecv
      case .recvOnly:
        newDirection = RTCRtpTransceiverDirection.sendRecv
      default:
        newDirection = RTCRtpTransceiverDirection.stopped
      }
    } else {
      switch direction {
      case .inactive:
        newDirection = RTCRtpTransceiverDirection.inactive
      case .sendOnly:
        newDirection = RTCRtpTransceiverDirection.inactive
      case .sendRecv:
        newDirection = RTCRtpTransceiverDirection.recvOnly
      case .recvOnly:
        newDirection = RTCRtpTransceiverDirection.recvOnly
      default:
        newDirection = RTCRtpTransceiverDirection.stopped
      }
    }

    if newDirection != RTCRtpTransceiverDirection.stopped {
      setDirection(direction: direction)
    }
  }

  public func getMid() -> String? {
    os_log(OSLogType.error, "getMid was called: %@", transceiver.mid)
    if transceiver.mid != nil && transceiver.mid.count == 0 {
      os_log(OSLogType.error, "getMid was called and mid is nil")
      return nil
    }
    return transceiver.mid
  }

  public func getDirection() -> TransceiverDirection {
    if self.transceiver.isStopped {
      return TransceiverDirection.stopped
    } else {
      return TransceiverDirection.fromWebRtc(direction: self.transceiver.direction)
    }
  }

  public func stop() {
    // TODO: Fire callback on_stop
    // transceiver.stop()
  }
}
