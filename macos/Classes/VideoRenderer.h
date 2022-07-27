#import <AVFoundation/AVFoundation.h>
#import <FlutterMacOS/FlutterMacOS.h>

// Converts provided Frame to the ARGB format to the provided buffer pointer.
extern void get_argb_bytes(void* frame, uint8_t* buffer);

// Drops provided Frame.
extern void drop_frame(void* frame);

// Video frame.
typedef struct Frame {
    size_t height;
    size_t width;
    int32_t rotation;
    size_t buffer_size;
    uint8_t* frame;
} Frame;

// MacOS texture video renderer definition.
@interface TextureVideoRenderer
    : NSObject <FlutterTexture, FlutterStreamHandler>

// FlutterEventChannel of this TextureVideoRenderer.
@property(nonatomic, strong, nullable) FlutterEventChannel* eventChannel;

// Flag which indicates that first frame was rendered.
@property(nonatomic) bool firstFrameRendered;

// FlutterTextureRegistry of this TextureVideoRenderer.
@property(nonatomic, weak) id<FlutterTextureRegistry> registry;

// ID of this TextureVideoRenderer.
@property(nonatomic, strong, nullable) NSNumber* textureId;

// Rotation of the last rendered by this TextureVideoRenderer Frame.
@property(nonatomic, strong, nullable) NSNumber* rotation;

// FlutterEventSink of this TextureVideoRenderer.
@property(nonatomic, strong, nullable) FlutterEventSink eventSink;

// ID of the FlutterTexture registered in FlutterTextureRegistry.
@property(nonatomic) int64_t tid;

// CVPixelBuffer onto which Frames will be rendered bu this TextureVideoRenderer.
@property(nonatomic) CVPixelBufferRef pixelBufferRef;

// Buffer size of the last rendered by this TextureVideoRenderer Frame.
@property(nonatomic) size_t bufferSize;

// Width of the last rendered by this TextureVideoRenderer Frame.
@property(nonatomic) size_t frameWidth;

// Height of the last rendered by this TextureVideoRenderer Frame.
@property(nonatomic) size_t frameHeight;

- (instancetype)init:(id<FlutterTextureRegistry>)registry
           messenger:(id<FlutterBinaryMessenger>)messenger;
- (void)resetRenderer;
- (void)onFrame:(Frame)frame;
- (NSNumber*)textureId;
@end

@interface VideoRendererManager : NSObject
// FlutterTextureRegistry of this VideoRendererManager.
@property(nonatomic, strong, nullable) id<FlutterTextureRegistry> registry;

// FlutterBinaryMessenger of this VideoRendererManager.
@property(nonatomic, strong, nullable) id<FlutterBinaryMessenger> messenger;

// All TextureVideoRenderers created by this VideoRendererManager.
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
