package com.cloudwebrtc.webrtc.proxy

interface IWebRTCProxy<T> {
    var obj: T

    fun syncWithObject()

    fun updateObject(newObj: T) {
        obj = newObj
        syncWithObject()
    }

    fun dispose()
}