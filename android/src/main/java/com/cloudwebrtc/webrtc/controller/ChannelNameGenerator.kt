package com.cloudwebrtc.webrtc.controller

object ChannelNameGenerator {
    private const val CHANNEL_NAME_TAG: String = "com.instrumentisto.flutter_webrtc"

    fun withId(entityName: String, id: Int): String {
        return "${withoutId(entityName)}/$id"
    }

    fun withoutId(entityName: String): String {
        return "$CHANNEL_NAME_TAG/$entityName"
    }
}