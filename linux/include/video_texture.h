#pragma once
#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <mutex>
#include <memory>

#include "flutter_webrtc/flutter_web_r_t_c_plugin.h"

struct _VideoTextureClass {
  FlPixelBufferTextureClass parent_class;
  int64_t texture_id = 0;
  uint8_t* buffer = nullptr;
  int32_t video_width = 0;
  int32_t video_height = 0;

  uint8_t* buffer_ = nullptr;
  int32_t video_width_ = 0;
  int32_t video_height_ = 0;

  std::shared_ptr<std::mutex> mutex;
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

  

  auto v_texture = DART_VIDEO_TEXTURE_GET_CLASS(texture);
  const std::lock_guard<std::mutex> lock(*v_texture->mutex);

  *out_buffer = v_texture->buffer;
  *width = v_texture->video_width;
  *height = v_texture->video_height;

  std::swap(v_texture->buffer, v_texture->buffer_);
  std::swap(v_texture->video_height, v_texture->video_height_);
  std::swap(v_texture->video_width, v_texture->video_width_);

  return TRUE;
}

static VideoTexture* video_texture_new() {
  return DART_VIDEO_TEXTURE(g_object_new(video_texture_get_type(), nullptr));
}

static void video_texture_class_init(VideoTextureClass* klass) {
  FL_PIXEL_BUFFER_TEXTURE_CLASS(klass)->copy_pixels = video_texture_copy_pixels;
}

static void video_texture_init(VideoTexture* self) {}
