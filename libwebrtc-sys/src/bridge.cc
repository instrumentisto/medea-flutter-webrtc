#include <memory>
#include <string>

#include "../bridge.h"
#include "../wrapper.h"

namespace RTC {
    std::unique_ptr<std::string> SystemTimeMillis() {
        long long a = rtc::SystemTimeMillis();
        std::string b = std::to_string(a);

        return std::make_unique<std::string>(b);
    }
}
