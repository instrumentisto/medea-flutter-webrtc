package com.cloudwebrtc.webrtc

interface IWebRTCProxy<T> {
    var obj: T

    fun syncWithObject()

    fun updateObject(newObj: T) {
        obj = newObj
        syncWithObject()
    }

    fun dispose()
}