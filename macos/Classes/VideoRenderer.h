#import <AVFoundation/AVFoundation.h>
#import <FlutterMacOS/FlutterMacOS.h>

extern void get_argb_bytes(void* frame, uint8_t* buffer);
extern void drop_frame(void* frame);

typedef struct Frame {
    size_t height;
    size_t width;
    int32_t rotation;
    size_t buffer_size;
    uint8_t* frame;
} Frame;

@interface TextureVideoRenderer
    : NSObject <FlutterTexture, FlutterStreamHandler>
@property(nonatomic, strong, nullable) FlutterEventChannel* eventChannel;
@property(nonatomic) bool firstFrameRendered;
@property(nonatomic, weak) id<FlutterTextureRegistry> registry;
@property(nonatomic, strong, nullable) NSNumber* textureId;
@property(nonatomic, strong, nullable) NSNumber* rotation;
@property(nonatomic, strong, nullable) FlutterEventSink eventSink;
@property(nonatomic) int64_t tid;
@property(nonatomic) CVPixelBufferRef pixelBufferRef;
@property(nonatomic) size_t bufferSize;
@property(nonatomic) size_t frameWidth;
@property(nonatomic) size_t frameHeight;

- (instancetype)init:(id<FlutterTextureRegistry>)registry
           messenger:(id<FlutterBinaryMessenger>)messenger;
- (void)resetRenderer;
- (void)onFrame:(Frame)frame;
- (NSNumber*)textureId;
@end

@interface VideoRendererManager : NSObject
@property(nonatomic, strong, nullable) id<FlutterTextureRegistry> registry;
@property(nonatomic, strong, nullable) id<FlutterBinaryMessenger> messenger;
@property(nonatomic, strong, nullable)
    NSMutableDictionary<NSNumber*, TextureVideoRenderer*>* renderers;

- (VideoRendererManager*)init:(id<FlutterTextureRegistry>)registry
                    messenger:(id<FlutterBinaryMessenger>)messenger;
- (void)createVideoRendererTexture:(FlutterResult)result;
- (void)videoRendererDispose:(FlutterMethodCall*)methodCall
                      result:(FlutterResult)result;
- (void)createFrameHandler:(FlutterMethodCall*)methodCall
                    result:(FlutterResult)result;
@end
