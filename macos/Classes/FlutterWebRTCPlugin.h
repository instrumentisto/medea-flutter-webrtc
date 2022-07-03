#import <AVFoundation/AVFoundation.h>

#import "FlutterMacOS/FlutterMacOS.h"
#import "VideoRenderer.h"

@interface FlutterWebRTCPlugin : NSObject<FlutterPlugin>
@property (nonatomic, strong) VideoRendererManager* videoRendererManager;

- (instancetype) initWithChannel:(FlutterMethodChannel*)channel :(NSObject<FlutterBinaryMessenger>*)messenger;
@end
