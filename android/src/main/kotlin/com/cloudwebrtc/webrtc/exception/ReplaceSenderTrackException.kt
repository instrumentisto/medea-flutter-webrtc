package com.cloudwebrtc.webrtc.exception

/**
 * [Exception] which can be thrown on `RtpSenderProxy.replaceTrack` request.
 */
class ReplaceSenderTrackException :
        Exception("Failed to replace MediaStreamTrack of the RtpSender")
