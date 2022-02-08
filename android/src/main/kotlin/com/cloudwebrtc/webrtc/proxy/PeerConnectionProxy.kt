package com.cloudwebrtc.webrtc.proxy

import com.cloudwebrtc.webrtc.exception.AddIceCandidateException
import com.cloudwebrtc.webrtc.exception.CreateSdpException
import com.cloudwebrtc.webrtc.exception.SetSdpException
import com.cloudwebrtc.webrtc.model.*
import com.cloudwebrtc.webrtc.model.IceCandidate
import org.webrtc.*
import java.util.*
import kotlin.collections.HashMap
import kotlin.collections.HashSet
import kotlin.coroutines.Continuation
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine
import org.webrtc.SessionDescription as WSessionDescription

/**
 * Wrapper around [PeerConnection].
 *
 * @property id unique ID of this [PeerConnectionProxy].
 * @param peer underlying [PeerConnection].
 */
class PeerConnectionProxy(val id: Int, peer: PeerConnection) : IWebRTCProxy<PeerConnection> {
    /**
     * Actual underlying [PeerConnection].
     */
    override var obj: PeerConnection = peer

    /**
     * List of all [RtpSenderProxy]s owned by this [PeerConnectionProxy].
     */
    private var senders: HashMap<String, RtpSenderProxy> = HashMap()

    /**
     * List of all [RtpReceiverProxy]s owned by this [PeerConnectionProxy].
     */
    private var receivers: HashMap<String, RtpReceiverProxy> = HashMap()

    /**
     * List of all [RtpTransceiverProxy]s owned by this [PeerConnectionProxy].
     */
    private var transceivers: TreeMap<Int, RtpTransceiverProxy> = TreeMap()

    /**
     * List of subscribers on [dispose] event.
     *
     * This callbacks will be called on [dispose] method call.
     */
    private var onDisposeSubscribers: MutableList<(Int) -> Unit> = mutableListOf()

    /**
     * List of [EventObserver] for this [PeerConnectionProxy].
     */
    private var eventObservers: HashSet<EventObserver> = HashSet()

    init {
        syncWithObject()
    }

    companion object {
        /**
         * Observer of the [PeerConnectionProxy] events.
         */
        interface EventObserver {
            /**
             * Notifies observer about new [MediaStreamTrackProxy].
             *
             * @param track newly added [MediaStreamTrackProxy].
             * @param transceiver [RtpTransceiverProxy] of this [MediaStreamTrackProxy].
             */
            fun onAddTrack(track: MediaStreamTrackProxy, transceiver: RtpTransceiverProxy)

            /**
             * Notifies observer about [IceConnectionState] update.
             *
             * @param iceConnectionState new [IceConnectionState] of the [PeerConnectionProxy].
             */
            fun onIceConnectionStateChange(iceConnectionState: IceConnectionState)

            /**
             * Notifies observer about [SignalingState] update.
             *
             * @param signalingState new [SignalingState] of the [PeerConnectionProxy].
             */
            fun onSignalingStateChange(signalingState: SignalingState)

            /**
             * Notifies observer about [PeerConnectionState] update.
             *
             * @param peerConnectionState new [PeerConnectionState] of the [PeerConnectionProxy].
             */
            fun onConnectionStateChange(peerConnectionState: PeerConnectionState)

            /**
             * Notifies observer about [IceGatheringState] update.
             *
             * @param iceGatheringState new [IceGatheringState] of the [PeerConnectionProxy].
             */
            fun onIceGatheringStateChange(iceGatheringState: IceGatheringState)

            /**
             * Notifies observer about new [IceCandidate].
             *
             * @param candidate newly added [IceCandidate].
             */
            fun onIceCandidate(candidate: IceCandidate)
        }

        /**
         * Creates [SdpObserver] which will resolve provided [Continuation]
         * on [SdpObserver.onCreateSuccess] or [SdpObserver.onCreateFailure].
         *
         * @param continuation [Continuation] which will be resumed.
         * @return new [SdpObserver].
         */
        private fun createSdpObserver(continuation: Continuation<SessionDescription>): SdpObserver {
            return object : SdpObserver {
                override fun onCreateSuccess(sdp: WSessionDescription) {
                    continuation.resume(SessionDescription.fromWebRtc(sdp))
                }

                override fun onSetSuccess() {
                    throw RuntimeException("onSetSuccess function can't be called when creating offer")
                }

                override fun onCreateFailure(msg: String?) {
                    var message = msg
                    if (message == null) {
                        message = ""
                    }
                    continuation.resumeWithException(CreateSdpException(message))
                }

                override fun onSetFailure(msg: String?) {
                    throw RuntimeException("onSetFailure function can't be called when creating offer")
                }
            }
        }

        /**
         * Creates [SdpObserver] which will resolve provided [Continuation]
         * on [SdpObserver.onSetSuccess] or [SdpObserver.onSetFailure].
         *
         * @param continuation [Continuation] which will be resumed.
         * @return new [SdpObserver].
         */
        private fun setSdpObserver(continuation: Continuation<Unit>): SdpObserver {
            return object : SdpObserver {
                override fun onCreateSuccess(sdp: org.webrtc.SessionDescription?) {
                    throw RuntimeException("onCreateSuccess function can't be called when settings offer")
                }

                override fun onSetSuccess() {
                    continuation.resume(Unit)
                }

                override fun onCreateFailure(msg: String?) {
                    throw RuntimeException("onCreateFailure function can't be called when settings offer")
                }

                override fun onSetFailure(msg: String?) {
                    var message = msg
                    if (message == null) {
                        message = ""
                    }
                    continuation.resumeWithException(SetSdpException(message))
                }
            }
        }
    }

