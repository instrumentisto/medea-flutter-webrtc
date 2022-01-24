package com.cloudwebrtc.webrtc.model

import org.webrtc.MediaConstraints

data class AudioConstraints(
    val mandatory: Map<String, String>,
    val optional: Map<String, String>
) {
    companion object {
        fun fromMap(map: Map<*, *>): AudioConstraints {
            val mandatoryArg =
                map["mandatory"] as Map<*, *>? ?: mapOf<String, String>()
            val optionalArg =
                map["optional"] as Map<*, *>? ?: mapOf<String, String>()
            val mandatory =
                mandatoryArg.entries.associate { it.key as String to it.value as String }
            val optional =
                optionalArg.entries.associate { it.key as String to it.value as String }

            return AudioConstraints(mandatory, optional)
        }
    }

    // TODO(evdokimovs): Maybe add some default constraints
    fun intoWebRtc(): MediaConstraints {
        val mediaConstraints = MediaConstraints()
        for (entry in mandatory) {
            mediaConstraints.mandatory.add(MediaConstraints.KeyValuePair(entry.key, entry.value))
        }
        for (entry in optional) {
            mediaConstraints.optional.add(MediaConstraints.KeyValuePair(entry.key, entry.value))
        }
        return mediaConstraints
    }
}