package com.cloudwebrtc.webrtc.utils

import org.webrtc.EglBase
import kotlin.jvm.Synchronized
import com.cloudwebrtc.webrtc.utils.EglUtils
import android.os.Build

object EglUtils {
    /**
     * Lazily creates and returns the one and only [EglBase] which will serve as the root for
     * all contexts that are needed.
     */
    /**
     * The root [EglBase] instance shared by the entire application for the sake of reducing the
     * utilization of system resources (such as EGL contexts).
     */
    @get:Synchronized
    var rootEglBase: EglBase? = null
        get() {
            if (field == null) {
                field =
                    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) EglBase.createEgl10(
                        EglBase.CONFIG_PLAIN
                    ) else EglBase.create()
            }
            return field
        }
        private set
    @JvmStatic
    val rootEglBaseContext: EglBase.Context?
        get() {
            val eglBase = rootEglBase
            return eglBase?.eglBaseContext
        }
}