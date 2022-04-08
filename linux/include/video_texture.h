#pragma once

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <memory>
#include <mutex>

#include "flutter_webrtc/flutter_web_r_t_c_plugin.h"
#include "iostream"

struct _VideoTextureClass {
  FlPixelBufferTextureClass parent_class;

  // Mutex that guards `frame_` field accessed from multiple threads.
  std::mutex mutex = std::mutex();

  // ID of this texture
  int64_t texture_id = 0;

  // Frame that should be rendered.
  std::optional<VideoFrame> frame_;

  // Buffer that contains the actual `ARGB` bytes that we pass to the Flutter.
  uint8_t* buffer_ = nullptr;
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
  const std::lock_guard<std::mutex> lock(v_texture->mutex);

  if (v_texture->buffer_ == nullptr) {
    // Allocate buffer on first run.
    v_texture->buffer_ = new uint8_t[v_texture->frame_->buffer_size];
  } else if (sizeof(v_texture->buffer_) != v_texture->frame_->buffer_size) {
    // Recreate buffer if image was resized.
    delete v_texture->buffer_;
    v_texture->buffer_ = new uint8_t[v_texture->frame_->buffer_size];
  }
  v_texture->frame_->GetABGRBytes(v_texture->buffer_);

  *out_buffer = v_texture->buffer_;
  *width = v_texture->frame_->width;
  *height = v_texture->frame_->height;

  return TRUE;
}

static VideoTexture* video_texture_new() {
  return DART_VIDEO_TEXTURE(g_object_new(video_texture_get_type(), nullptr));
}

static void video_texture_class_init(VideoTextureClass* klass) {
  FL_PIXEL_BUFFER_TEXTURE_CLASS(klass)->copy_pixels = video_texture_copy_pixels;
}

static void video_texture_init(VideoTexture* self) {}
