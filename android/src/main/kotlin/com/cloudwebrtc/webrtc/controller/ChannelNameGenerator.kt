package com.cloudwebrtc.webrtc.controller

/**
 * Generator for the all [io.flutter.plugin.common.MethodChannel] names created by `flutter_webrtc`.
 */
object ChannelNameGenerator {
    private const val CHANNEL_NAME_TAG: String = "FlutterWebRtc"

    /**
     * Generates new channel name for some controller with a provided ID.
     *
     * @param controllerName name of the controller for which we generate new name (e.g. `PeerConnection`).
     * @param id unique identifier of some concrete instance of some entity.
     * @return generated channel name.
     */
    fun withId(controllerName: String, id: Int): String {
        return "${withoutId(controllerName)}/$id"
    }

    /**
     * Generates new channel name for some singleton controller.
     *
     * @param controllerName name of the singleton controller for which new channel name will be generated (e.g. `PeerConnection`).
     * @return generated channel name.
     */
    fun withoutId(controllerName: String): String {
        return "$CHANNEL_NAME_TAG/$controllerName"
    }
}