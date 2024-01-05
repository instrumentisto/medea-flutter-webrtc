package com.instrumentisto.medea_flutter_webrtc.controller

import android.media.MediaCodecList
import com.instrumentisto.medea_flutter_webrtc.State
import com.instrumentisto.medea_flutter_webrtc.model.*
import com.instrumentisto.medea_flutter_webrtc.proxy.PeerConnectionFactoryProxy
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Controller of creating new [PeerConnectionController]s by a [PeerConnectionFactoryProxy].
 *
 * @property messenger Messenger used for creating new [MethodChannel]s.
 * @param state State used for creating new [PeerConnectionFactoryProxy]s.
 */
class PeerConnectionFactoryController(private val messenger: BinaryMessenger, state: State) :
    MethodChannel.MethodCallHandler {
  /** Factory creating new [PeerConnectionController]s. */
  private val factory: PeerConnectionFactoryProxy = PeerConnectionFactoryProxy(state)

  /** Channel listened for the [MethodCall]s. */
  private val chan = MethodChannel(messenger, ChannelNameGenerator.name("PeerConnectionFactory", 0))

  init {
    chan.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "create" -> {
        val iceTransportTypeArg: Int = call.argument("iceTransportType") ?: 0
        val iceTransportType = IceTransportType.fromInt(iceTransportTypeArg)

        val iceServersArg: List<Map<String, Any>> = call.argument("iceServers") ?: listOf()
        val iceServers: List<IceServer> =
            iceServersArg.map { serv ->
              val urlsArg = serv["urls"] as? List<*>
              val urls = urlsArg?.mapNotNull { it as? String }
              val username = serv["username"] as? String
              val password = serv["password"] as? String

              IceServer(urls ?: listOf(), username, password)
            }

        val newPeer = factory.create(PeerConnectionConfiguration(iceServers, iceTransportType))
        val peerController = PeerConnectionController(messenger, newPeer)
        result.success(peerController.asFlutterResult())
      }
      "videoEncoders" -> {
        var codecsCount = android.media.MediaCodecList.getCodecCount()
        var resultList = mutableListOf<Map<String, Any>>()
        for (i in 0 until codecsCount) {

          var info = MediaCodecList.getCodecInfoAt(i)
          if (info.isEncoder) {
            val codec = VideoCodecMimeType.values().find { it.value == info.supportedTypes[0] }
            if (codec != null) {
              val info =
                  VideoCodecInfo(
                      VideoCodecInfo.isHardwareSupportedInCurrentSdk(info), codec, info.name)
              resultList.add(info.asFlutterResult())
            }
          }
        }
        result.success(resultList)
      }
      "videoDecoders" -> {
        var codecsCount = android.media.MediaCodecList.getCodecCount()
        var resultList = mutableListOf<Map<String, Any>>()
        for (i in 0 until codecsCount) {
          var info = MediaCodecList.getCodecInfoAt(i)
          if (!info.isEncoder) {
            val codec = VideoCodecMimeType.values().find { it.value == info.supportedTypes[0] }
            if (codec != null) {
              val info =
                  VideoCodecInfo(
                      VideoCodecInfo.isHardwareSupportedInCurrentSdk(info), codec, info.name)
              resultList.add(info.asFlutterResult())
            }
          }
        }
        result.success(resultList)
      }
      "dispose" -> {
        chan.setMethodCallHandler(null)
        result.success(null)
      }
    }
  }
}
