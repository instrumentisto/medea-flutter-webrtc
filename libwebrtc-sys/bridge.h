#pragma once

#include <memory>
#include <string>
#include "wrapper.h"

namespace bridge {
    std::unique_ptr<std::string> getSystemTime();
}
