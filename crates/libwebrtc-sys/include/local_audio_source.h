/*
 *  Copyright 2012 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#ifndef BRIDGE_LOCAL_AUDIO_SOURCE_H_
#define BRIDGE_LOCAL_AUDIO_SOURCE_H_

#include "api/audio_options.h"
#include "api/media_stream_interface.h"
#include "api/notifier.h"
#include "api/scoped_refptr.h"

// LocalAudioSource implements AudioSourceInterface.
// This contains settings for switching audio processing on and off.

namespace bridge {

class LocalAudioSource : public webrtc::Notifier<webrtc::AudioSourceInterface> {
 public:
  // Creates an instance of LocalAudioSource.
  static rtc::scoped_refptr<LocalAudioSource> Create(cricket::AudioOptions audio_options);

  SourceState state() const override { return kLive; }
  bool remote() const override { return false; }

  const cricket::AudioOptions options() const override { return options_; }

  void AddSink(webrtc::AudioTrackSinkInterface* sink) override {}
  void RemoveSink(webrtc::AudioTrackSinkInterface* sink) override {}

 protected:
  LocalAudioSource() {}
  ~LocalAudioSource() override {}

 private:
  void Initialize(cricket::AudioOptions audio_options);

  cricket::AudioOptions options_;
};

}  // namespace webrtc

#endif  // PC_LOCAL_AUDIO_SOURCE_H_
