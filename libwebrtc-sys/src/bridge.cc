#include <memory>
#include <string>

#include "../bridge.h"

namespace bridge {
    std::unique_ptr<std::string> bridge_hello_world() {
        long long a = rtc::SystemTimeMillis();
        std::string b = std::to_string(a);
        
        return std::make_unique<std::string>(b);
    }
}
