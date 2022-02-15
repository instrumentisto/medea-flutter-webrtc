package com.cloudwebrtc.webrtc.controller

/**
 * Generator for the all [io.flutter.plugin.common.MethodChannel] names created by `flutter_webrtc`.
 */
object ChannelNameGenerator {
    private const val PREFIX: String = "FlutterWebRtc"

    /**
     * Generates new channel name for some controller with a provided ID.
     *
     * @param name name of the controller for which we generate new name (e.g. `PeerConnection`).
     * @param id unique identifier of some concrete instance of some entity.
     * @return generated channel name.
     */
    fun name(name: String, id: Long): String {
        return "$PREFIX/$name/$id"
    }
}