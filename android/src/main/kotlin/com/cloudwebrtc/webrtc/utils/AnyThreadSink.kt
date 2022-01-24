package com.cloudwebrtc.webrtc.utils

import android.os.Handler
import io.flutter.plugin.common.EventChannel.EventSink
import android.os.Looper
import java.lang.Runnable

class AnyThreadSink(private val eventSink: EventSink) : EventSink {
    private val handler = Handler(Looper.getMainLooper())
    override fun success(o: Any) {
        post(Runnable { eventSink.success(o) })
    }

    override fun error(s: String, s1: String, o: Any) {
        post(Runnable { eventSink.error(s, s1, o) })
    }

    override fun endOfStream() {
        post(Runnable { eventSink.endOfStream() })
    }

    private fun post(r: Runnable) {
        if (Looper.getMainLooper() == Looper.myLooper()) {
            r.run()
        } else {
            handler.post(r)
        }
    }
}