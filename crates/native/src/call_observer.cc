#include "C:/Users/Human/Documents/GitHub/flutter-webrtc/crates/native/include/call_observer.h"

void call_success(std::unique_ptr<MyObserver> obs, const std::string& sdp, const std::string& type_) {
    obs.get()->success(sdp, type_);
}
void call_fail(std::unique_ptr<MyObserver> obs, const std::string& error) {
    obs.get()->fail(error);
}