#import "FlutterMacOS/FlutterMacOS.h"

@interface FlutterWebRTCPlugin : NSObject<FlutterPlugin>
{
    @private NSObject<FlutterBinaryMessenger> *messenger;
    @private NSObject<FlutterTextureRegistry> *textures;
}
- (instancetype) initWithChannel:(FlutterMethodChannel*)channel :(NSObject<FlutterBinaryMessenger>*)messenger;
@end

@interface FlutterWebRTC : NSObject
{
    @private NSObject<FlutterBinaryMessenger> *messenger;
}
- (void) handleMethodCall:(FlutterMethodCall*)methodCall :(FlutterResult)result; 
@end
