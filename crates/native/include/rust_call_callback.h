#pragma once
#include "callback.h"
#include "rust/cxx.h"
#include <memory>

void call_on_event(MyEventCallback& cb, const std::string& event);