#import "VideoRenderer.h"
#import "FlutterMacOS/FlutterMacOS.h"
#import <AVFoundation/AVFoundation.h>

void drop_handler(void* handler) {
    TextureVideoRenderer* renderer = (__bridge_transfer TextureVideoRenderer*) handler;
}

void foobar() {

}

void on_frame_caller(void* handler, Frame frame) {
    NSLog(@"OnFrame 1");
    TextureVideoRenderer* renderer = (__bridge TextureVideoRenderer*) handler;
    NSLog(@"OnFrame: %@", [renderer textureId]);
    NSLog(@"OnFrame 2");
    [renderer onFrame: frame];
    NSLog(@"OnFrame 3");
}

@implementation TextureVideoRenderer
- (instancetype) init: (id<FlutterTextureRegistry>) registry messenger:(id<FlutterBinaryMessenger>)messenger {
    self = [super init];
    // _sendEvents = true;
    // _firstFrameRendered = false;
    // _registry = registry;
    // _pixelBufferRef = nil;
    // _eventSink = nil;
    // _rotation = @0;

    self->_pixelBufferRef = nil;
    self->_registry = registry;
    self->_sendEvents = true;
    NSLog(@"TextureVideoRenderer::initialize 1");

    int64_t tid = [registry registerTexture: self];
    self->_tid = tid;
    NSLog(@"Texture ID in init: %d", tid);
    NSNumber* textureId = [NSNumber numberWithInt: tid];
    NSString* channelName = [NSString stringWithFormat:@"FlutterWebRtc/VideoRendererEvent/%@", textureId];
    NSLog(@"TextureVideoRenderer channel name: %@", channelName);
    _eventChannel = [FlutterEventChannel
                                eventChannelWithName:channelName
                                binaryMessenger:messenger];
    NSLog(@"TextureVideoRenderer::initialize 2");
    self->_textureId = textureId;
    [_eventChannel setStreamHandler:self];
    NSLog(@"TextureVideoRenderer::initialize 3");
    return self;
}

- (void) resetRenderer {
    self->_firstFrameRendered = false;
}

- (void)onTextureUnregistered:(NSObject<FlutterTexture>*)texture {
    NSLog(@"FUCK TEXTURE UNREGISTERED");
}

- (void) onFrame: (Frame) frame {
    // id<RTCI420Buffer> i420Buffer = [self correctRotation:[frame.buffer toI420] withRotation:frame.rotation];
    // id<RTCI420Buffer> i420buffer = [frame.buffer toI420];
    if (_pixelBufferRef != nil) {
        NSLog(@"Pixel buffer release");
      CVBufferRelease(_pixelBufferRef);
    }
    NSDictionary *pixelAttributes = @{(id)kCVPixelBufferIOSurfacePropertiesKey : @{}};
    CVPixelBufferCreate(kCFAllocatorDefault,
                        frame.width, frame.height,
                        kCVPixelFormatType_32BGRA,
                        (__bridge CFDictionaryRef)(pixelAttributes), &_pixelBufferRef);
    CVPixelBufferLockBaseAddress(_pixelBufferRef, 0);
    uint8_t* dst = CVPixelBufferGetBaseAddress(_pixelBufferRef);
    memcpy(dst, frame.buffer, frame.width * frame.height * 4);
    CVPixelBufferUnlockBaseAddress(_pixelBufferRef, 0);

    NSLog(@"onFrame from Flutter: %@", self->_textureId);
    if (!self->_firstFrameRendered) {
        NSLog(@"firstFrameRendered 1");
        if (self->_sendEvents) {
            NSLog(@"firstFrameRendered 2");
            NSDictionary *map = @{
                @"event" : @"onFirstFrameRendered",
                @"id" : self->_textureId,
            };
            self->_eventSink(map);
            self->_firstFrameRendered = true;
        }
    }
    NSNumber *frameRotation = [NSNumber numberWithInt: frame.rotation];
    if (self->_rotation != frameRotation) {
        if (self->_sendEvents) {
            NSDictionary *map = @{
                @"event" : @"onTextureChangeRotation",
                @"id" : self->_textureId,
                @"rotation" : frameRotation,
            };
            self->_eventSink(map);
        }
        self->_rotation = frameRotation;
    }
    if (self->_frame.buffer_size != frame.buffer_size) {
        if (self->_sendEvents) {
            NSDictionary *map = @{
                @"event" : @"onTextureChangeVideoSize",
                @"id" : self->_textureId,
                @"width" : [NSNumber numberWithLong: frame.width],
                @"height" : [NSNumber numberWithLong: frame.height],
            };
            self->_eventSink(map);
        }
    }
    // [self->_registry textureFrameAvailable: [self->_textureId longValue]];
    // [self->_registry textureFrameAvailable: self->_tid];

    __weak TextureVideoRenderer* weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong TextureVideoRenderer* strongSelf = weakSelf;
        if (strongSelf) {
            NSLog(@"textureFrameAvailable called");
            [strongSelf.registry textureFrameAvailable:strongSelf->_tid];
        }
    });
}

- (NSNumber*) textureId {
    return self->_textureId;
}

- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    _eventSink = nil;
    return nil;
}

- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(nonnull FlutterEventSink)sink {
    _eventSink = sink;
    return nil;
}

- (CVPixelBufferRef)copyPixelBuffer {
    NSLog(@"copyPixelBuffer");
    if(_pixelBufferRef != nil){
        CVBufferRetain(_pixelBufferRef);
        return _pixelBufferRef;
    }
    return nil;
}
@end

@implementation VideoRendererManager
- (VideoRendererManager*) init: (id<FlutterTextureRegistry>) registry messenger:(id<FlutterBinaryMessenger>)messenger {
    self->_renderers = [[NSMutableDictionary alloc] init];
    self->_registry = registry;
    self->_messenger = messenger;
    return self;
}

- (void) createVideoRendererTexture: (FlutterResult) result {
    TextureVideoRenderer* renderer = [[TextureVideoRenderer alloc] init: self->_registry messenger:self->_messenger];
    NSNumber* textureId = [renderer textureId];
    [self->_renderers setObject: renderer forKey:textureId];
    NSLog(@"Renderers: %@", self->_renderers);

    NSLog(@"Texture ID in create: %@", textureId);
    NSDictionary* map = @{
        @"textureId" : textureId,
        @"channelId" : textureId,
    };
    result(map);
}

- (void) videoRendererDispose: (FlutterMethodCall*) methodCall result:(FlutterResult)result {
    NSLog(@"Dispose videoRenderer");
    NSDictionary* arguments = methodCall.arguments;
    NSNumber* textureId = arguments[@"textureId"];

    TextureVideoRenderer* renderer = self->_renderers[textureId];
    [self->_registry unregisterTexture: [textureId intValue]];
    [self->_renderers removeObjectForKey: textureId];
    result(@{});
}

- (void) createFrameHandler: (FlutterMethodCall*) methodCall result:(FlutterResult)result {
    NSDictionary* arguments = methodCall.arguments;
    NSNumber* textureId = arguments[@"textureId"];
    NSLog(@"Renderer textureID: %@", textureId);
    TextureVideoRenderer* renderer = self->_renderers[textureId];
    NSLog(@"Renderer print: %@", renderer);
    
    int64_t rendererPtr = (int64_t) renderer;
    NSLog(@"RendererPtr: %@", rendererPtr);
    result(@{
        @"handler_ptr" : [NSNumber numberWithLong: rendererPtr],
    });
}
@end
