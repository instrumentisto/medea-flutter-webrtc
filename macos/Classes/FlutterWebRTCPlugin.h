#import "FlutterMacOS/FlutterMacOS.h"
#import "VideoRenderer.h"

@interface FlutterWebRTCPlugin : NSObject<FlutterPlugin>
{
    @private NSObject<FlutterBinaryMessenger> *messenger;
    @private NSObject<FlutterTextureRegistry> *textures;
}
@property (nonatomic, strong) VideoRendererManager* videoRendererManager;

- (instancetype) initWithChannel:(FlutterMethodChannel*)channel :(NSObject<FlutterBinaryMessenger>*)messenger;
@end
