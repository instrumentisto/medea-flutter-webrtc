#if defined(WEBRTC_MAC)

#import <Foundation/Foundation.h>
#import <ScreenCaptureKit/ScreenCaptureKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AppKit/AppKit.h>
#include <unistd.h>
#include <objc/message.h>
#include <vector>
#include <algorithm>
#include <limits>
#include "rtc_base/logging.h"
#include "libwebrtc-sys/include/sys_audio_capture/mac_capture.h"

constexpr float kInt16MaxAsFloat = static_cast<float>(std::numeric_limits<int16_t>::max());
constexpr int32_t kInt16Min = std::numeric_limits<int16_t>::min();
constexpr int32_t kInt16Max = std::numeric_limits<int16_t>::max();
constexpr long kShareableContentTimeoutSeconds = 5;

bool IsSysAudioCaptureAvailable() {
  if (@available(macOS 13.0, *)) {
    return true;
  } else {
    return false;
  }
}

/// SCStreamOutput that forwards audio buffers to a C++ SysAudioSource instance.
API_AVAILABLE(macos(13.0))
@interface SystemAudioDelegate : NSObject <SCStreamOutput, SCStreamDelegate>
/// `SysAudioSource` that this `SCStreamOutput` forwards captured audio to.
@property(nonatomic, assign) SysAudioSource* owner;
@end

