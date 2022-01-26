#pragma once

#include "rust/cxx.h"

struct Frame;

class OnFrameHandler {
 public:
  virtual void OnFrame(Frame*) = 0;
};
