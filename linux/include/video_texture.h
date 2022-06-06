#pragma once

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <memory>
#include <mutex>

#include "flutter_webrtc/flutter_web_r_t_c_plugin.h"
#include "iostream"

#define VIDEO_TEXTURE_TYPE                  (video_texture_get_type ())
#define VIDEO_TEXTURE(obj)                  (G_TYPE_CHECK_INSTANCE_CAST ((obj), VIDEO_TEXTURE_TYPE, VideoTexture))


typedef struct _VideoTexture        VideoTexture;
typedef struct _VideoTextureClass   VideoTextureClass;

struct _VideoTexture {

  FlPixelBufferTexture parent_instance;

  // Mutex guarding `frame_` field accessed from multiple threads.
  std::mutex mutex = std::mutex();

  // ID of this texture.
  int64_t texture_id = 0;

  // Frame that should be rendered.
  std::optional<Frame> frame_;
};

struct _VideoTextureClass {
  FlPixelBufferTextureClass parent_class;
};


G_DEFINE_TYPE(VideoTexture, video_texture, fl_pixel_buffer_texture_get_type())

static gboolean video_texture_copy_pixels(FlPixelBufferTexture* texture,
                                          const uint8_t** out_buffer,
                                          uint32_t* width,
                                          uint32_t* height,
                                          GError** error) {
  auto v_texture = VIDEO_TEXTURE(texture);

  const std::lock_guard<std::mutex> lock(v_texture->mutex);

  if (v_texture->frame_) {
    *out_buffer = v_texture->frame_->buffer;
    *width = v_texture->frame_->width;
    *height = v_texture->frame_->height;
  }

  return TRUE;
}

static VideoTexture* video_texture_new() {
  return VIDEO_TEXTURE(g_object_new(video_texture_get_type(), nullptr));
}

static void video_texture_class_init(VideoTextureClass* klass) {
  FL_PIXEL_BUFFER_TEXTURE_CLASS(klass)->copy_pixels = video_texture_copy_pixels;
}

static void video_texture_init(VideoTexture* self) {}
