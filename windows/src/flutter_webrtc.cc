#include <Windows.h>
#include <sstream>
#include <string>

#include "flutter_webrtc.h"
#include "flutter_webrtc/flutter_web_r_t_c_plugin.h"
#include "media_stream.h"
#include "peer_connection.h"

#define DEFAULT_WIDTH 640
#define DEFAULT_HEIGHT 480
#define DEFAULT_FPS 30

namespace flutter_webrtc_plugin {

FlutterWebRTC::FlutterWebRTC(FlutterWebRTCPlugin* plugin)
    : FlutterVideoRendererManager::FlutterVideoRendererManager(
          plugin->textures(),
          plugin->messenger()) {}

FlutterWebRTC::~FlutterWebRTC() {}

void FlutterWebRTC::HandleMethodCall(
    const flutter::MethodCall<EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
  const std::string& method = method_call.method_name();

  if (method.compare("createPeerConnection") == 0) {
    CreateRTCPeerConnection(webrtc, method_call, std::move(result));
  } else if (method.compare("getSources") == 0) {
    EnumerateDevice(webrtc, std::move(result));
  } else if (method.compare("getUserMedia") == 0) {
    GetUserMedia(method_call, webrtc, std::move(result));
  } else if (method.compare("getDisplayMedia") == 0) {
    if (!method_call.arguments()) {
      result->Error("Bad Arguments", "Null constraints arguments received");
      return;
    }

    LocalStreamInfo display_media = GetDisplayMedia(webrtc);

    EncodableMap params;
    params[EncodableValue("streamId")] =
        EncodableValue(display_media.stream_id.c_str());

    EncodableList videoTracks;
    if (display_media.video_tracks.size() == 0) {
      params[EncodableValue("videoTracks")] = EncodableValue(EncodableList());
    } else {
      for (size_t i = 0; i < display_media.video_tracks.size(); ++i) {
        EncodableMap info;
        info[EncodableValue("id")] =
            EncodableValue(display_media.video_tracks[i].id.c_str());
        info[EncodableValue("label")] =
            EncodableValue(display_media.video_tracks[i].label.c_str());
        info[EncodableValue("kind")] = EncodableValue(
            display_media.video_tracks[i].kind == TrackKind::Video ? "video"
                                                                   : "audio");
        info[EncodableValue("enabled")] =
            EncodableValue(display_media.video_tracks[i].enabled);

        videoTracks.push_back(EncodableValue(info));
      }
    }
    params[EncodableValue("videoTracks")] = EncodableValue(videoTracks);

    EncodableList audioTracks;
    // if (display_media.audio_tracks.size() == 0) {
    params[EncodableValue("audioTracks")] = EncodableValue(EncodableList());
    // } else {
    //   for (size_t i = 0; i < display_media.audio_tracks.size(); ++i) {
    //     EncodableMap info;
    //     info[EncodableValue("id")] =
    //         EncodableValue(display_media.audio_tracks[i].id.c_str());
    //     info[EncodableValue("label")] =
    //         EncodableValue(display_media.audio_tracks[i].label.c_str());
    //     info[EncodableValue("kind")] = EncodableValue(
    //         display_media.audio_tracks[i].kind == TrackKind::Video ? "video"
    //                                                                :
    //                                                                "audio");
    //     info[EncodableValue("enabled")] =
    //         EncodableValue(display_media.audio_tracks[i].enabled);

    //     audioTracks.push_back(EncodableValue(info));
    //   }
    // }
    params[EncodableValue("audioTracks")] = EncodableValue(audioTracks);

    result->Success(EncodableValue(params));
  } else if (method.compare("mediaStreamGetTracks") == 0) {
  } else if (method.compare("createOffer") == 0) {
    CreateOffer(webrtc, method_call, std::move(result));
  } else if (method.compare("createAnswer") == 0) {
    CreateAnswer(webrtc, method_call, std::move(result));
  } else if (method.compare("addStream") == 0) {
  } else if (method.compare("removeStream") == 0) {
  } else if (method.compare("setLocalDescription") == 0) {
    SetLocalDescription(webrtc, method_call, std::move(result));
  } else if (method.compare("setRemoteDescription") == 0) {
    SetRemoteDescription(webrtc, method_call, std::move(result));
  } else if (method.compare("addCandidate") == 0) {
  } else if (method.compare("getStats") == 0) {
  } else if (method.compare("createDataChannel") == 0) {
  } else if (method.compare("dataChannelSend") == 0) {
  } else if (method.compare("dataChannelClose") == 0) {
  } else if (method.compare("streamDispose") == 0) {
    DisposeStream(method_call, webrtc, std::move(result));
  } else if (method.compare("mediaStreamTrackSetEnable") == 0) {
  } else if (method.compare("trackDispose") == 0) {
  } else if (method.compare("peerConnectionClose") == 0) {
  } else if (method.compare("peerConnectionDispose") == 0) {
  } else if (method.compare("createVideoRenderer") == 0) {
    CreateVideoRendererTexture(std::move(result));
  } else if (method.compare("videoRendererDispose") == 0) {
    VideoRendererDispose(method_call, webrtc, std::move(result));
  } else if (method.compare("videoRendererSetSrcObject") == 0) {
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
