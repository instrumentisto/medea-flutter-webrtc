/*
 *  Copyright 2013 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#include "local_audio_source.h"

// using webrtc::MediaSourceInterface;

namespace bridge {

rtc::scoped_refptr<LocalAudioSource> LocalAudioSource::Create(cricket::AudioOptions audio_options) {
  auto source = rtc::make_ref_counted<LocalAudioSource>();
  source->Initialize(audio_options);
  return source;
}

void LocalAudioSource::Initialize(const cricket::AudioOptions audio_options) {
  RTC_LOG(LS_ERROR) << "LocalAudioSource::Initialize";
  options_ = audio_options;
}

void LocalAudioSource::AddSink(webrtc::AudioTrackSinkInterface* sink) {
  _sinks.push_back(sink);
  RTC_LOG(LS_ERROR) << "LocalAudioSource::AddSink";
}

void LocalAudioSource::RemoveSink(webrtc::AudioTrackSinkInterface* sink) {
  RTC_LOG(LS_ERROR) << "LocalAudioSource::RemoveSink";
}

void LocalAudioSource::OnData(const void* audio_data,
                    int bits_per_sample,
                    int sample_rate,
                    size_t number_of_channels,
                    size_t number_of_frames) {
  RTC_LOG(LS_ERROR) << "OnData";
  _sinks.front()->OnData(audio_data, bits_per_sample, sample_rate, number_of_channels, number_of_frames);
}

}  // namespace webrtc
