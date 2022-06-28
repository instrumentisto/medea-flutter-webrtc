package com.instrumentisto.medea_jason_webrtc.exception

/** [Exception] thrown on `RtpSenderProxy.replaceTrack` request. */
class ReplaceSenderTrackException :
    Exception("Failed to replace MediaStreamTrack of the RtpSender")
