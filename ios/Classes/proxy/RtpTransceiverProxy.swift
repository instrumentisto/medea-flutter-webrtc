import WebRTC

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
        if (recv) {
            switch (direction) {
                case .inactive:
                    newDirection = RTCRtpTransceiverDirection.recvOnly
                case .recvOnly:
                    newDirection = RTCRtpTransceiverDirection.recvOnly
                case .sendRecv:
                    newDirection = RTCRtpTransceiverDirection.sendRecv
                case .sendOnly:
                    newDirection = RTCRtpTransceiverDirection.sendRecv
            }
        } else {
            switch (direction) {
                case .inactive:
                    newDirection = RTCRtpTransceiverDirection.inactive
                case .recvOnly:
                    newDirection = RTCRtpTransceiverDirection.inactive
                case .sendRecv:
                    newDirection = RTCRtpTransceiverDirection.sendOnly
                case .sendOnly:
                    newDirection = RTCRtpTransceiverDirection.sendOnly
            }
        }
        
        if (newDirection != RTCRtpTransceiverDirection.stopped) {
            setDirection(direction)
        }
    }

    func setSend(send: Bool) {
        let direction = self.getDirection()
        var newDirection = RTCRtpTransceiverDirection.stopped
        if (send) {
            switch (direction) {
                case .inactive:
                    newDirection = RTCRtpTransceiverDirection.sendOnly
                case .sendOnly:
                    newDirection = RTCRtpTransceiverDirection.sendOnly
                case .sendRecv:
                    newdirection = RTCRtpTransceiverDirection.sendRecv
                case .recvOnly:
                    newDirection = RTCRtpTransceiverDirection.sendRecv
            }
        } else {
            switch (direction) {
                case .inactive:
                    newDirection = RTCRtpTransceiverDirection.inactive
                case .sendOnly:
                    newDirection = RTCRtpTransceiverDirection.inactive
                case .sendRecv:
                    newDirection = RTCRtpTransceiverDirection.recvOnly
                case .recvOnly:
                    newDirection = RTCRtpTransceiverDirection.recvOnly
            }
        }
        
        if (newDirection != RTCRtpTransceiverDirection.stopped) {
            setDirection(direction)
        }
    }

    public func getMid() -> String? {
        return transceiver.mid
    }

    public func getDirection() -> RTCRtpTransceiverDirection {
        if (self.transceiver.isStopped) {
            return RTCRtpTransceiverDirection.stopped
        } else {
            switch (self.transceiver.direction) {
                case .sendRecv:
                    return RTCRtpTransceiverDirection.sendRecv
                case .sendOnly:
                    return RTCRtpTransceiverDirection.sendOnly
                case .recvOnly:
                    return RTCRtpTransceiverDirection.recvOnly
                case .inactive:
                    return RTCRtpTransceiverDirection.inactive
            }
        }
    }

    public func stop() {
        // TODO: Fire callback on_stop
        // transceiver.stop()
    }
}