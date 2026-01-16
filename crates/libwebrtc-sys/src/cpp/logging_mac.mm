#if defined(WEBRTC_MAC)

#include <iostream>
#include <mutex>
#include "rtc_base/logging.h"
#include "sdk/objc/base/RTCLogging.h"

namespace bridge {

// `webrtc::LogSink` that overrides the logging callbacks to print messages
// to the standard output streams. Warnings and errors are directed to stderr,
// while other logs go to stdout.
class SysLogSink : public webrtc::LogSink {
 public:
  ~SysLogSink() override = default;

  // Handle a log message without severity information printing it
  // to `std::cout`.
  void OnLogMessage(const std::string& message) override {
    std::cout << message << std::endl;
  }

  // Handle a log message with severity information. If the severity is
  // warning or higher, the message is printed to `std::cerr`.
  void OnLogMessage(const std::string& message,
                    webrtc::LoggingSeverity severity) override {
    if (severity >= webrtc::LS_WARNING) {
      std::cerr << message;
    } else {
      std::cout << message;
    }
  }
};

// Guards `g_sys_log_sink` initialization.
std::mutex g_sys_log_sink_mutex;

// Custom `webrtc::LogSink`, initialized once, guarded by
// `g_sys_log_sink_mutex`.
SysLogSink* g_sys_log_sink = nullptr;

// Configures the WebRTC logging sink for macOS/iOS.
//
// This function initializes a custom log sink that redirects WebRTC
// logs to stdout or stderr based on the log severity.
void SetWebRTCLogSink(webrtc::LoggingSeverity severity) {
  std::lock_guard<std::mutex> lock(g_sys_log_sink_mutex);
  if (severity != webrtc::LS_NONE && !g_sys_log_sink) {
    g_sys_log_sink = new SysLogSink();
    webrtc::LogMessage::AddLogToStream(g_sys_log_sink, severity);
  }
}

}  // namespace bridge

#endif // WEBRTC_MAC
