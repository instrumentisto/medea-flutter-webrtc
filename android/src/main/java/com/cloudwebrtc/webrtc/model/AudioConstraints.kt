package com.cloudwebrtc.webrtc.model

import org.webrtc.MediaConstraints

data class AudioConstraints(val mandatory: HashMap<String, String>, val optional: HashMap<String, String>) {
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