#if __APPLE__

#include "mouse_cursor_monitor_mac.h"

namespace bridge {

MouseCursorMonitorMac::MouseCursorMonitorMac(std::unique_ptr<webrtc::MouseCursorMonitor> mouse_monitor) {
    mouse_monitor_ = std::move(mouse_monitor);
}

void MouseCursorMonitorMac::Init(webrtc::MouseCursorMonitor::Callback* callback, webrtc::MouseCursorMonitor::Mode mode) {
    mouse_monitor_->Init(callback, mode);
}

void MouseCursorMonitorMac::Capture() {
    @autoreleasepool {
        mouse_monitor_->Capture();
    }
}

}  // namespace bridge

#endif
