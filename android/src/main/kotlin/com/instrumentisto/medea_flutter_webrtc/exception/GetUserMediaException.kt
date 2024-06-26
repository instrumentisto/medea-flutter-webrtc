package com.instrumentisto.medea_flutter_webrtc.exception

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
