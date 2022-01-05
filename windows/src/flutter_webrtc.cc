#include <Windows.h>
#include <sstream>

#include "flutter_webrtc.h"

#include <flutter_webrtc_native.h>
#include "flutter_webrtc/flutter_web_r_t_c_plugin.h"

#define DEFAULT_WIDTH 640
#define DEFAULT_HEIGHT 480
#define DEFAULT_FPS 30

namespace flutter_webrtc_plugin {

// template <typename T>
// inline bool TypeIs(const EncodableValue val) {
//   return std::holds_alternative<T>(val);
// }

// template <typename T>
// inline const T GetValue(EncodableValue val) {
//   return std::get<T>(val);
// }

// inline EncodableMap findMap(const EncodableMap& map, const std::string& key)
// {
//   auto it = map.find(EncodableValue(key));
//   if (it != map.end() && TypeIs<EncodableMap>(it->second))
//     return GetValue<EncodableMap>(it->second);
//   return EncodableMap();
// }

// inline std::string findString(const EncodableMap& map, const std::string&
// key) {
//   auto it = map.find(EncodableValue(key));
//   if (it != map.end() && TypeIs<std::string>(it->second))
//     return GetValue<std::string>(it->second);
//   return std::string();
// }

FlutterWebRTC::FlutterWebRTC(FlutterWebRTCPlugin* plugin)
    : FlutterWebRTCBase::FlutterWebRTCBase(plugin->messenger(),
                                           plugin->textures()),
      FlutterVideoRendererManager::FlutterVideoRendererManager(this) {}

FlutterWebRTC::~FlutterWebRTC() {}

void FlutterWebRTC::HandleMethodCall(
    const flutter::MethodCall<EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
  if (method_call.method_name().compare("createPeerConnection") == 0) {
  } else if (method_call.method_name().compare("getSources") == 0) {
    rust::Vec<MediaDeviceInfo> devices = EnumerateDevices(webrtc);

    EncodableList sources;

    for (size_t i = 0; i < devices.size(); ++i) {
      std::string kind;
      switch (devices[i].kind) {
        case MediaDeviceKind::kAudioInput:
          kind = "audioinput";
          break;

        case MediaDeviceKind::kAudioOutput:
          kind = "audiooutput";
          break;

        case MediaDeviceKind::kVideoInput:
          kind = "videoinput";
          break;

        default:
          throw std::exception("Invalid MediaDeviceKind");
      }

      EncodableMap info;
      info[EncodableValue("label")] =
          EncodableValue(std::string(devices[i].label));
      info[EncodableValue("deviceId")] =
          EncodableValue(std::string(devices[i].device_id));
      info[EncodableValue("kind")] = EncodableValue(kind);
      info[EncodableValue("groupId")] = EncodableValue(std::string(""));

      sources.push_back(EncodableValue(info));
    }

    EncodableMap params;
    params[EncodableValue("sources")] = EncodableValue(sources);
    result->Success(EncodableValue(params));
  } else if (method_call.method_name().compare("getUserMedia") == 0) {
    if (!method_call.arguments()) {
      result->Error("Bad Arguments", "Null constraints arguments received");
      return;
    }

    Constraints cnstrts;
    VideoConstraints vdcntsrts;

    const EncodableMap param_constrs =
        GetValue<EncodableMap>(*method_call.arguments());
    const EncodableMap constraints = findMap(param_constrs, "constraints");

    auto audio_constraints = constraints.find(EncodableValue("audio"))->second;

    if ((TypeIs<bool>(audio_constraints) &&
         GetValue<bool>(audio_constraints)) ||
        TypeIs<EncodableMap>(audio_constraints)) {
      cnstrts.audio = true;
    } else {
      cnstrts.audio = false;
    }

    EncodableMap video_mandatory;
    auto it = constraints.find(EncodableValue("video"));
    EncodableMap video_map = GetValue<EncodableMap>(it->second);
    video_mandatory = GetValue<EncodableMap>(
        video_map.find(EncodableValue("mandatory"))->second);

    EncodableValue widthValue =
        video_mandatory.find(EncodableValue("minWidth"))->second;

    EncodableValue heightValue =
        video_mandatory.find(EncodableValue("minHeight"))->second;

    EncodableValue fpsValue =
        video_mandatory.find(EncodableValue("minFrameRate"))->second;

    vdcntsrts.min_width = rust::String(GetValue<std::string>(widthValue));
    vdcntsrts.min_height = rust::String(GetValue<std::string>(heightValue));
    vdcntsrts.min_fps = rust::String(GetValue<std::string>(fpsValue));
    cnstrts.video = vdcntsrts;

    LocalStreamInfo user_media = GetUserMedia(webrtc, cnstrts);

    EncodableMap params;
    params[EncodableValue("streamId")] =
        EncodableValue(user_media.stream_id.c_str());

    EncodableList videoTracks;
    if (user_media.video_tracks.size() == 0) {
      params[EncodableValue("videoTracks")] = EncodableValue(EncodableList());
    } else {
      for (size_t i = 0; i < user_media.video_tracks.size(); ++i) {
        EncodableMap info;
        info[EncodableValue("id")] =
            EncodableValue(user_media.video_tracks[i].id.c_str());
        info[EncodableValue("label")] =
            EncodableValue(user_media.video_tracks[i].label.c_str());
        info[EncodableValue("kind")] = EncodableValue(
            user_media.video_tracks[i].kind == TrackKind::Video ? "video"
                                                                : "audio");
        info[EncodableValue("enabled")] =
            EncodableValue(user_media.video_tracks[i].enabled);

        videoTracks.push_back(EncodableValue(info));
      }
    }
    params[EncodableValue("videoTracks")] = EncodableValue(videoTracks);

    EncodableList audioTracks;
    if (user_media.audio_tracks.size() == 0) {
      params[EncodableValue("audioTracks")] = EncodableValue(EncodableList());
    } else {
      for (size_t i = 0; i < user_media.audio_tracks.size(); ++i) {
        EncodableMap info;
        info[EncodableValue("id")] =
            EncodableValue(user_media.audio_tracks[i].id.c_str());
        info[EncodableValue("label")] =
            EncodableValue(user_media.audio_tracks[i].label.c_str());
        info[EncodableValue("kind")] = EncodableValue(
            user_media.audio_tracks[i].kind == TrackKind::Video ? "video"
                                                                : "audio");
        info[EncodableValue("enabled")] =
            EncodableValue(user_media.audio_tracks[i].enabled);

        audioTracks.push_back(EncodableValue(info));
      }
    }
    params[EncodableValue("audioTracks")] = EncodableValue(audioTracks);

    result->Success(EncodableValue(params));
  } else if (method_call.method_name().compare("test") == 0) {
    // testfl();
  } else if (method_call.method_name().compare("getDisplayMedia") == 0) {
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
  } else if (method_call.method_name().compare("mediaStreamGetTracks") == 0) {
  } else if (method_call.method_name().compare("createOffer") == 0) {
  } else if (method_call.method_name().compare("createAnswer") == 0) {
  } else if (method_call.method_name().compare("addStream") == 0) {
  } else if (method_call.method_name().compare("removeStream") == 0) {
  } else if (method_call.method_name().compare("setLocalDescription") == 0) {
  } else if (method_call.method_name().compare("setRemoteDescription") == 0) {
  } else if (method_call.method_name().compare("addCandidate") == 0) {
  } else if (method_call.method_name().compare("getStats") == 0) {
  } else if (method_call.method_name().compare("createDataChannel") == 0) {
  } else if (method_call.method_name().compare("dataChannelSend") == 0) {
  } else if (method_call.method_name().compare("dataChannelClose") == 0) {
  } else if (method_call.method_name().compare("streamDispose") == 0) {
    const EncodableMap params =
        GetValue<EncodableMap>(*method_call.arguments());
    const std::string stream_id = findString(params, "streamId");
    DisposeStream(webrtc, rust::String(stream_id));
    result->Success();
  } else if (method_call.method_name().compare("mediaStreamTrackSetEnable") ==
             0) {
  } else if (method_call.method_name().compare("trackDispose") == 0) {
  } else if (method_call.method_name().compare("peerConnectionClose") == 0) {
  } else if (method_call.method_name().compare("peerConnectionDispose") == 0) {
  } else if (method_call.method_name().compare("createVideoRenderer") == 0) {
    CreateVideoRendererTexture(std::move(result));
  } else if (method_call.method_name().compare("videoRendererDispose") == 0) {
    if (!method_call.arguments()) {
      result->Error("Bad Arguments", "Null constraints arguments received");
      return;
    }
    const EncodableMap params =
        GetValue<EncodableMap>(*method_call.arguments());
    int64_t texture_id = findLongInt(params, "textureId");
    VideoRendererDispose(webrtc, texture_id, std::move(result));
  } else if (method_call.method_name().compare("videoRendererSetSrcObject") ==
             0) {
    if (!method_call.arguments()) {
      result->Error("Bad Arguments", "Null constraints arguments received");
      return;
    }

    const EncodableMap params =
        GetValue<EncodableMap>(*method_call.arguments());
    const std::string stream_id = findString(params, "streamId");
    int64_t texture_id = findLongInt(params, "textureId");
    SetMediaStream(webrtc, texture_id, stream_id);
    result->Success();
  } else if (method_call.method_name().compare("setVolume") == 0) {
  } else if (method_call.method_name().compare("getLocalDescription") == 0) {
  } else if (method_call.method_name().compare("getRemoteDescription") == 0) {
  } else if (method_call.method_name().compare("mediaStreamAddTrack") == 0) {
  } else if (method_call.method_name().compare("mediaStreamRemoveTrack") == 0) {
  } else if (method_call.method_name().compare("addTrack") == 0) {
  } else if (method_call.method_name().compare("removeTrack") == 0) {
  } else if (method_call.method_name().compare("addTransceiver") == 0) {
  } else if (method_call.method_name().compare("getTransceivers") == 0) {
  } else if (method_call.method_name().compare("getReceivers") == 0) {
  } else if (method_call.method_name().compare("getSenders") == 0) {
  } else if (method_call.method_name().compare("rtpSenderDispose") == 0) {
  } else if (method_call.method_name().compare("rtpSenderSetTrack") == 0) {
  } else if (method_call.method_name().compare("rtpSenderReplaceTrack") == 0) {
  } else if (method_call.method_name().compare("rtpSenderSetParameters") == 0) {
  } else if (method_call.method_name().compare("rtpTransceiverStop") == 0) {
  } else if (method_call.method_name().compare("rtpTransceiverSetDirection") ==
             0) {
  } else if (method_call.method_name().compare("setConfiguration") == 0) {
  } else if (method_call.method_name().compare("captureFrame") == 0) {
  } else {
    result->NotImplemented();
  }
}

}  // namespace flutter_webrtc_plugin
