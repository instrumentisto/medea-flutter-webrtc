import Flutter
import WebRTC

/// Renderer of video from a track to a `FlutterTexture` which can be shown by
/// Flutter side.
class FlutterRtcVideoRenderer: NSObject, FlutterTexture, RTCVideoRenderer {
  /// Track which is rendered by this `FlutterRtcVideoRenderer`.
  private var track: MediaStreamTrackProxy?

  /// ID of the `FlutterTexture` on which this `FlutterRtcVideoRenderer` renders
  /// the track.
  private var textureId: Int64 = 0

  /// Pixel buffer into which video will be rendered from the track.
  private var pixelBuffer: CVPixelBuffer?

  /// Registry for registering new `FlutterTexture`s.
  private var registry: FlutterTextureRegistry

  /// Observers of the `FlutterRtcVideoRenderer` events.
  private var observers: [VideoRendererEvent] = []

  /// Indicator whether a first frame was rendered by this
  /// `FlutterRtcVideoRenderer`.
  private var isFirstFrameRendered: Bool = false

  /// Last known width of the frame provided by `libwebrtc` to the
  /// `renderFrame()` method.
  private var frameWidth: Int32 = 0

  /// Last known height of the frame provided by `libwebrtc` to the
  /// `renderFrame()` method.
  private var frameHeight: Int32 = 0

  /// Last known rotation of the frame provided by libwebrtc to the
  /// `renderFrame()` method.
  private var frameRotation: Int = -1

  /// Lock for the `renderFrame()` function.
  ///
  /// This lock is locked when some frame is currently rendering or the
  /// `FlutterRtcVideoRenderer` in process of stopping.
  private let rendererLock: NSLock = .init()

  /// Initializes a new `FlutterRtcVideoRenderer`.
  init(registry: FlutterTextureRegistry) {
    self.registry = registry
    super.init()
    let textureId = registry.register(self)
    self.textureId = textureId
  }

  /// Subscribes the provided `VideoRendererEvent` to this
  /// `FlutterRtcVideoRenderer` events.
  func subscribe(sub: VideoRendererEvent) {
    self.observers.append(sub)
  }

  /// Returns an observer which will send provided events to all the observers
  /// of this renderer.
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

