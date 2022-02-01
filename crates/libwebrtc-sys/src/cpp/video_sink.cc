#include "video_sink.h"
#include "libwebrtc-sys/src/bridge.rs.h"
#include <iostream>

namespace video_sink {

// Creates a new `ForwardingVideoSink` backed by the provided
// `DynOnFrameCallback`.
ForwardingVideoSink::ForwardingVideoSink(
    rust::Box<bridge::DynOnFrameCallback> cb_) : cb_(std::move(cb_)) {
    std::cout << "CPP ForwardingVideoSink::ctor\n";
   }

void ForwardingVideoSink::OnFrame(const webrtc::VideoFrame& video_frame) {
  std::cout << "CPP ForwardingVideoSink::OnFrame\n";
  bridge::on_frame(*cb_.value(),
                   std::make_unique<webrtc::VideoFrame>(video_frame));
}

void ForwardingVideoSink::OnDiscardedFrame() {
  std::cout << "CPP ForwardingVideoSink::OnDiscardedFrame\n";
}

}  // namespace video_sink
