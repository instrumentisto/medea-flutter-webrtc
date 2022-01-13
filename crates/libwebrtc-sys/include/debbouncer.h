#include <iostream>
#include <thread>
#include <chrono>
#include <atomic>

class CustomTimer {
  std::atomic<bool> active{ true };

public:
  template<typename Function>
  void setTimeout(Function function, int delay) {
    active = true;
    std::thread t([=]() {
      if (!active.load()) return;
      std::this_thread::sleep_for(std::chrono::milliseconds(delay));
      if (!active.load()) return;
      function();
      });
    t.detach();
  };

  template<typename Function>
  void setInterval(Function function, int interval) {
    active = true;
    std::thread t([=]() {
      while (active.load()) {
        std::this_thread::sleep_for(std::chrono::milliseconds(interval));
        if (!active.load()) return;
        function();
      }
      });
    t.detach();
  };

  void stop() {
    active = false;
  };

};
