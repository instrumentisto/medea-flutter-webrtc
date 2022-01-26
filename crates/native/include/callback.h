#pragma once
#include <string>

class MyEventCallback {
    public:
    virtual void OnEvent(std::string event);
};