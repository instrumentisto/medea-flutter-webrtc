class VideoRendererEventController: VideoRendererEvent {
  private var eventController: EventController
  private var messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger, eventController: EventController) {
    self.messenger = messenger
    self.eventController = eventController
  }

  func onFirstFrameRendered(id: Int64) {
    self.eventController.sendEvent(data: [
      "event": "onFirstFrameRendered",
      "id": id,
    ])
  }

  func onTextureChangeVideoSize(id: Int64, height: Int32, width: Int32) {
    self.eventController.sendEvent(data: [
      "event": "onTextureChangeVideoSize",
      "id": id,
      "width": width,
      "height": height,
    ])
  }

  func onTextureChangeRotation(id: Int64, rotation: Int) {
    self.eventController.sendEvent(data: [
      "event": "onTextureChangeRotation",
      "id": id,
      "rotation": rotation,
    ])
  }
}
