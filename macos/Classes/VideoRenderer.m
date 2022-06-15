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
    NSLog(@"TextureVideoRenderer::initialize 1");

    NSNumber* textureId = [NSNumber numberWithInt: [registry registerTexture: self]];
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

- (void) onFrame: (Frame) frame {
    // id<RTCI420Buffer> i420Buffer = [self correctRotation:[frame.buffer toI420] withRotation:frame.rotation];
    id<RTCI420Buffer> i420buffer = [frame.buffer toI420];
    CVPixelBufferLockBaseAddress(_pixelBufferRef, 0);

    const OSType pixelFormat = CVPixelBufferGetPixelFormatType(_pixelBufferRef);
    if (pixelFormat == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange ||
        pixelFormat == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
        // NV12
        uint8_t* dstY = CVPixelBufferGetBaseAddressOfPlane(_pixelBufferRef, 0);
        const size_t dstYStride = CVPixelBufferGetBytesPerRowOfPlane(_pixelBufferRef, 0);
        uint8_t* dstUV = CVPixelBufferGetBaseAddressOfPlane(_pixelBufferRef, 1);
        const size_t dstUVStride = CVPixelBufferGetBytesPerRowOfPlane(_pixelBufferRef, 1);
        
        [RTCYUVHelper I420ToNV12:i420Buffer.dataY
                      srcStrideY:i420Buffer.strideY
                            srcU:i420Buffer.dataU
                      srcStrideU:i420Buffer.strideU
                            srcV:i420Buffer.dataV
                      srcStrideV:i420Buffer.strideV
                            dstY:dstY
                      dstStrideY:(int)dstYStride
                            dstUV:dstUV
                      dstStrideUV:(int)dstUVStride
                           width:i420Buffer.width
                           width:i420Buffer.height];

    } else {
        uint8_t* dst = CVPixelBufferGetBaseAddress(_pixelBufferRef);
        const size_t bytesPerRow = CVPixelBufferGetBytesPerRow(_pixelBufferRef);
        
        if (pixelFormat == kCVPixelFormatType_32BGRA) {
            // Corresponds to libyuv::FOURCC_ARGB
        
            [RTCYUVHelper I420ToARGB:i420Buffer.dataY
                          srcStrideY:i420Buffer.strideY
                                srcU:i420Buffer.dataU
                          srcStrideU:i420Buffer.strideU
                                srcV:i420Buffer.dataV
                          srcStrideV:i420Buffer.strideV
                             dstARGB:dst
                       dstStrideARGB:(int)bytesPerRow
                               width:i420Buffer.width
                              height:i420Buffer.height];

        } else if (pixelFormat == kCVPixelFormatType_32ARGB) {
            // Corresponds to libyuv::FOURCC_BGRA
            [RTCYUVHelper I420ToBGRA:i420Buffer.dataY
                          srcStrideY:i420Buffer.strideY
                                srcU:i420Buffer.dataU
                          srcStrideU:i420Buffer.strideU
                                srcV:i420Buffer.dataV
                          srcStrideV:i420Buffer.strideV
                             dstBGRA:dst
                       dstStrideBGRA:(int)bytesPerRow
                               width:i420Buffer.width
                              height:i420Buffer.height];
        }
    }
    
    CVPixelBufferUnlockBaseAddress(_pixelBufferRef, 0);





    NSLog(@"onFrame from Flutter");
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
    [self->_registry textureFrameAvailable: [self->_textureId intValue]];
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
