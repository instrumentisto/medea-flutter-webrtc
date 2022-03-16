#include <Windows.h>
#include <sstream>
#include <string>

#include <flutter/standard_message_codec.h>
#include <flutter/standard_method_codec.h>
#include "flutter-webrtc-native/include/api.h"
#include "flutter_webrtc.h"
#include "flutter_webrtc/flutter_web_r_t_c_plugin.h"
#include "parsing.h"

namespace flutter_webrtc_plugin {

FlutterWebRTC::FlutterWebRTC(FlutterWebRTCPlugin* plugin)
    : FlutterVideoRendererManager::FlutterVideoRendererManager(
          plugin->textures(),
          plugin->messenger()) {
  messenger_ = plugin->messenger();
}

FlutterWebRTC::~FlutterWebRTC() {}

void FlutterWebRTC::HandleMethodCall(
    const flutter::MethodCall<EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
  const std::string& method = method_call.method_name();

  if (method.compare("createVideoRenderer") == 0) {
    // dont touch
    CreateVideoRendererTexture(std::move(result));
  } else if (method.compare("videoRendererDispose") == 0) {
    VideoRendererDispose(method_call, std::move(result));
  } else if (method.compare("videoRendererSetSrcObject") == 0) {
    // create cb
    SetMediaStream(method_call, std::move(result));
  } else {
    result->NotImplemented();
  }
}

}  // namespace flutter_webrtc_plugin
