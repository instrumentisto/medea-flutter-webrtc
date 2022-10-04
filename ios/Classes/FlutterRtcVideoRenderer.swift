import Flutter
import OSLog
import WebRTC
import os

class FlutterRtcVideoRenderer: NSObject, FlutterTexture, RTCVideoRenderer {
  private var track: MediaStreamTrackProxy?
  private var textureId: Int64 = 0
  private var pixelBuffer: CVPixelBuffer?
  private var frameSize: CGSize
  private var registry: FlutterTextureRegistry
  private var observers: [VideoRendererEvent] = []
  private var isFirstFrameRendered: Bool = false
  private var frameWidth: Int32 = 0
  private var frameHeight: Int32 = 0
  private var frameRotation: Int = -1

  init(registry: FlutterTextureRegistry) {
    self.frameSize = CGSize()
    self.registry = registry
    super.init()
    let textureId = registry.register(self)
    self.textureId = textureId
  }

  func subscribe(sub: VideoRendererEvent) {
    self.observers.append(sub)
  }

  func broadcastEventObserver() -> VideoRendererEvent {
    class BroadcastEventObserver: VideoRendererEvent {
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

      func onTextureChangeRotation(id: Int64, rotation: Int) {
        for observer in self.observers {
          observer.onTextureChangeRotation(id: id, rotation: rotation)
        }
      }
    }

    return BroadcastEventObserver(observers: self.observers)
  }

  func getTextureId() -> Int64 {
    return self.textureId
  }

  public func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
    if self.pixelBuffer == nil {
      return nil
    }
    return Unmanaged<CVPixelBuffer>.passRetained(self.pixelBuffer!)
  }

  func setSize(_ size: CGSize) {
    if self.pixelBuffer == nil
      || (size.width != self.frameSize.width || size.height != self.frameSize.height)
    {
      let attrs =
        [
          kCVPixelBufferOpenGLCompatibilityKey: kCFBooleanTrue,
          kCVPixelBufferOpenGLESCompatibilityKey: kCFBooleanTrue,
          kCVPixelBufferMetalCompatibilityKey: kCFBooleanTrue,
        ] as CFDictionary
      let res = CVPixelBufferCreate(
        kCFAllocatorDefault,
        Int(size.width), Int(size.height),
        kCVPixelFormatType_32BGRA,
        attrs,
        &self.pixelBuffer
      )
      self.frameSize = size
    }
  }

  public func onTextureUnregistered(_ texture: FlutterRtcVideoRenderer) {

  }

  func reset() {
    self.frameWidth = 0
    self.frameHeight = 0
    self.frameRotation = -1
    self.pixelBuffer = nil
    self.isFirstFrameRendered = false
    self.frameSize = CGSize()
  }

  func correctRotation(frame: RTCVideoFrame) -> RTCI420Buffer {
    let src = frame.buffer.toI420()
    let rotation = frame.rotation
    var rotatedWidth = src.width
    var rotatedHeight = src.height

    if rotation == ._90 || rotation == ._270 {
      rotatedWidth = src.height
      rotatedHeight = src.width
    }

    let buffer = RTCI420Buffer(width: rotatedWidth, height: rotatedHeight)
    libyuv_I420Rotate(
      src.dataY,
      src.strideY,
      src.dataU,
      src.strideU,
      src.dataV,
      src.strideV,
      UnsafeMutablePointer(mutating: buffer.dataY),
      buffer.strideY,
      UnsafeMutablePointer(mutating: buffer.dataU),
      buffer.strideU,
      UnsafeMutablePointer(mutating: buffer.dataV),
      buffer.strideV,
      src.width,
      src.height,
      rotation
    )
    return buffer
  }

  func setVideoTrack(newTrack: MediaStreamTrackProxy?) {
    if newTrack == nil {
      self.reset()
      track?.removeRenderer(renderer: self)
    }
    if self.track != newTrack && newTrack != nil {
      track?.removeRenderer(renderer: self)

      if self.track == nil {
        newTrack!.addRenderer(renderer: self)
      }
    }

    self.track = newTrack
  }

  func dispose() {
    self.track!.removeRenderer(renderer: self)
  }

  func renderFrame(_ renderFrame: RTCVideoFrame?) {
    if renderFrame == nil {
      return
    }
    let buffer = self.correctRotation(frame: renderFrame!)
    let isFrameWidthChanged = self.frameWidth != renderFrame!.buffer.width
    let isFrameHeightChanged = self.frameHeight != renderFrame!.buffer.height
    if isFrameWidthChanged || isFrameHeightChanged {
      self.frameWidth = renderFrame!.buffer.width
      self.frameHeight = renderFrame!.buffer.height
      self.broadcastEventObserver().onTextureChangeVideoSize(
        id: self.textureId, height: self.frameHeight, width: self.frameWidth)
    }
    if self.pixelBuffer == nil {
      return
    }
    CVPixelBufferLockBaseAddress(self.pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
    let dst = CVPixelBufferGetBaseAddress(self.pixelBuffer!)!
    let bytesPerRow = CVPixelBufferGetBytesPerRow(self.pixelBuffer!)
    libyuv_I420ToARGB(
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
    CVPixelBufferUnlockBaseAddress(self.pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

    var rotation = 0
    switch renderFrame!.rotation {
    case RTCVideoRotation._0:
      rotation = 0
    case RTCVideoRotation._90:
      rotation = 90
    case RTCVideoRotation._180:
      rotation = 180
    case RTCVideoRotation._270:
      rotation = 270
      break
    }
    if self.frameRotation != rotation {
      self.frameRotation = rotation
      self.broadcastEventObserver().onTextureChangeRotation(
        id: self.textureId, rotation: self.frameRotation)
    }

    if !self.isFirstFrameRendered {
      self.broadcastEventObserver().onFirstFrameRendered(id: self.textureId)
      isFirstFrameRendered = true
    }

    DispatchQueue.main.async {
      self.registry.textureFrameAvailable(self.textureId)
    }
  }
}
