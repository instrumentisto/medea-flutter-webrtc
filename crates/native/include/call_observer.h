#pragma once
#include <string>
#include <memory>
#include "observer.h"

void call_success(std::unique_ptr<MyObserver> obs, const std::string& sdp, const std::string& type_);
void call_fail(std::unique_ptr<MyObserver> obs, const std::string& error);