#pragma once

#include <memory>
#include <string>

namespace bridge {
    std::unique_ptr<std::string> getSystemTime();
}
