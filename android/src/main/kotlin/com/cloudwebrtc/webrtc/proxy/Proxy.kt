package com.cloudwebrtc.webrtc.proxy

import org.webrtc.ThreadUtils

/**
 * Interface responsible for the proxy's underlying `libwebrtc` object update.
 *
 * For example, when `PeerConnection.getSenders` is called, then all old
 * `libwebrtc`'s `RtpSender` will be outdated. To keep this from happening
 * `PeerConnection` should update `RtpSender`s with a newly obtained `RtpSender`s
 * with [Proxy.replace] method.
 */
interface Proxy<T> {
    /**
     * Underlying `libwebrtc` object of this proxy.
     */
    var obj: T

    /**
     * Notifies proxy about [obj] update.
     */
    fun syncWithObject() {}

    /**
     * Replaces [obj] and notifies proxy about it.
     */
    fun replace(newObj: T) {
        ThreadUtils.checkIsOnMainThread()
        obj = newObj
        syncWithObject()
    }
}