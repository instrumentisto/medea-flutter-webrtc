#include "video_capture_mac.h"
#import "api/media_stream_interface.h"
#import "sdk/objc/api/peerconnection/RTCAudioSource+Private.h"
#import "sdk/objc/api/peerconnection/RTCAudioTrack+Private.h"
#import "sdk/objc/api/peerconnection/RTCMediaConstraints+Private.h"
#import "sdk/objc/native/src/objc_frame_buffer.h"
#import "sdk/objc/api/peerconnection/RTCMediaStream+Private.h"
#import "sdk/objc/native/api/video_capturer.h"
#import "sdk/objc/api/peerconnection/RTCPeerConnection+Private.h"
#import "sdk/objc/api/peerconnection/RTCVideoTrack+Private.h"
#import "sdk/objc/api/peerconnection/RTCVideoTrack+Private.h"
#import "sdk/objc/base/RTCVideoCapturer.h"
#import "api/media_stream_interface.h"
#import "sdk/objc/native/src/objc_video_track_source.h"
#import "api/video_track_source_proxy_factory.h"
#import "sdk/objc/components/capturer/RTCCameraVideoCapturer.h"

@interface RTCTestVideoSourceAdapter : NSObject <RTC_OBJC_TYPE (RTCVideoCapturerDelegate)>
@property(nonatomic) VideoCaptureMac *capturer;
@end

@implementation RTCTestVideoSourceAdapter
@synthesize capturer = _capturer;

- (void)capturer:(RTC_OBJC_TYPE(RTCVideoCapturer) *)capturer
didCaptureVideoFrame:(RTC_OBJC_TYPE(RTCVideoFrame) *)frame {
//    const int64_t timestamp_us = frame.timeStampNs / rtc::kNumNanosecsPerMicrosec;
//    rtc::scoped_refptr<webrtc::VideoFrameBuffer> buffer =
//            rtc::make_ref_counted<webrtc::ObjCFrameBuffer>(frame.buffer);
//    _capturer->OnFrame(webrtc::VideoFrame::Builder()
//                               .set_video_frame_buffer(buffer)
//                               .set_rotation(webrtc::kVideoRotation_0)
//                               .set_timestamp_us(timestamp_us)
//                               .build());
}

@end

rtc::scoped_refptr<webrtc::VideoTrackSourceInterface> create_video_track_source(
        webrtc::PeerConnectionFactoryInterface& factory,
        rtc::Thread& worker_thread,
        rtc::Thread& signaling_thread,
        size_t width,
        size_t height,
        size_t fps,
        uint32_t device
) {
    NSLog(@"create_video_track_source 1");
    RTCTestVideoSourceAdapter *adapter = [[RTCTestVideoSourceAdapter alloc] init];
    RTCCameraVideoCapturer *capturer = [[RTCCameraVideoCapturer alloc] initWithDelegate:adapter];
    NSLog(@"create_video_track_source 2");

    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSArray<AVCaptureDeviceFormat *> *formats = [RTCCameraVideoCapturer supportedFormatsForDevice:videoDevice];
    AVCaptureDeviceFormat *format = formats[0];
    NSInteger target_fps = 30;
    NSLog(@"create_video_track_source 3");

    [capturer startCaptureWithDevice:videoDevice format:format fps:target_fps];
    NSLog(@"create_video_track_source 4");
    return webrtc::ObjCToNativeVideoCapturer(capturer, &worker_thread, &signaling_thread);
//    return objcVideoTrackSource;

//    return objcVideoTrackSource;

//    RTCVideoSource* videoSource = [[RTCVideoSource alloc]
//            initWithFactory:&factory, webrtc::CreateVideoTrackSourceProxy(&signaling_thread,
//                                                                            &worker_thread,
//                                                                            objcVideoTrackSource)];
//    AVCaptureDevice *videoDevice = [AVCaptureDevice deviceWithUniqueID:@"000"];
//
//    RTCCameraVideoCapturer *videoCapturer = [[RTCCameraVideoCapturer alloc] initWithDelegate:videoSource];
//    NSArray<AVCaptureDeviceFormat *> *formats = [RTCCameraVideoCapturer supportedFormatsForDevice:videoDevice];
//    AVCaptureDeviceFormat *selectedFormat = formats[0];
//    NSInteger selectedFps = 30;
//    [videoCapturer startCaptureWithDevice:videoDevice format:selectedFormat fps:selectedFps completionHandler:^(NSError *error) {
//        if (error) {
//            NSLog(@"Start capture error: %@", [error localizedDescription]);
//        }
//    }];
}

VideoCaptureMac::VideoCaptureMac() {

}

VideoCaptureMac::~VideoCaptureMac() {

}

int32_t VideoCaptureMac::Init(const char* deviceUniqueId) {
    NSString *deviceId = [NSString stringWithUTF8String:deviceUniqueId];
    this->device = [AVCaptureDevice deviceWithUniqueID:deviceId];
}

int32_t VideoCaptureMac::StartCapture(const webrtc::VideoCaptureCapability& capability) {
    return 0;
}

int32_t VideoCaptureMac::StopCapture() {
    return 0;
}

bool VideoCaptureMac::CaptureStarted() {
    return true;
}

int32_t VideoCaptureMac::CaptureSettings(webrtc::VideoCaptureCapability& settings) {
    return -1;
}

rtc::scoped_refptr<webrtc::VideoCaptureModule> create_video_capture_mac(const char* deviceUniqueId) {
    auto ptr = rtc::make_ref_counted<VideoCaptureMac>();

    return ptr;
}