@implementation SystemAudioDelegate
- (void)stream:(SCStream*)stream didStopWithError:(NSError *)error {
  if (error) {
    RTC_LOG(LS_ERROR) << "SystemAudioDelegate: Stream stopped with error: " << error.code;
  } else {
    RTC_LOG(LS_VERBOSE) << "SystemAudioDelegate: Stream stopped without error.";
  }
  if (self.owner) {
    self.owner->StopCapture();
  }
}
- (void)stream:(SCStream*)stream didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer ofType:(SCStreamOutputType)type {
  if (type != SCStreamOutputTypeAudio) {
    RTC_LOG(LS_VERBOSE) << "SystemAudioDelegate: Ignoring non-audio output type: " << (int)type;
    return;
  }

  if (!CMSampleBufferIsValid(sampleBuffer)) {
    RTC_LOG(LS_ERROR) << "SystemAudioDelegate: Received invalid CMSampleBuffer.";
    return;
  }

  CMFormatDescriptionRef fmt = CMSampleBufferGetFormatDescription(sampleBuffer);
  if (!fmt) {
    RTC_LOG(LS_ERROR) << "SystemAudioDelegate: Missing CMFormatDescription from CMSampleBuffer.";
    return;
  }

  const AudioStreamBasicDescription* asbd = CMAudioFormatDescriptionGetStreamBasicDescription(fmt);
  if (!asbd) {
    RTC_LOG(LS_ERROR) << "SystemAudioDelegate: Missing AudioStreamBasicDescription.";
    return;
  }

  if (asbd->mFormatID != kAudioFormatLinearPCM) {
    RTC_LOG(LS_ERROR) << "SystemAudioDelegate: Unsupported audio format (mFormatID=" << (unsigned int)asbd->mFormatID << ") expected kAudioFormatLinearPCM.";
    return;
  }

  const bool isFloat = (asbd->mFormatFlags & kAudioFormatFlagIsFloat) != 0;
  const bool isNonInterleaved = (asbd->mFormatFlags & kAudioFormatFlagIsNonInterleaved) != 0;
  const UInt32 channels = asbd->mChannelsPerFrame;

  if (channels == 0) {
    RTC_LOG(LS_ERROR) << "SystemAudioDelegate: AudioStreamBasicDescription reports zero channels.";
    return;
  }

  const CMItemCount totalFrames = CMSampleBufferGetNumSamples(sampleBuffer);
  if (totalFrames <= 0) {
    RTC_LOG(LS_ERROR) << "SystemAudioDelegate: CMSampleBuffer has zero frames.";
    return;
  }

  if (!isFloat && asbd->mBitsPerChannel != 16) {
    RTC_LOG(LS_ERROR) << "SystemAudioDelegate: Unsupported integer PCM bits per channel: " << (unsigned int)asbd->mBitsPerChannel << ", only 16-bit supported.";
    return;
  }

  if (isNonInterleaved) {
    CMBlockBufferRef retainedBlock = nullptr;
    const size_t ablSize = sizeof(AudioBufferList) + (channels - 1) * sizeof(AudioBuffer);
    std::vector<uint8_t> ablStorage(ablSize);
    AudioBufferList* abl = reinterpret_cast<AudioBufferList*>(ablStorage.data());
    abl->mNumberBuffers = channels;

    OSStatus st = CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(
        sampleBuffer,
        nullptr,
        abl,
        ablSize,
        kCFAllocatorDefault,
        kCFAllocatorDefault,
        0,
        &retainedBlock);
    if (st != noErr) {
      RTC_LOG(LS_ERROR) << "SystemAudioDelegate: CMAudioSampleBufferGetAudioBufferListWithRetainedBlockBuffer failed with status: " << (int)st;
      return;
    }

    std::vector<int16_t> mono;
    mono.reserve((size_t)totalFrames);

    if (isFloat) {
      // Float planar to mono S16
      for (CMItemCount i = 0; i < totalFrames; ++i) {
        double acc = 0.0;
        for (UInt32 c = 0; c < channels; ++c) {
          const float* src = reinterpret_cast<const float*>(abl->mBuffers[c].mData);
          acc += src[i];
        }
        float v = (float)(acc / (double)channels);
        v = std::clamp(v, -1.0f, 1.0f);
        mono.push_back((int16_t)lrintf(v * kInt16MaxAsFloat));
      }
    } else {
      if (channels == 1) {
        // S16 planar mono is what we need so just copy.
        const int16_t* src = reinterpret_cast<const int16_t*>(abl->mBuffers[0].mData);
        mono.insert(mono.end(), src, src + totalFrames);
      } else {
        // S16 planar multi-channel to mono.
        for (CMItemCount i = 0; i < totalFrames; ++i) {
          long acc = 0;
          for (UInt32 c = 0; c < channels; ++c) {
            const int16_t* src = reinterpret_cast<const int16_t*>(abl->mBuffers[c].mData);
            acc += src[i];
          }
          mono.push_back((int16_t)(acc / (long)channels));
        }
      }
    }

    if (self.owner) {
      self.owner->OnPcmDataFromSC(mono.data(), (size_t)totalFrames, 1, asbd->mSampleRate);
    }

    if (retainedBlock) {
      CFRelease(retainedBlock);
    }
    return;
  } else {
    CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    if (!blockBuffer) {
      RTC_LOG(LS_ERROR) << "SystemAudioDelegate: Missing CMBlockBuffer in CMSampleBuffer.";
      return;
    }

    size_t length = 0;
    char* dataPtr = nullptr;
    OSStatus getPtrStatus = CMBlockBufferGetDataPointer(blockBuffer, 0, nullptr, &length, &dataPtr);
    if (getPtrStatus != kCMBlockBufferNoErr) {
      RTC_LOG(LS_ERROR) << "SystemAudioDelegate: CMBlockBufferGetDataPointer failed with status: " << (int)getPtrStatus;
      return;
    }

    if (length == 0) {
      RTC_LOG(LS_ERROR) << "SystemAudioDelegate: CMBlockBuffer has zero length.";
      return;
    }

    const UInt32 bytesPerFrame = asbd->mBytesPerFrame;
    if (bytesPerFrame == 0) {
      RTC_LOG(LS_ERROR) << "SystemAudioDelegate: AudioStreamBasicDescription reports zero bytesPerFrame.";
      return;
    }

    const size_t frames = length / bytesPerFrame;

    if (isFloat) {
      const float* fsrc = reinterpret_cast<const float*>(dataPtr);
      std::vector<int16_t> tmp;
      tmp.reserve(frames);
      if (channels == 1) {
        // Float interleaved mono to S16.
        for (size_t i = 0; i < frames; ++i) {
          float v = std::clamp(fsrc[i], -1.0f, 1.0f);
          tmp.push_back((int16_t) lrintf(v * kInt16MaxAsFloat));
        }
      } else {
        // Float interleaved multi-channel to mono
        for (size_t i = 0; i < frames; ++i) {
          double acc = 0.0;
          for (UInt32 c = 0; c < channels; ++c) {
            acc += fsrc[i * channels + c];
          }
          float v = (float) (acc / (double) channels);
          v = std::clamp(v, -1.0f, 1.0f);
          tmp.push_back((int16_t) lrintf(v * kInt16MaxAsFloat));
        }
      }
      if (self.owner) {
        // Hand off mono S16 PCM; resampling (if needed) happens downstream.
        self.owner->OnPcmDataFromSC(tmp.data(), frames, 1, asbd->mSampleRate);
      }
    } else {
      if (channels == kRecordingChannels) {
        // S16 interleaved, channel count already matches target: forward as-is.
        if (self.owner) {
          self.owner->OnPcmDataFromSC(reinterpret_cast<const int16_t *>(dataPtr),
                                      frames,
                                      channels,
                                      asbd->mSampleRate);
        }
      } else {
        // S16 interleaved multichannel, downmix to mono by averaging.
        std::vector<int16_t> mono;
        mono.reserve(frames);
        const int16_t* src = reinterpret_cast<const int16_t*>(dataPtr);
        for (size_t i = 0; i < frames; ++i) {
          long acc = 0;
          for (UInt32 c = 0; c < channels; ++c) {
            acc += src[i * channels + c];
          }
          mono.push_back(static_cast<int16_t>(acc / (long)channels));
        }
        if (self.owner) {
          self.owner->OnPcmDataFromSC(mono.data(), frames, 1, asbd->mSampleRate);
        }
      }
    }
  }
}
@end

