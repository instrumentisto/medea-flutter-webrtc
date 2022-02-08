package com.cloudwebrtc.webrtc.utils

import android.os.Handler
import io.flutter.plugin.common.EventChannel.EventSink
import android.os.Looper
import java.lang.Runnable

/**
 * Thread agnostic [EventSink] for sending events from Android side to the Flutter.
 *
 * @property eventSink underlying socket, into which all events will be sent.
 */
class AnyThreadSink(private val eventSink: EventSink) : EventSink {
    /**
     * [Runnable] executor on the main Android looper.
     */
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

    /**
     * Schedules provided [Runnable] on the main Android looper using [handler].
     *
     * @param r [Runnable] which will be scheduled.
     */
    private fun post(r: Runnable) {
        if (Looper.getMainLooper() == Looper.myLooper()) {
            r.run()
        } else {
            handler.post(r)
        }
    }
}