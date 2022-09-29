#import <Flutter/Flutter.h>

@interface MedeaFlutterWebrtcPlugin : NSObject<FlutterPlugin>
@end

// func myI420ToARGB(srcY: UnsafePointer<UInt8>, srcStrideY: Int32, srcU: UnsafePointer<UInt8>, srcStrideU: Int32, srcV: UnsafePointer<UInt8>, srcStrideV: Int32, dstARGB: UnsafeMutableRawPointer, dstStrideARGB: Int, width: Int32, height: Int32) -> Int32 {
bool libyuv_I420ToARGB(
	const uint8_t* src_y,
	int src_stride_y,
	const uint8_t* src_u,
	int src_stride_u,
	const uint8_t* src_v,
	int src_stride_v,
	uint8_t* dst_argb,
	int dst_stride_argb,
	int width,
	int height
);