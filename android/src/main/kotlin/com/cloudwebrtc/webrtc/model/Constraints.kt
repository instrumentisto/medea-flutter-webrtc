package com.cloudwebrtc.webrtc.model

/**
 * Audio and video constraints data.
 *
 * @property audio optional constraints with which audio devices will be lookuped.
 * @property video optional constraints with which video devices will be lookuped.
 */
data class Constraints(val audio: AudioConstraints?, val video: VideoConstraints?) {
    companion object {
        /**
         * Creates new [Constraints] object based on the method call received from the Flutter.
         *
         * @return [Constraints] created from the provided [Map].
         */
        fun fromMap(map: Map<String, Any>): Constraints {
            val audioArg = map["audio"] as? Map<*, *>?
            var audio: AudioConstraints? = null
            if (audioArg != null) {
                audio = AudioConstraints.fromMap(audioArg)
            }

            val videoArg = map["video"] as Map<*, *>?
            var video: VideoConstraints? = null
            if (videoArg != null) {
                video = VideoConstraints.fromMap(videoArg)
            }

            return Constraints(audio, video)
        }
    }
}