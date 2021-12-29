#include "flutter_webrtc_base.h"

namespace flutter_webrtc_plugin {

FlutterWebRTCBase::FlutterWebRTCBase(BinaryMessenger* messenger,
                                     TextureRegistrar* textures)
    : messenger_(messenger), textures_(textures) {}

FlutterWebRTCBase::~FlutterWebRTCBase() {}
}  // namespace flutter_webrtc_plugin
