package com.cloudwebrtc.webrtc.exception

/**
 * [Exception] which can be thrown on `getUserMedia` request.
 *
 * Indicates that all available devices are not suitable based on the provided
 * by used `Constraints`.
 */
class OverconstrainedException :
        Exception("getUserMedia failed because device matching provided Constraints is not found")