API_AVAILABLE(macos(13.0)) SysAudioSource::SysAudioSource() {
  recorded_samples_.reserve(kRecordingPart * kRecordingChannels);
  source_ = bridge::LocalAudioSource::Create(webrtc::AudioOptions(), nullptr);
}


API_AVAILABLE(macos(13.0)) bool SysAudioSource::StartCapture() {
  std::lock_guard<std::recursive_mutex> lock(mutex_);

  if (recording_) {
    return false;
  }

  @autoreleasepool {
    __block SCShareableContent* content = nil;
    __block NSError* contentError = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [SCShareableContent getShareableContentWithCompletionHandler:^(SCShareableContent *c, NSError *err) {
         content = c;
         contentError = err;
         dispatch_semaphore_signal(sema);
       }];

    // Wait up to kShareableContentTimeoutSeconds seconds max.
    long waitResult = dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, kShareableContentTimeoutSeconds * NSEC_PER_SEC));
    if (waitResult != 0) {
      RTC_LOG(LS_ERROR) << "SysAudioSource(Mac): Timeout waiting for shareable content.";
      return false;
    }
    if (!content || contentError) {
      RTC_LOG(LS_ERROR) << "SysAudioSource(Mac): Failed to get shareable content.";
      return false;
    }

    SCDisplay* display = content.displays.firstObject;
    if (!display) {
      RTC_LOG(LS_ERROR) << "SysAudioSource(Mac): Failed to find any displays.";
      return false;
    }

    SCContentFilter* filter = nil;
    if ([SCContentFilter instancesRespondToSelector:@selector(initWithDisplay:excludingApplications:exceptingWindows:)]) {
      filter = [[SCContentFilter alloc] initWithDisplay:display excludingApplications:@[] exceptingWindows:@[]];
    }

    if (!filter) {
      RTC_LOG(LS_ERROR) << "SysAudioSource(Mac): Failed to create SCContentFilter.";
      return false;
    }

    SCStreamConfiguration* cfg = [[SCStreamConfiguration alloc] init];
    cfg.capturesAudio = YES;
    cfg.sampleRate = kRecordingFrequency;
    cfg.channelCount = kRecordingChannels;
    cfg.excludesCurrentProcessAudio = YES;

    SystemAudioDelegate* output = [[SystemAudioDelegate alloc] init];
    output.owner = this;

    SCStream* stream = [[SCStream alloc] initWithFilter:filter configuration:cfg delegate:output];
    if (!stream) {
      RTC_LOG(LS_ERROR) << "SysAudioSource(Mac): Failed to create SCStream.";
      return false;
    }

    dispatch_queue_t q = dispatch_queue_create("SysAudioSource.SCStreamOutput", DISPATCH_QUEUE_SERIAL);
    sample_queue_ = (__bridge_retained void*)q;

    NSError *addStreamOutputError = nil;
    BOOL add_output_ok = [stream addStreamOutput:output type:SCStreamOutputTypeAudio
                                sampleHandlerQueue:q
                                             error:&addStreamOutputError];
    if (!add_output_ok) {
      RTC_LOG(LS_ERROR) << "SysAudioSource(Mac): addStreamOutput (SCStreamOutputTypeAudio) error: " << addStreamOutputError.code;
      return false;
    }

    stream_ = (__bridge_retained void*) stream;
    output_ = (__bridge_retained void*) output;
    recording_ = true;

    [stream startCaptureWithCompletionHandler:^(NSError *startError) {
      if (startError) {
        RTC_LOG(LS_ERROR) << "SysAudioSource(Mac): startCapture error: " << startError.code;
        std::lock_guard<std::recursive_mutex> guard(mutex_);
        recording_ = false;
      }
    }];
  }

  return true;
}

