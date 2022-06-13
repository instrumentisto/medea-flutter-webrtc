#ifndef FLUTTER_PLUGIN_MEDEA_JASON_WEBRTC_PLUGIN_H_
#define FLUTTER_PLUGIN_MEDEA_JASON_WEBRTC_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include "video_renderer.h"

#include <memory>

namespace medea_jason_webrtc {

class MedeaJasonWebrtcPlugin : public flutter::Plugin,
                               public FlutterVideoRendererManager {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  MedeaJasonWebrtcPlugin(flutter::PluginRegistrarWindows* registrar);

  virtual ~MedeaJasonWebrtcPlugin();

  // Disallow copy and assign.
  MedeaJasonWebrtcPlugin(const MedeaJasonWebrtcPlugin&) = delete;
  MedeaJasonWebrtcPlugin& operator=(const MedeaJasonWebrtcPlugin&) = delete;

  // `BinaryMessenger` is used to open `EventChannel`s to the Dart side.
  flutter::BinaryMessenger* messenger_;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace medea_jason_webrtc

#endif  // FLUTTER_PLUGIN_MEDEA_JASON_WEBRTC_PLUGIN_H_
