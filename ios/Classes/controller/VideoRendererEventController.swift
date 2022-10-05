/// Controller for the VideoRenderer events.
class VideoRendererEventController: VideoRendererEvent {
  /// Controller for the PeerConnection event channel.
  private var eventController: EventController

  /// Flutter messenger for creating another controllers.
  private var messenger: FlutterBinaryMessenger

  /**
    Creates new controller for sending all `FlutterRtcVideoRenderer`
    events to the Flutter side.
  */
  init(messenger: FlutterBinaryMessenger, eventController: EventController) {
    self.messenger = messenger
    self.eventController = eventController
  }

  /// Sends `onFirstFrameRendered` event to the Flutter side.
  func onFirstFrameRendered(id: Int64) {
    self.eventController.sendEvent(data: [
      "event": "onFirstFrameRendered",
      "id": id,
    ])
  }

  /// Sends `onTextureChangeVideoSize` event to the Flutter side.
  func onTextureChangeVideoSize(id: Int64, height: Int32, width: Int32) {
    self.eventController.sendEvent(data: [
      "event": "onTextureChangeVideoSize",
      "id": id,
      "width": width,
      "height": height,
    ])
  }

  /// Sends `onTextureChangeRotation` event to the Flutter side.
  func onTextureChangeRotation(id: Int64, rotation: Int) {
    self.eventController.sendEvent(data: [
      "event": "onTextureChangeRotation",
      "id": id,
      "rotation": rotation,
    ])
  }
}
