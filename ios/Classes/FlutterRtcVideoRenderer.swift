import WebRTC
import Flutter
import OSLog
import os

func myI420ToARGB(srcY: UnsafePointer<UInt8>, srcStrideY: Int32, srcU: UnsafePointer<UInt8>, srcStrideU: Int32, srcV: UnsafePointer<UInt8>, srcStrideV: Int32, dstARGB: UnsafeMutableRawPointer, dstStrideARGB: Int32, width: Int32, height: Int32) -> Bool {
      return libyuv_I420ToARGB(srcY, srcStrideY, srcU, srcStrideU, srcV, srcStrideV, dstARGB, dstStrideARGB, width, height);
}

class FlutterRtcVideoRenderer : NSObject, FlutterTexture, RTCVideoRenderer {
    private var track: MediaStreamTrackProxy?
    private var textureId: Int64 = 0
    private var pixelBuffer: CVPixelBuffer?
    private var frameSize: CGSize
    private var registry: FlutterTextureRegistry
    private var observers: [VideoRendererEvent] = []
    private var isFirstFrameRendered: Bool = false
    private var frameWidth: Int32 = 0
    private var frameHeight: Int32 = 0

    init(registry: FlutterTextureRegistry) {
        self.frameSize = CGSize()
        self.registry = registry
        super.init()
        if (Thread.isMainThread) {
            os_log(OSLogType.error, "We're running on main thread")
        } else {
            os_log(OSLogType.error, "We're running not on main thread")
        }
        let textureId = registry.register(self)
        if (textureId == nil) {
            os_log(OSLogType.error, "textureId is nil")
        } else {
            os_log(OSLogType.error, "textureId is not nil")
        }
        if (textureId > 0) {
            os_log(OSLogType.error, "textureId is greater 0")
        } else {
            os_log(OSLogType.error, "textureId is NOT greater 0")
        }
        self.textureId = textureId
        // os_log(OSLogType.error, "textureId: %@", textureId)
    }

    func subscribe(sub: VideoRendererEvent) {
        self.observers.append(sub)
    }

    func broadcastEventObserver() -> VideoRendererEvent {
        class BroadcastEventObserver : VideoRendererEvent {
            private var observers: [VideoRendererEvent]

            init(observers: [VideoRendererEvent]) {
                self.observers = observers
            }

            func onFirstFrameRendered(id: Int64) {
                for observer in self.observers {
                    observer.onFirstFrameRendered(id: id)
                }
            }


            func onTextureChangeVideoSize(id: Int64, height: Int32, width: Int32) {
                for observer in self.observers {
                    observer.onTextureChangeVideoSize(id: id, height: height, width: width)
                }
            }
        }

        return BroadcastEventObserver(observers: self.observers)
    }

    func getTextureId() -> Int64 {
        return self.textureId
    }

    public func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
        os_log(OSLogType.error, "copyPixelBuffer")
        if(self.pixelBuffer == nil){
            os_log(OSLogType.error, "PixelBuffer is nil")
            return nil
        }
        os_log(OSLogType.error, "PixelBuffer is not nil")
        return Unmanaged<CVPixelBuffer>.passRetained(self.pixelBuffer!)
    }

    func setSize(_ size: CGSize) {
        os_log(OSLogType.error, "setSize 1")
        if (self.pixelBuffer == nil || (size.width != self.frameSize.width || size.height != self.frameSize.height)) {
            let res = CVPixelBufferCreate(kCFAllocatorDefault,
                                Int(size.width), Int(size.height),
                                kCVPixelFormatType_32BGRA,
                                nil,
                                &self.pixelBuffer
            )
            if (res == kCVReturnSuccess) {
                os_log(OSLogType.error, "Buffer created success")
            } else {
                os_log(OSLogType.error, "Buffer created NOT success")
            }
            self.frameSize = size
        }
    }

    public func onTextureUnregistered(_ texture: FlutterRtcVideoRenderer) {

    }

    func setVideoTrack(newTrack: MediaStreamTrackProxy?) {
        if (self.track != newTrack && newTrack != nil) {
            track?.removeRenderer(renderer: self)

            if (self.track == nil) {
                newTrack!.addRenderer(renderer: self)
            }
        }

        self.track = newTrack
    }

    func renderFrame(_ renderFrame: RTCVideoFrame?) {
        os_log(OSLogType.error, "renderFrame 1")
        if (renderFrame == nil) {
            return
        }
        if (self.pixelBuffer == nil) {
            return
        }
        let isFrameWidthChanged = self.frameWidth != renderFrame!.width
        let isFrameHeightChanged = self.frameHeight != renderFrame!.height
        if (isFrameWidthChanged || isFrameHeightChanged) {
            self.frameWidth = renderFrame!.width
            self.frameHeight = renderFrame!.height
            let res = CVPixelBufferCreate(kCFAllocatorDefault,
                                Int(self.frameWidth), Int(self.frameHeight),
                                kCVPixelFormatType_32BGRA,
                                nil,
                                &self.pixelBuffer
            )
            if (res == kCVReturnSuccess) {
                os_log(OSLogType.error, "Buffer created success")
            } else {
                os_log(OSLogType.error, "Buffer created NOT success")
            }
            self.broadcastEventObserver().onTextureChangeVideoSize(id: self.textureId, height: self.frameHeight, width: self.frameWidth)
        }
        os_log(OSLogType.error, "renderFrame 2")
        CVPixelBufferLockBaseAddress(self.pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0));
        let buffer = renderFrame!.buffer.toI420()
        let dst = CVPixelBufferGetBaseAddress(self.pixelBuffer!)!
        let bytesPerRow = CVPixelBufferGetBytesPerRow(self.pixelBuffer!)
        let dstBefore = dst.load(as: UInt8.self)
        let isSuccess = libyuv_I420ToARGB(
            buffer.dataY,
            buffer.strideY,
            buffer.dataU,
            buffer.strideU,
            buffer.dataV,
            buffer.strideV,
            dst,
            Int32(bytesPerRow),
            buffer.width,
            buffer.height
        )
        let dstAfter = dst.load(as: UInt8.self)
        os_log(OSLogType.error, "libyuv dst before: %i; after: %i", dstBefore, dstAfter)
        
        // let isSuccess = myI420ToARGB(
        //     srcY: buffer.dataY,
        //     srcStrideY: buffer.strideY,
        //     srcU: buffer.dataU,
        //     srcStrideU: buffer.strideU,
        //     srcV: buffer.dataV,
        //     srcStrideV: buffer.strideV,
        //     dstARGB: dst,
        //     dstStrideARGB: Int32(bytesPerRow),
        //     width: buffer.width,
        //     height: buffer.height
        // )
        if (isSuccess) {
            os_log(OSLogType.error, "convert success")
        } else {
            os_log(OSLogType.error, "convert NOT success")
        }
        os_log(OSLogType.error, "renderFrame 3")
        CVPixelBufferUnlockBaseAddress(self.pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0));


        if (!self.isFirstFrameRendered) {
            self.broadcastEventObserver().onFirstFrameRendered(id: self.textureId)
            isFirstFrameRendered = true
        }

        DispatchQueue.main.async {
            self.registry.textureFrameAvailable(self.textureId)
            os_log(OSLogType.error, "renderFrame 4")
        }
    }
}
