#include "media_stream.h"

void enumerate_device(Box<Webrtc>& webrtc, std::unique_ptr<MethodResult<EncodableValue>> result) {
  rust::Vec<MediaDeviceInfo> devices = webrtc->EnumerateDevices();

  EncodableList sources;

  for (size_t i = 0; i < devices.size(); ++i) {
    std::string kind;
    switch (devices[i].kind) {
    case MediaDeviceKind::kAudioInput:kind = "audioinput";
      break;

    case MediaDeviceKind::kAudioOutput:kind = "audiooutput";
      break;

    case MediaDeviceKind::kVideoInput:kind = "videoinput";
      break;

    default:throw std::exception("Invalid MediaDeviceKind");
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
}

void get_user_media(EncodableMap constraints_arg, Box<Webrtc>& webrtc, std::unique_ptr<MethodResult<EncodableValue>> result) {
  auto video_arg = constraints_arg.find(EncodableValue("video"));
  auto audio_arg = constraints_arg.find(EncodableValue("audio"));

  MediaStreamConstraints constraints;

  auto video_constraints = parse_video_constraints(video_arg->second, result.get());
  if (!video_constraints.has_value()) return;
  constraints.video = video_constraints.value();
  constraints.audio = parse_audio_constraints(audio_arg->second);

  MediaStream user_media = webrtc->GetUserMedia(constraints);

  EncodableMap params;
  params[EncodableValue("streamId")] =
    EncodableValue(std::to_string(user_media.stream_id).c_str());

  EncodableList video_tracks;
  if (user_media.video_tracks.size() == 0) {
    params[EncodableValue("videoTracks")] = EncodableValue(EncodableList());
  } else {
    for (size_t i = 0; i < user_media.video_tracks.size(); ++i) {
      EncodableMap info;
      info[EncodableValue("id")] = EncodableValue(
        std::to_string(user_media.video_tracks[i].id).c_str());
      info[EncodableValue("label")] =
        EncodableValue(user_media.video_tracks[i].label.c_str());
      info[EncodableValue("kind")] = EncodableValue(
        user_media.video_tracks[i].kind == TrackKind::kVideo ? "video"
        : "audio");
      info[EncodableValue("enabled")] =
        EncodableValue(user_media.video_tracks[i].enabled);

      video_tracks.push_back(EncodableValue(info));
    }
  }
  params[EncodableValue("videoTracks")] = EncodableValue(video_tracks);

  EncodableList audio_tracks;
  if (user_media.audio_tracks.size() == 0) {
    params[EncodableValue("audioTracks")] = EncodableValue(EncodableList());
  } else {
    for (size_t i = 0; i < user_media.audio_tracks.size(); ++i) {
      EncodableMap info;
      info[EncodableValue("id")] = EncodableValue(
        std::to_string(user_media.audio_tracks[i].id).c_str());
      info[EncodableValue("label")] =
        EncodableValue(user_media.audio_tracks[i].label.c_str());
      info[EncodableValue("kind")] = EncodableValue(
        user_media.audio_tracks[i].kind == TrackKind::kVideo ? "video"
        : "audio");
      info[EncodableValue("enabled")] =
        EncodableValue(user_media.audio_tracks[i].enabled);

      audio_tracks.push_back(EncodableValue(info));
    }
  }
  params[EncodableValue("audioTracks")] = EncodableValue(audio_tracks);

  result->Success(EncodableValue(params));
}

std::optional<VideoConstraints> parse_video_constraints(EncodableValue video_arg, MethodResult<EncodableValue>* result) {
  EncodableMap video_mandatory;

  EncodableValue width;
  EncodableValue height;
  EncodableValue fps;
  EncodableValue video_device_id;
  bool video_required;

  if (TypeIs<bool>(video_arg)) {
    if (GetValue<bool>(video_arg)) {
      width = DEFAULT_WIDTH;
      height = DEFAULT_HEIGHT;
      fps = DEFAULT_FPS;
      video_required = true;
    } else {
      width = 0;
      height = 0;
      fps = 0;
      video_required = false;
    }
    video_device_id = std::string();
  } else {
    EncodableMap video_map = GetValue<EncodableMap>(video_arg);
    video_mandatory = GetValue<EncodableMap>(
      video_map.find(EncodableValue("mandatory"))->second);
    width = video_mandatory.find(EncodableValue("minWidth"))->second;
    height = video_mandatory.find(EncodableValue("minHeight"))->second;
    fps = video_mandatory.find(EncodableValue("minFrameRate"))->second;
    video_required = true;

    video_device_id = findString(video_map, "device_id");

    if (std::stoi(GetValue<std::string>(width)) < 1) {
      result->Error("Bad Arguments", "Null width recieved.");
      return std::nullopt;
    }

    if (std::stoi(GetValue<std::string>(height)) < 1) {
      result->Error("Bad Arguments", "Null height recieved.");
      return std::nullopt;
    }

    if (std::stoi(GetValue<std::string>(fps)) < 1) {
      result->Error("Bad Arguments", "Null FPS recieved.");
      return std::nullopt;
    }
  }

  VideoConstraints video_constraints;

  video_constraints.min_width = std::stoi(GetValue<std::string>(width));
  video_constraints.min_height = std::stoi(GetValue<std::string>(height));
  video_constraints.min_fps = std::stoi(GetValue<std::string>(fps));
  video_constraints.device_id =
    rust::String(GetValue<std::string>(video_device_id));
  video_constraints.required = video_required;

  return video_constraints;
}

AudioConstraints parse_audio_constraints(EncodableValue audio_arg) {
  EncodableValue audio_device_id;
  bool audio_required;

  if (TypeIs<bool>(audio_arg)) {
    if (GetValue<bool>(audio_arg)) {
      audio_required = true;
    } else {
      audio_required = false;
    }
    audio_device_id = std::string();
  } else {
    EncodableMap audio_map = GetValue<EncodableMap>(audio_arg);
    audio_device_id = findString(audio_map, "device_id");
    audio_required = true;
  }

  AudioConstraints audio_constraints;

  audio_constraints.required = audio_required;
  audio_constraints.device_id =
    rust::String(GetValue<std::string>(audio_device_id));

  return audio_constraints;
}
