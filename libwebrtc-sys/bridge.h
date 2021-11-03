#pragma once

#include <memory>
#include <string>
#include "include/wrapper.h"

namespace bridge {
    std::unique_ptr<std::string> bridge_hello_world();
}