    override fun syncWithObject() {
        syncSenders()
        syncReceivers()
        syncTransceivers()
    }

    /**
     * Adds [EventObserver] for this [PeerConnectionProxy].
     *
     * @param eventObserver [EventObserver] which will be subscribed.
     */
    fun addEventObserver(eventObserver: EventObserver) {
        eventObservers.add(eventObserver)
    }

    /**
     * Removes [EventObserver] from this [PeerConnectionProxy].
     *
     * @param eventObserver [EventObserver] which will be unsubscribed.
     */
    fun removeEventObserver(eventObserver: EventObserver) {
        eventObservers.remove(eventObserver)
    }

    /**
     * Creates broadcaster to the all [eventObservers] of this [PeerConnectionProxy].
     *
     * @return [EventObserver] which will broadcast calls to the all [eventObservers].
     */
    internal fun observableEventBroadcaster(): EventObserver {
        return object : EventObserver {
            override fun onAddTrack(
                    track: MediaStreamTrackProxy,
                    transceiver: RtpTransceiverProxy
            ) {
                eventObservers.forEach { it.onAddTrack(track, transceiver) }
            }

            override fun onIceConnectionStateChange(iceConnectionState: IceConnectionState) {
                eventObservers.forEach { it.onIceConnectionStateChange(iceConnectionState) }
            }

            override fun onSignalingStateChange(signalingState: SignalingState) {
                eventObservers.forEach { it.onSignalingStateChange(signalingState) }
            }

            override fun onConnectionStateChange(peerConnectionState: PeerConnectionState) {
                eventObservers.forEach { it.onConnectionStateChange(peerConnectionState) }
            }

            override fun onIceGatheringStateChange(iceGatheringState: IceGatheringState) {
                eventObservers.forEach { it.onIceGatheringStateChange(iceGatheringState) }
            }

            override fun onIceCandidate(candidate: IceCandidate) {
                eventObservers.forEach { it.onIceCandidate(candidate) }
            }
        }
    }

    /**
     * Disposes underlying [PeerConnection], [RtpSenderProxy]s, [RtpReceiverProxy] and
     * notifies all [onDispose] subscribers about it.
     */
    fun dispose() {
        obj.dispose()
        senders = HashMap()
        receivers = HashMap()
        onDisposeSubscribers.forEach { sub -> sub(id) }
    }

    /**
     * Subscribes to the [dispose] event of this [PeerConnectionProxy].
     *
     * @param f callback which will be called on [dispose].
     */
    fun onDispose(f: (Int) -> Unit) {
        onDisposeSubscribers.add(f)
    }

    /**
     * Synchronizes and returns all [RtpSenderProxy]s of this [PeerConnectionProxy].
     *
     * @return all [RtpSenderProxy]s of this [PeerConnectionProxy].
     */
    fun getSenders(): List<RtpSenderProxy> {
        syncSenders()
        return senders.values.toList()
    }

    /**
     * Synchronizes and returns all [RtpTransceiverProxy]s of this [PeerConnectionProxy].
     *
     * @return all [RtpTransceiverProxy]s of this [PeerConnectionProxy].
     */
    fun getTransceivers(): List<RtpTransceiverProxy> {
        syncTransceivers()
        return transceivers.values.toList()
    }

    /**
     * @return local [SessionDescription] of the underlying [PeerConnection].
     */
    fun getLocalDescription(): SessionDescription {
        return SessionDescription.fromWebRtc(obj.localDescription)
    }

    /**
     * @return remote [SessionDescription] of the underlying [PeerConnection].
     */
    fun getRemoteDescription(): SessionDescription? {
        val sdp = obj.remoteDescription
        return if (sdp == null) {
            null
        } else {
            SessionDescription.fromWebRtc(sdp)
        }
    }

