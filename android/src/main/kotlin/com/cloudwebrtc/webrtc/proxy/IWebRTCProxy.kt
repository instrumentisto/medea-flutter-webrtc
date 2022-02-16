package com.cloudwebrtc.webrtc.proxy

import org.webrtc.ThreadUtils

// TODO(#34): docs
interface IWebRTCProxy<T> {
    var obj: T

    fun syncWithObject() {}

    fun replace(newObj: T) {
        ThreadUtils.checkIsOnMainThread()
        obj = newObj
        syncWithObject()
    }
}