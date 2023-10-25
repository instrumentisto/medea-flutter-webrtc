#pragma once

#if __APPLE__

#include "modules/desktop_capture/mouse_cursor_monitor.h"

namespace bridge {

// Captures mouse shape and position.
class MouseCursorMonitorMac: public webrtc::MouseCursorMonitor {

public:
  MouseCursorMonitorMac(std::unique_ptr<webrtc::MouseCursorMonitor> mouse_monitor);

  // Initializes the monitor with the `callback`, which must remain valid until
  // capturer is destroyed.
  virtual void Init(Callback* callback, Mode mode) override;

  void Capture() override;

private:
    std::unique_ptr<webrtc::MouseCursorMonitor> mouse_monitor_;
};



}  // namespace bridge

#endif