    /**
     * Creates new [SessionDescription] offer.
     *
     * @return newly created [SessionDescription].
     */
    suspend fun createOffer(): SessionDescription {
        return suspendCoroutine { continuation ->
            obj.createOffer(createSdpObserver(continuation), MediaConstraints())
        }
    }

    /**
     * Creates new [SessionDescription] answer.
     *
     * @return newly created [SessionDescription].
     */
    suspend fun createAnswer(): SessionDescription {
        return suspendCoroutine { continuation ->
            obj.createAnswer(createSdpObserver(continuation), MediaConstraints())
        }
    }

    /**
     * Sets provided local [SessionDescription] to the underlying [PeerConnection].
     *
     * @param description SDP which will be applied.
     */
    suspend fun setLocalDescription(description: SessionDescription?) {
        suspendCoroutine<Unit> { continuation ->
            if (description == null) {
                obj.setLocalDescription(setSdpObserver(continuation))
            } else {
                obj.setLocalDescription(setSdpObserver(continuation), description.intoWebRtc())
            }
        }
    }

    /**
     * Sets provided remote [SessionDescription] to the underlying [PeerConnection].
     *
     * @param description SDP which will be applied.
     */
    suspend fun setRemoteDescription(description: SessionDescription) {
        suspendCoroutine<Unit> { continuation ->
            obj.setRemoteDescription(setSdpObserver(continuation), description.intoWebRtc())
        }
    }

    /**
     * Adds new [IceCandidate] to the underlying [PeerConnection].
     */
    suspend fun addIceCandidate(candidate: IceCandidate) {
        suspendCoroutine<Unit> { continuation ->
            obj.addIceCandidate(candidate.intoWebRtc(), object : AddIceObserver {
                override fun onAddSuccess() {
                    continuation.resume(Unit)
                }

                override fun onAddFailure(msg: String?) {
                    var message = msg
                    if (message == null) {
                        message = ""
                    }
                    continuation.resumeWithException(AddIceCandidateException(message))
                }
            })
        }
    }

    /**
     * Creates new [RtpTransceiverProxy] based on the provided config.
     *
     * @param mediaType initial [MediaType] of the newly created [RtpTransceiverProxy].
     * @param init configuration of the newly created [RtpTransceiverProxy].
     * @return newly created [RtpTransceiverProxy].
     */
    fun addTransceiver(mediaType: MediaType, init: RtpTransceiverInit?): RtpTransceiverProxy {
        obj.addTransceiver(mediaType.intoWebRtc(), init?.intoWebRtc())
        syncTransceivers()
        return transceivers.lastEntry()!!.value
    }

    /**
     * Requests underlying [PeerConnection] to [IceCandidate] gathering redone.
     */
    fun restartIce() {
        obj.restartIce()
    }

    /**
     * Synchronizes underlying pointers of old [RtpSenderProxy]s and
     * creates [RtpSenderProxy]s for the new [RtpSender]s.
     */
    private fun syncSenders() {
        val newSenders = mutableMapOf<String, RtpSenderProxy>()
        val oldSenders = senders

        val peerSenders = obj.senders
        for (peerSender in peerSenders) {
            val peerSenderId = peerSender.id()

            val oldSender = oldSenders.remove(peerSenderId)
            if (oldSender == null) {
                newSenders[peerSenderId] = RtpSenderProxy(peerSender)
            } else {
                oldSender.updateObject(peerSender)
                newSenders[peerSenderId] = oldSender
            }
        }
    }

    /**
     * Synchronizes underlying pointers of old [RtpReceiverProxy]s and
     * creates [RtpReceiverProxy]s for the new [RtpReceiver]s.
     */
    private fun syncReceivers() {
        val newReceivers = mutableMapOf<String, RtpReceiverProxy>()
        val oldReceivers = receivers

        val peerReceivers = obj.receivers
        for (peerReceiver in peerReceivers) {
            val peerReceiverId = peerReceiver.id()

            val oldReceiver = oldReceivers.remove(peerReceiverId)
            if (oldReceiver == null) {
                newReceivers[peerReceiverId] = RtpReceiverProxy(peerReceiver)
            } else {
                oldReceiver.updateObject(peerReceiver)
                newReceivers[peerReceiverId] = oldReceiver
            }
        }
    }

    /**
     * Synchronizes underlying pointers of old [RtpTransceiverProxy]s and
     * creates [RtpTransceiverProxy]s for the new [RtpTransceiver]s.
     */
    private fun syncTransceivers() {
        val peerTransceivers = obj.transceivers.withIndex()

        for ((id, peerTransceiver) in peerTransceivers) {
            val oldTransceiver = transceivers[id]
            if (oldTransceiver == null) {
                transceivers[id] = RtpTransceiverProxy(peerTransceiver)
            } else {
                oldTransceiver.updateObject(peerTransceiver)
            }
        }
    }
}