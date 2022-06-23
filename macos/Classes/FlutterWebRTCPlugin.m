#import "FlutterWebRTCPlugin.h"
// #import <FlutterMacOS/FlutterMacOS.h>
// #import "flutter_webrtc_native.h"
#import <AVFoundation/AVFoundation.h>

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
    instance->_registrar = registrar;
    // [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
    //     if (granted) {
    //         NSLog(@"Video permission granted");
    //     } else {
    //         NSLog(@"Video permission NOT granted");
    //     }
    // }];
    // [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
    //     if (granted) {
    //         NSLog(@"Audio permission granted");
    //     } else {
    //         NSLog(@"Audio permission NOT granted");
    //     }
    // }];
}

- (void)handleMethodCall:(nonnull FlutterMethodCall*) methodCall result:(nonnull FlutterResult)result {
    NSString* method = methodCall.method;
    if ([method isEqualToString:@"create"]) {
        [self->_videoRendererManager createVideoRendererTexture: result];
    } else if ([method isEqualToString:@"dispose"]) {
        [self->_videoRendererManager videoRendererDispose: methodCall result: result];
    } else if ([method isEqualToString:@"createFrameHandler"]) {
        [self->_videoRendererManager createFrameHandler: methodCall result: result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (instancetype) initWithChannel:(FlutterMethodChannel*)channel :(NSObject<FlutterBinaryMessenger>*)messenger {
    self = [super init];
    return self;
}
@end
