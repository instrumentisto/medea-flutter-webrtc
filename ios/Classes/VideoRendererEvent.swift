protocol VideoRendererEvent {
  func onFirstFrameRendered(id: Int64)
  func onTextureChangeVideoSize(id: Int64, height: Int32, width: Int32)
  func onTextureChangeRotation(id: Int64, rotation: Int)
}
