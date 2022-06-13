#include "include/medea_jason_webrtc/medea_jason_webrtc_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "medea_jason_webrtc_plugin.h"

void MedeaJasonWebrtcPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  medea_jason_webrtc::MedeaJasonWebrtcPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
