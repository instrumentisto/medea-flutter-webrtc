#import "FlutterMacOS/FlutterMacOS.h"
#import "VideoRenderer.h"

@interface FlutterWebRTCPlugin : NSObject<FlutterPlugin>
{
    // @private NSObject<FlutterBinaryMessenger> *messenger;
    // @private id<FlutterTextureRegistry> textures;
}
@property (nonatomic, strong) VideoRendererManager* videoRendererManager;
@property (nonatomic, strong) NSObject<FlutterBinaryMessenger> *messenger;
@property (nonatomic, strong) id<FlutterTextureRegistry> textures;
@property (nonatomic, strong) id<FlutterPluginRegistrar> registrar;

- (instancetype) initWithChannel:(FlutterMethodChannel*)channel :(NSObject<FlutterBinaryMessenger>*)messenger;
@end
