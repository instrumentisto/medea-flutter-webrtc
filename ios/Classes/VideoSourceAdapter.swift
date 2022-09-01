import WebRTC

public class VideoSourceAdapter : NSObject, RTCVideoCapturerDelegate{
    public func capturer(_ capturer: RTCVideoCapturer, didCapture frame: RTCVideoFrame) {

    }
}

// @interface RTCVideoSourceAdapter : NSObject <RTCVideoCapturerDelegate>
// @property(nonatomic) MacCapturer* capturer;
// @end

// @implementation RTCVideoSourceAdapter
// @synthesize capturer = _capturer;

// - (void)capturer:(RTCVideoCapturer*)capturer didCaptureVideoFrame:(RTCVideoFrame*)frame {
//   const int64_t timestamp_us = frame.timeStampNs / rtc::kNumNanosecsPerMicrosec;
//   rtc::scoped_refptr<webrtc::VideoFrameBuffer> buffer =
//       rtc::make_ref_counted<webrtc::ObjCFrameBuffer>(frame.buffer);
//   _capturer->OnFrame(webrtc::VideoFrame::Builder()
//                          .set_video_frame_buffer(buffer)
//                          .set_rotation(webrtc::kVideoRotation_0)
//                          .set_timestamp_us(timestamp_us)
//                          .build());
// }

// @end