#include <Windows.h>
#include <sstream>

#include "flutter_webrtc.h"

#include "flutter_webrtc/flutter_web_r_t_c_plugin.h"

namespace flutter_webrtc_plugin {

FlutterWebRTC::FlutterWebRTC(FlutterWebRTCPlugin* plugin)
    : FlutterWebRTCBase::FlutterWebRTCBase(plugin->messenger(),
                                           plugin->textures()),
      FlutterVideoRendererManager::FlutterVideoRendererManager(this) {}

FlutterWebRTC::~FlutterWebRTC() {}

void FlutterWebRTC::HandleMethodCall(
    const flutter::MethodCall<EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
  const std::string& method = method_call.method_name();

  if (method.compare("createPeerConnection") == 0) {
  } else if (method.compare("getSources") == 0) {
    MediaStreamMethods::EnumerateDevice(webrtc, std::move(result));
  } else if (method.compare("getUserMedia") == 0) {
    MediaStreamMethods::GetUserMedia(method_call, webrtc, std::move(result));
  } else if (method.compare("getDisplayMedia") == 0) {
  } else if (method.compare("mediaStreamGetTracks") == 0) {
  } else if (method.compare("createOffer") == 0) {
  } else if (method.compare("createAnswer") == 0) {
  } else if (method.compare("addStream") == 0) {
  } else if (method.compare("removeStream") == 0) {
  } else if (method.compare("setLocalDescription") == 0) {
  } else if (method.compare("setRemoteDescription") == 0) {
  } else if (method.compare("addCandidate") == 0) {
  } else if (method.compare("getStats") == 0) {
  } else if (method.compare("createDataChannel") == 0) {
  } else if (method.compare("dataChannelSend") == 0) {
  } else if (method.compare("dataChannelClose") == 0) {
  } else if (method.compare("streamDispose") == 0) {
    MediaStreamMethods::DisposeStream(method_call, webrtc, std::move(result));
  } else if (method.compare("mediaStreamTrackSetEnable") == 0) {
    MediaStreamMethods::SetTrackEnabled(method_call, webrtc, std::move(result));
  } else if (method.compare("trackDispose") == 0) {
  } else if (method.compare("peerConnectionClose") == 0) {
  } else if (method.compare("peerConnectionDispose") == 0) {
  } else if (method_call.method_name().compare("createVideoRenderer") == 0) {
    CreateVideoRendererTexture(std::move(result));
  } else if (method_call.method_name().compare("videoRendererDispose") == 0) {
    VideoRendererDispose(method_call, webrtc, std::move(result));
  } else if (method_call.method_name().compare("videoRendererSetSrcObject") ==
             0) {
    SetMediaStream(method_call, webrtc, std::move(result));
  } else if (method.compare("setVolume") == 0) {
  } else if (method.compare("getLocalDescription") == 0) {
  } else if (method.compare("getRemoteDescription") == 0) {
  } else if (method.compare("mediaStreamAddTrack") == 0) {
  } else if (method.compare("mediaStreamRemoveTrack") == 0) {
  } else if (method.compare("addTrack") == 0) {
  } else if (method.compare("removeTrack") == 0) {
  } else if (method.compare("addTransceiver") == 0) {
  } else if (method.compare("getTransceivers") == 0) {
  } else if (method.compare("getReceivers") == 0) {
  } else if (method.compare("getSenders") == 0) {
  } else if (method.compare("rtpSenderDispose") == 0) {
  } else if (method.compare("rtpSenderSetTrack") == 0) {
  } else if (method.compare("rtpSenderReplaceTrack") == 0) {
  } else if (method.compare("rtpSenderSetParameters") == 0) {
  } else if (method.compare("rtpTransceiverStop") == 0) {
  } else if (method.compare("rtpTransceiverSetDirection") == 0) {
  } else if (method.compare("setConfiguration") == 0) {
  } else if (method.compare("captureFrame") == 0) {
  } else {
    result->NotImplemented();
  }
}

}  // namespace flutter_webrtc_plugin
