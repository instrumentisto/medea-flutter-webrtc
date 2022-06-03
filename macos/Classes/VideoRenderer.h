#import "FlutterMacOS/FlutterMacOS.h"
#import <AVFoundation/AVFoundation.h>
// #if __cplusplus__
// #include "flutter_webrtc_native.h"
// #endif

@interface FlutterTextureRenderer

- (CVPixelBufferRef*)copyPixelBuffer:(size_t)width height:(size_t)height;
// - (void)onFrame:(void*)frame;
- (void)resetRenderer;

@end