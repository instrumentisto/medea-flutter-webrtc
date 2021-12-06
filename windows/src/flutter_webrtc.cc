#include <Windows.h>
#include <sstream>

#include "flutter_webrtc.h"

#include <flutter_webrtc_native.h>
#include "flutter_webrtc/flutter_web_r_t_c_plugin.h"

#define DEFAULT_WIDTH 640
#define DEFAULT_HEIGHT 480
#define DEFAULT_FPS 30

namespace flutter_webrtc_plugin {

template <typename T>
inline bool TypeIs(const EncodableValue val) {
  return std::holds_alternative<T>(val);
}

template <typename T>
inline const T GetValue(EncodableValue val) {
  return std::get<T>(val);
}

inline EncodableMap findMap(const EncodableMap& map, const std::string& key) {
  auto it = map.find(EncodableValue(key));
  if (it != map.end() && TypeIs<EncodableMap>(it->second))
    return GetValue<EncodableMap>(it->second);
  return EncodableMap();
}

inline int toInt(EncodableValue inputVal, int defaultVal) {
  int intValue = defaultVal;
  if (TypeIs<int>(inputVal)) {
    intValue = GetValue<int>(inputVal);
  } else if (TypeIs<int32_t>(inputVal)) {
    intValue = GetValue<int32_t>(inputVal);
  } else if (TypeIs<std::string>(inputVal)) {
    intValue = atoi(GetValue<std::string>(inputVal).c_str());
  }
  return intValue;
}

inline std::string findString(const EncodableMap& map, const std::string& key) {
  auto it = map.find(EncodableValue(key));
  if (it != map.end() && TypeIs<std::string>(it->second))
    return GetValue<std::string>(it->second);
  return std::string();
}

FlutterWebRTC::FlutterWebRTC(FlutterWebRTCPlugin* plugin) {}

FlutterWebRTC::~FlutterWebRTC() {}

void FlutterWebRTC::HandleMethodCall(
    const flutter::MethodCall<EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
  if (method_call.method_name().compare("createPeerConnection") == 0) {
  } else if (method_call.method_name().compare("getSources") == 0) {
    rust::Vec<DeviceInfo> devices = enumerate_devices();

    EncodableList sources;

    for (size_t i = 0; i < devices.size(); ++i) {
      EncodableMap info;
      info[EncodableValue("label")] =
          EncodableValue(std::string(devices[i].label));
      info[EncodableValue("deviceId")] =
          EncodableValue(std::string(devices[i].deviceId));
      info[EncodableValue("kind")] =
          EncodableValue(std::string(devices[i].kind));
      info[EncodableValue("groupId")] = EncodableValue(std::string(""));

      sources.push_back(EncodableValue(info));
    }

    EncodableMap params;
    params[EncodableValue("sources")] = EncodableValue(sources);
    result->Success(EncodableValue(params));
  } else if (method_call.method_name().compare("test") == 0) {
  } else if (method_call.method_name().compare("getUserMedia") == 0) {
    if (!method_call.arguments()) {
      result->Error("Bad Arguments", "Null constraints arguments received");
      return;
    }

    const EncodableMap param_constrs =
        GetValue<EncodableMap>(*method_call.arguments());
    const EncodableMap constraints = findMap(param_constrs, "constraints");

    EncodableMap params;
    rust::String stream_id = "test_stream_id";
    create_local_stream(webrtc, stream_id);
    params[EncodableValue("streamId")] = EncodableValue(stream_id.c_str());

    auto audio_constraints = constraints.find(EncodableValue("audio"))->second;

    if ((TypeIs<bool>(audio_constraints) &&
         GetValue<bool>(audio_constraints)) ||
        TypeIs<EncodableMap>(audio_constraints)) {
      std::string audio_source_id = "test_audio_source_id";
      std::string audio_track_id = "test_audio_track_id";

      create_local_audio_source(webrtc, audio_source_id);
      create_local_audio_track(webrtc, audio_track_id, audio_source_id);

      add_audio_track_to_local(webrtc, stream_id, audio_track_id);

      EncodableMap track_info;
      track_info[EncodableValue("id")] = EncodableValue(audio_track_id);
      track_info[EncodableValue("label")] = EncodableValue(audio_track_id);
      track_info[EncodableValue("kind")] = EncodableValue("audio");
      track_info[EncodableValue("enabled")] = EncodableValue(true);

      EncodableList audioTracks;
      audioTracks.push_back(EncodableValue(track_info));
      params[EncodableValue("audioTracks")] = EncodableValue(audioTracks);
    } else {
      params[EncodableValue("audioTracks")] = EncodableValue(EncodableList());
    }

    std::string video_source_id = "test_video_source_id";
    std::string video_track_id = "test_video_track_id";

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

    create_local_video_source(webrtc, video_source_id,
                              rust::String(GetValue<std::string>(widthValue)),
                              rust::String(GetValue<std::string>(heightValue)),
                              rust::String(GetValue<std::string>(fpsValue)));

    create_local_video_track(webrtc, video_track_id, video_source_id);

    add_video_track_to_local(webrtc, stream_id, video_track_id);

    EncodableList videoTracks;
    EncodableMap info;
    info[EncodableValue("id")] = EncodableValue(video_track_id);
    info[EncodableValue("label")] = EncodableValue(video_track_id);
    info[EncodableValue("kind")] = EncodableValue("video");
    info[EncodableValue("enabled")] = EncodableValue(true);
    videoTracks.push_back(EncodableValue(info));
    params[EncodableValue("videoTracks")] = EncodableValue(videoTracks);

    result->Success(EncodableValue(params));
  } else if (method_call.method_name().compare("getDisplayMedia") == 0) {
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
    dispose_stream(webrtc, rust::String(stream_id));
    result->Success();
  } else if (method_call.method_name().compare("mediaStreamTrackSetEnable") ==
             0) {
  } else if (method_call.method_name().compare("trackDispose") == 0) {
  } else if (method_call.method_name().compare("peerConnectionClose") == 0) {
  } else if (method_call.method_name().compare("createVideoRenderer") == 0) {
  } else if (method_call.method_name().compare("videoRendererDispose") == 0) {
  } else if (method_call.method_name().compare("videoRendererSetSrcObject") ==
             0) {
  } else if (method_call.method_name().compare(
                 "mediaStreamTrackSwitchCamera") == 0) {
  } else if (method_call.method_name().compare("setVolume") == 0) {
  } else {
    result->NotImplemented();
  }
}

}  // namespace flutter_webrtc_plugin
