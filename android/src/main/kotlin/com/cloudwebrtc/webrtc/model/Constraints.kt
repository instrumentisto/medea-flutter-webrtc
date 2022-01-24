package com.cloudwebrtc.webrtc.model

data class Constraints(val audio: AudioConstraints?, val video: VideoConstraints?) {
    companion object {
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