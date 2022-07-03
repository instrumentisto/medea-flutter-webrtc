#ifndef FLUTTER_PLUGIN_FLUTTER_WEBRTC_PLUGIN_H_
#define FLUTTER_PLUGIN_FLUTTER_WEBRTC_PLUGIN_H_

#include <flutter_linux/flutter_linux.h>

struct Frame final {
  size_t height;
  size_t width;
  int32_t rotation;
  size_t buffer_size;
  void* frame;
};

G_BEGIN_DECLS

#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __attribute__((visibility("default")))
#else
#define FLUTTER_PLUGIN_EXPORT
#endif

typedef struct _FlutterWebrtcPlugin FlutterWebrtcPlugin;
typedef struct {
  GObjectClass parent_class;
} FlutterWebrtcPluginClass;

FLUTTER_PLUGIN_EXPORT GType flutter_webrtc_plugin_get_type();

FLUTTER_PLUGIN_EXPORT void flutter_web_r_t_c_plugin_register_with_registrar(
    FlPluginRegistrar* registrar);

FLUTTER_PLUGIN_EXPORT void on_frame_caller(void* obj, Frame frame);
FLUTTER_PLUGIN_EXPORT void drop_handler(void* obj);

G_END_DECLS

#endif  // FLUTTER_PLUGIN_FLUTTER_WEBRTC_PLUGIN_H_