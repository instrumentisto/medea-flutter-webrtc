#pragma once
#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>

#include "flutter_webrtc/flutter_web_r_t_c_plugin.h"

struct _VideoTextureClass {
  FlPixelBufferTextureClass parent_class;
  int64_t texture_id = 0;
  uint8_t* buffer = nullptr;
  int32_t video_width = 0;
  int32_t video_height = 0;
};

G_DECLARE_DERIVABLE_TYPE(VideoTexture,
                         video_texture,
                         DART,
                         VIDEO_TEXTURE,
                         FlPixelBufferTexture)

G_DEFINE_TYPE(VideoTexture, video_texture, fl_pixel_buffer_texture_get_type())

static gboolean video_texture_copy_pixels(FlPixelBufferTexture* texture,
                                          const uint8_t** out_buffer,
                                          uint32_t* width,
                                          uint32_t* height,
                                          GError** error) {
  *out_buffer = DART_VIDEO_TEXTURE_GET_CLASS(texture)->buffer;
  *width = DART_VIDEO_TEXTURE_GET_CLASS(texture)->video_width;
  *height = DART_VIDEO_TEXTURE_GET_CLASS(texture)->video_height;
  return TRUE;
}

static VideoTexture* video_texture_new() {
  return DART_VIDEO_TEXTURE(g_object_new(video_texture_get_type(), nullptr));
}

static void video_texture_class_init(VideoTextureClass* klass) {
  FL_PIXEL_BUFFER_TEXTURE_CLASS(klass)->copy_pixels = video_texture_copy_pixels;
}

static void video_texture_init(VideoTexture* self) {}
