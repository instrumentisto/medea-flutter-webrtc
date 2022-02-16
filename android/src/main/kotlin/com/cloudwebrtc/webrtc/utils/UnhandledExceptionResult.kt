package com.cloudwebrtc.webrtc.utils

import io.flutter.plugin.common.MethodChannel

/**
 * Calls [MethodChannel.Result.error] with a provided [Exception]
 * and `UnhandledException` `errorCode.
 */
fun resultUnhandledException(result: MethodChannel.Result, e: Exception) {
    result.error(
        "UnhandledException",
        "Unexpected Exception was thrown by flutter_webrtc Android",
        e
    )
}
