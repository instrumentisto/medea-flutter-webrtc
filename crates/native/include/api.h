#pragma once

struct Frame;

class OnFrameHandler {
 public:
  virtual ~OnFrameHandler() = default;
  virtual void OnFrame(Frame*) = 0;
};
