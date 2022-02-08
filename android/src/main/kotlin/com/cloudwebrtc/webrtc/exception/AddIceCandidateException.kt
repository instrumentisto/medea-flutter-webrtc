package com.cloudwebrtc.webrtc.exception

/**
 * [Exception] which can be thrown on `PeerConnection.addIceCandidate` action.
 *
 * @param message description of the [AddIceCandidateException].
 */
class AddIceCandidateException(message: String) : Exception(message)
