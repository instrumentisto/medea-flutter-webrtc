#import "FlutterWebRTCPlugin.h"
#import <FlutterMacOS/FlutterMacOS.h>
#import <AVFoundation/AVFoundation.h>

void* store_dart_post_cobject(void*);

@implementation FlutterWebRTCPlugin
+ (void)registerWithRegistrar:(nonnull id<FlutterPluginRegistrar>)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"FlutterWebRtc/VideoRendererFactory/0"
                                     binaryMessenger:[registrar messenger]];
    FlutterWebRTCPlugin* instance = [FlutterWebRTCPlugin alloc];
    FlutterWebRTCPlugin* finalInstance = [instance initWithChannel:channel:[registrar messenger]];
    [registrar addMethodCallDelegate:finalInstance channel:channel];
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (granted) {
            NSLog(@"Video permission granted");
        } else {
            NSLog(@"Video permission NOT granted");
        }
    }];
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        if (granted) {
            NSLog(@"Audio permission granted");
        } else {
            NSLog(@"Audio permission NOT granted");
        }
    }];
}

- (void)handleMethodCall:(nonnull FlutterMethodCall*)call result:(nonnull FlutterResult)result {
    store_dart_post_cobject(nil);
    NSLog(@"Handle method call was called");
}

- (instancetype) initWithChannel:(FlutterMethodChannel*)channel :(NSObject<FlutterBinaryMessenger>*)messenger {
    self = [super init];
    return self;
}
@end

@implementation FlutterWebRTC
- (void)handleMethodCall:(FlutterMethodCall*)methodCall :(FlutterResult)result {
    NSLog(@"Hello Flutter world!");
    NSString* method = methodCall.method;
    if ([method isEqualToString:@"create"]) {

    } else if ([method isEqualToString:@"dispose"]) {

    } else {
        result(FlutterMethodNotImplemented);
    }
}
@end