      func onTextureChange(
        id: Int64,
        height: Int32,
        width: Int32,
        rotation: Int
      ) {
        for observer in self.observers {
          observer.onTextureChange(
            id: id,
            height: height,
            width: width,
            rotation: rotation
          )
        }
      }
    }

    return BroadcastEventObserver(observers: self.observers)
  }

  /// Returns `FlutterTexture` ID of this renderer.
  func getTextureId() -> Int64 {
    self.textureId
  }

  /// Returns `CVPixelBuffer` with frame video data in it.
  ///
  /// Returns `nil` if no frames are available.
  func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
    self.rendererLock.lock()
    defer { rendererLock.unlock() }

    if let pixelBuf = self.pixelBuffer {
        return Unmanaged<CVPixelBuffer>.passRetained(pixelBuf)
    } else {
        return nil
    }
  }

  func setSize(_ size: CGSize) {}

  /// Resets the `CVPixelBuffer` of this renderer.
  func onTextureUnregistered(_: FlutterRtcVideoRenderer) {
    self.pixelBuffer = nil
  }

  /// Sets the `MediaStreamTrackProxy` which will be rendered by this renderer.
  func setVideoTrack(newTrack: MediaStreamTrackProxy?) {
    self.rendererLock.lock()
    defer { rendererLock.unlock() }

    if newTrack == nil {
      self.frameWidth = 0
      self.frameHeight = 0
      self.frameRotation = -1
      self.pixelBuffer = nil
      self.isFirstFrameRendered = false
      self.track?.removeRenderer(renderer: self)
      self.track = nil;
    } else if self.track != newTrack {
      self.track?.removeRenderer(renderer: self)

      if let newTrack = newTrack {
        newTrack.addRenderer(renderer: self)
      }
      self.track = newTrack
    }
  }

  /// Removes this renderer from the list of renderers used by the rendering
  /// track.
  func dispose() {
    self.rendererLock.lock()
    defer { rendererLock.unlock() }

    if self.track != nil {
      self.track!.removeRenderer(renderer: self)
    }
  }

  /// Renders the provided `RTCVideoFrame` to the `CVPixelBuffer`.
  ///
  /// Video frame will be just rendered on the `CVPixelBuffer`, but Flutter
  /// should get it by calling the `copyPixelBuffer()` method. So, video will be
  /// seen on Flutter side only after the `copyPixelBuffer()` call by Flutter.
  ///
  /// Also this method fires renderer events (if any) and notifies Flutter about
  /// the necessity to call the `copyPixelBuffer()` method to get the rendered
  /// frame.
  func renderFrame(_ renderFrame: RTCVideoFrame?) {
    self.rendererLock.lock()
    defer { rendererLock.unlock() }

    guard let renderFrame = renderFrame else {
      return
    }

    var rotation = 0
    switch renderFrame.rotation {
    case RTCVideoRotation._0:
      rotation = 0
    case RTCVideoRotation._90:
      rotation = 90
    case RTCVideoRotation._180:
      rotation = 180
    case RTCVideoRotation._270:
      rotation = 270
    }

    let isFrameWidthChanged = self.frameWidth != renderFrame.buffer.width
    let isFrameHeightChanged = self.frameHeight != renderFrame.buffer.height
    let isFrameRotationChanged = self.frameRotation != rotation

    if isFrameWidthChanged
      || isFrameHeightChanged
      || isFrameRotationChanged
    {
      self.frameWidth = renderFrame.buffer.width
      self.frameHeight = renderFrame.buffer.height
      self.frameRotation = rotation

      let frameWidth = self.frameWidth
      let frameHeight = self.frameHeight

      DispatchQueue.main.async {
        self.broadcastEventObserver().onTextureChange(
          id: self.textureId,
          height: frameHeight,
          width: frameWidth,
          rotation: rotation
        )
      }
    }

    if let cv = renderFrame.buffer as? RTCCVPixelBuffer {
        self.pixelBuffer = cv.pixelBuffer
    } else {
      let buffer = renderFrame.buffer.toI420()

      if self.pixelBuffer == nil
        || self.frameWidth != buffer.width
        || self.frameHeight != buffer.height
      {
        let attrs =
          [
            kCVPixelBufferOpenGLCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferOpenGLESCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferMetalCompatibilityKey: kCFBooleanTrue,
          ] as CFDictionary

        var newPB: CVPixelBuffer?
        CVPixelBufferCreate(
          kCFAllocatorDefault,
          Int(buffer.width),
          Int(buffer.height),
          kCVPixelFormatType_32BGRA,
          attrs,
          &self.pixelBuffer
        )
        self.pixelBuffer = newPB
      }

      CVPixelBufferLockBaseAddress(self.pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

      let dst = CVPixelBufferGetBaseAddress(self.pixelBuffer!)!
      let bytesPerRow = CVPixelBufferGetBytesPerRow(self.pixelBuffer!)

      RTCYUVHelper.i420(
        toARGB: buffer.dataY,
        srcStrideY: buffer.strideY,
        srcU: buffer.dataU,
        srcStrideU: buffer.strideU,
        srcV: buffer.dataV,
        srcStrideV: buffer.strideV,
        dstARGB: UnsafeMutablePointer<UInt8>(OpaquePointer(dst)),
        dstStrideARGB: Int32(bytesPerRow),
        width: buffer.width,
        height: buffer.height
      )
      CVPixelBufferUnlockBaseAddress(self.pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
    }

    DispatchQueue.main.async {
      if !self.isFirstFrameRendered {
        self.isFirstFrameRendered = true
        self.broadcastEventObserver().onFirstFrameRendered(id: self.textureId)
      }
      self.registry.textureFrameAvailable(self.textureId)
    }
  }
}
