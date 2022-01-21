#pragma once
#include <string>
#include <memory>

class MyObserver {
public: 
    virtual void success(const std::string& sdp, const std::string& type) = 0;
    virtual void fail(const std::string& error) = 0;
    virtual ~MyObserver() = default;
};