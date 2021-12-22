#ifndef FLUTTER_WEBRTC_RTC_VIDEO_RENDERER_HXX
#define FLUTTER_WEBRTC_RTC_VIDEO_RENDERER_HXX

#include <mutex>

#include "flutter_webrtc_base.h"
#include "flutter_webrtc_native.h"

namespace flutter_webrtc_plugin {

using namespace flutter;

class FlutterVideoRenderer {
 public:
  FlutterVideoRenderer(TextureRegistrar* registrar, BinaryMessenger* messenger);

  virtual const FlutterDesktopPixelBuffer* CopyPixelBuffer(size_t width,
                                                           size_t height) const;

  void OnFrame(Frame* frame);

  // void SetVideoTrack(scoped_refptr<RTCVideoTrack> track);

  int64_t texture_id() { return texture_id_; }

  // bool CheckMediaStream(std::string mediaId);

  // bool CheckVideoTrack(std::string mediaId);

  std::string media_stream_id;

 private:
  struct FrameSize {
    size_t width;
    size_t height;
  };
  FrameSize last_frame_size_ = {0, 0};
  bool first_frame_rendered = false;
  TextureRegistrar* registrar_ = nullptr;
  std::unique_ptr<EventChannel<EncodableValue>> event_channel_;
  std::unique_ptr<EventSink<EncodableValue>> event_sink_;
  int64_t texture_id_ = -1;
  // scoped_refptr<RTCVideoTrack> track_ = nullptr;
  Frame* frame_;
  // webrtc::VideoFrame frame_;
  std::unique_ptr<flutter::TextureVariant> texture_;
  std::shared_ptr<FlutterDesktopPixelBuffer> pixel_buffer_;
  mutable std::shared_ptr<uint8_t> rgb_buffer_;
  mutable std::mutex mutex_;
  VideoRotation rotation_ = VideoRotation::kVideoRotation_0;
  mutable int count = 0;
  mutable int count_frame = 0;
};

class FlutterVideoRendererManager {
 public:
  FlutterVideoRendererManager(FlutterWebRTCBase* base);

  void CreateVideoRendererTexture(
      std::unique_ptr<MethodResult<EncodableValue>> result);

  void SetMediaStream(int64_t texture_id, const std::string& stream_id);

  void VideoRendererDispose(
      int64_t texture_id,
      std::unique_ptr<MethodResult<EncodableValue>> result);

 private:
  FlutterWebRTCBase* base_;
  std::map<int64_t, std::unique_ptr<FlutterVideoRenderer>> renderers_;
};

}  // namespace flutter_webrtc_plugin

#endif  // !FLUTTER_WEBRTC_RTC_VIDEO_RENDERER_HXX