API_AVAILABLE(macos(13.0)) void SysAudioSource::StopCapture() {
  std::lock_guard<std::recursive_mutex> lock(mutex_);

  if (!recording_) {
    return;
  }
  recording_ = false;

  @autoreleasepool {
    SCStream* stream = (__bridge SCStream*)stream_;
    SystemAudioDelegate* output = (__bridge SystemAudioDelegate*)output_;
    dispatch_queue_t q = nullptr;
    if (sample_queue_) {
      q = (__bridge_transfer dispatch_queue_t)sample_queue_;
      sample_queue_ = nullptr;
    }

    if (stream && output) {
      NSError* remErr = nil;
      [stream removeStreamOutput:output type:SCStreamOutputTypeAudio error:&remErr];
      output.owner = nullptr;
    }

    // Keep local strong references for async completion, but null out members now.
    void* stream_to_release = stream_;
    void* output_to_release = output_;
    stream_ = nullptr;
    output_ = nullptr;

    if (stream) {
      [stream stopCaptureWithCompletionHandler:^(NSError *_Nullable error) {
        if (error && error.code != SCStreamErrorAttemptToStopStreamState) {
          RTC_LOG(LS_ERROR) << "SysAudioSource(Mac): stopCaptureWithCompletionHandler error: " << error.code;
        }
        if (stream_to_release) {
          CFRelease((__bridge CFTypeRef)((__bridge id)stream_to_release));
        }
        if (output_to_release) {
          CFRelease((__bridge CFTypeRef)((__bridge id)output_to_release));
        }
        (void)q;
      }];
    } else {
      if (stream_to_release) {
        CFRelease((__bridge CFTypeRef)((__bridge id)stream_to_release));
      }
      if (output_to_release) {
        CFRelease((__bridge CFTypeRef)((__bridge id)output_to_release));
      }
      (void)q;
    }
  }
}

bool SysAudioSource::ProcessRecordedPart(bool /*firstInCycle*/) {
  std::lock_guard<std::recursive_mutex> lock(mutex_);

  if (recorded_samples_.size() >= kRecordingPart) {
    source_->OnData(
            recorded_samples_.data(),
            kBitsPerSample,
            kRecordingFrequency,
            kRecordingChannels,
            kRecordingPart);
    recorded_samples_.erase(
            recorded_samples_.begin(),
            recorded_samples_.begin() + kRecordingPart);

    return true;
  }
  return false;
}

webrtc::scoped_refptr<bridge::LocalAudioSource> SysAudioSource::GetSource() {
  return source_;
}

void SysAudioSource::OnPcmDataFromSC(const int16_t* data,
                                     size_t frames,
                                     unsigned int channels,
                                     double sample_rate) {
  std::lock_guard<std::recursive_mutex> lock(mutex_);

  if (!recording_) {
    return;
  }

  // Resample if needed using linear interpolation.
  if ((int)sample_rate != kRecordingFrequency) {
    const double scale = sample_rate / (double)kRecordingFrequency; // in_frames = out_idx * scale
    const size_t outFrames = (size_t)((double)frames / scale);
    std::vector<int16_t> tmp;
    tmp.reserve(outFrames);
    for (size_t i = 0; i < outFrames; ++i) {
      double srcPos = i * scale;
      size_t idx0 = (size_t)srcPos;
      double frac = srcPos - (double)idx0;
      if (idx0 >= frames) idx0 = frames - 1;
      size_t idx1 = idx0 + 1;
      if (idx1 >= frames) idx1 = frames - 1;
      double v = (1.0 - frac) * (double)data[idx0] + frac * (double)data[idx1];
      int32_t vi = (int32_t)lrint(v);
      vi = std::clamp<int32_t>(vi, kInt16Min, kInt16Max);
      tmp.push_back((int16_t)vi);
    }
    recorded_samples_.insert(recorded_samples_.end(), tmp.begin(), tmp.end());
  } else {
    recorded_samples_.insert(
            recorded_samples_.end(),
            data,
            data + frames);
  }
}

#endif  // WEBRTC_MAC
