package com.cloudwebrtc.webrtc.utils;

import androidx.annotation.NonNull;
import io.flutter.plugin.common.MethodCall;

public interface MethodCallObserver {
  void observerMethodCall(MethodCall call, @NonNull AnyThreadResult result);
}
