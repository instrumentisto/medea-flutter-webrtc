/*
 *  Copyright (c) 2017 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#include "scalable_track_source.h"

#include <algorithm>

// WebRTC
#include <api/scoped_refptr.h>
#include <api/video/i420_buffer.h>
#include <api/video/video_frame_buffer.h>
#include <api/video/video_rotation.h>
#include <rtc_base/logging.h>

ScalableVideoTrackSource::ScalableVideoTrackSource()
    : AdaptedVideoTrackSource(4) {}
ScalableVideoTrackSource::~ScalableVideoTrackSource() {}

bool ScalableVideoTrackSource::is_screencast() const {
  return false;
}

absl::optional<bool> ScalableVideoTrackSource::needs_denoising() const {
  return false;
}

webrtc::MediaSourceInterface::SourceState ScalableVideoTrackSource::state()
    const {
  return SourceState::kLive;
}

bool ScalableVideoTrackSource::remote() const {
  return false;
}

void ScalableVideoTrackSource::OnCapturedFrame(
    const webrtc::VideoFrame& frame) {
  const int64_t timestamp_us = frame.timestamp_us();
  const int64_t translated_timestamp_us =
      timestamp_aligner_.TranslateTimestamp(timestamp_us, rtc::TimeMicros());

  rtc::scoped_refptr<webrtc::VideoFrameBuffer> buffer =
      frame.video_frame_buffer();

  OnFrame(webrtc::VideoFrame::Builder()
              .set_video_frame_buffer(buffer)
              .set_rotation(frame.rotation())
              .set_timestamp_us(translated_timestamp_us)
              .build());
}
