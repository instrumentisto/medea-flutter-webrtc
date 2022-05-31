#import <FlutterMacOS/FlutterMacOS.h>
#import <AVFoundation/AVFoundation.h>
#include "flutter_webrtc_native.h"

@interface FlutterTextureRenderer

- (CVPixelBufferRef*)copyPixelBuffer:(size_t)width height:(size_t)height;
- (void)onFrame:(VideoFrame*)frame;
- (void)resetRenderer;

@end