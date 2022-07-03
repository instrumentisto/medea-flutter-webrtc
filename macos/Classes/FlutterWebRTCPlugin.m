#import "FlutterWebRTCPlugin.h"

@implementation FlutterWebRTCPlugin
+ (void)registerWithRegistrar:(nonnull id<FlutterPluginRegistrar>)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"FlutterWebRtc/VideoRendererFactory/0"
                                     binaryMessenger:[registrar messenger]];
    FlutterWebRTCPlugin* instance = [FlutterWebRTCPlugin alloc];
    FlutterWebRTCPlugin* finalInstance = [instance initWithChannel:channel:[registrar messenger]];
    [registrar addMethodCallDelegate:finalInstance channel:channel];
    VideoRendererManager* manager = [[VideoRendererManager alloc] init: [registrar textures] messenger: [registrar messenger]];
    instance->_videoRendererManager = manager;
}

- (void)handleMethodCall:(nonnull FlutterMethodCall*) methodCall result:(nonnull FlutterResult)result {
    NSString* method = methodCall.method;
    if ([method isEqualToString:@"create"]) {
        [_videoRendererManager createVideoRendererTexture: result];
    } else if ([method isEqualToString:@"dispose"]) {
        [_videoRendererManager videoRendererDispose: methodCall result: result];
    } else if ([method isEqualToString:@"createFrameHandler"]) {
        [_videoRendererManager createFrameHandler: methodCall result: result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (instancetype) initWithChannel:(FlutterMethodChannel*)channel :(NSObject<FlutterBinaryMessenger>*)messenger {
    self = [super init];
    return self;
}
@end
