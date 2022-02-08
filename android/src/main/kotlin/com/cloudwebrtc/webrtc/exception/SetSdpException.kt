package com.cloudwebrtc.webrtc.exception

/**
 * [Exception] which can be thrown on `PeerConnection.createOffer`/`PeerConnection.createAnswer`
 * action.
 *
 * @param message description of the [CreateSdpException].
 */
class SetSdpException(message: String) : Exception(message)
