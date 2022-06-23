#import "VideoRenderer.h"
#import "FlutterMacOS/FlutterMacOS.h"
#import <AVFoundation/AVFoundation.h>

void drop_handler(void* handler) {
    TextureVideoRenderer* renderer = (__bridge_transfer TextureVideoRenderer*) handler;
}

void foobar() {

}

void on_frame_caller(void* handler, Frame frame) {
    TextureVideoRenderer* renderer = (__bridge TextureVideoRenderer*) handler;
    [renderer onFrame: frame];
}

@implementation TextureVideoRenderer
- (instancetype) init: (id<FlutterTextureRegistry>) registry messenger:(id<FlutterBinaryMessenger>)messenger {
    self = [super init];
    self->_pixelBufferRef = nil;
    self->_registry = registry;
    self->_sendEvents = true;

    int64_t tid = [registry registerTexture: self];
    self->_tid = tid;
    NSNumber* textureId = [NSNumber numberWithLong: tid];
    NSString* channelName = [NSString stringWithFormat:@"FlutterWebRtc/VideoRendererEvent/%@", textureId];
    _eventChannel = [FlutterEventChannel
                                eventChannelWithName:channelName
                                binaryMessenger:messenger];
    self->_textureId = textureId;
    [_eventChannel setStreamHandler:self];

    __weak TextureVideoRenderer* weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong TextureVideoRenderer* strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf.registry textureFrameAvailable:strongSelf->_tid];
        }
    });
    return self;
}

- (void) resetRenderer {
    self->_firstFrameRendered = false;
}

- (void)onTextureUnregistered:(NSObject<FlutterTexture>*)texture {
}

- (void) onFrame: (Frame) frame {
    if (_pixelBufferRef != nil) {
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

    if (!self->_firstFrameRendered) {
        if (self->_sendEvents) {
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

    __weak TextureVideoRenderer* weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong TextureVideoRenderer* strongSelf = weakSelf;
        if (strongSelf) {
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
    if(_pixelBufferRef != nil) {
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

    NSDictionary* map = @{
        @"textureId" : textureId,
        @"channelId" : textureId,
    };
    result(map);
}

- (void) videoRendererDispose: (FlutterMethodCall*) methodCall result:(FlutterResult)result {
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
    TextureVideoRenderer* renderer = self->_renderers[textureId];
    
    int64_t rendererPtr = (int64_t) renderer;
    result(@{
        @"handler_ptr" : [NSNumber numberWithLong: rendererPtr],
    });
}
@end
