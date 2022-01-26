#include "native/include/rust_call_callback.h"

void call_on_event(MyEventCallback& cb, const std::string& event) {
    cb.OnEvent(event);
}