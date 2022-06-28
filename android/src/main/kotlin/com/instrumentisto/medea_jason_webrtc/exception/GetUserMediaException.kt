package com.instrumentisto.medea_jason_webrtc.exception

/**
 * [Exception] thrown on `GetUserMedia` action.
 *
 * @param message Description of the [GetUserMediaException].
 */
class GetUserMediaException(message: String?, val kind: Kind) : Exception(message) {
  enum class Kind {
    Audio,
    Video
  }
}
