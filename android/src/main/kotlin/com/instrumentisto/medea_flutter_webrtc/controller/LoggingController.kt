package com.instrumentisto.medea_flutter_webrtc.controller

import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.webrtc.Logging

/** Controller of the global logging configuration. */
class LoggingController(messenger: BinaryMessenger) : Controller {
  /** Channel listened for the [MethodCall]s. */
  private val chan = MethodChannel(messenger, ChannelNameGenerator.name("logging", 0))

  init {
    ControllerRegistry.register(this)
    chan.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "setLogLevel" -> {
        val level: Int? = call.argument("level")
        val severity =
            when (level) {
              0 -> Logging.Severity.LS_VERBOSE
              1 -> Logging.Severity.LS_INFO
              2 -> Logging.Severity.LS_WARNING
              3 -> Logging.Severity.LS_ERROR
              else -> Logging.Severity.LS_WARNING
            }
        Logging.enableLogToDebugOutput(severity)
        result.success(null)
      }
      else -> result.notImplemented()
    }
  }

  /** Releases all the allocated resources. */
  override fun dispose() {
    ControllerRegistry.unregister(this)
    chan.setMethodCallHandler(null)
  }
}
