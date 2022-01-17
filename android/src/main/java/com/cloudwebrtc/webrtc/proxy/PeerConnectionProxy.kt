package com.cloudwebrtc.webrtc.proxy

import com.cloudwebrtc.webrtc.exception.AddIceCandidateException
import com.cloudwebrtc.webrtc.exception.CreateSdpException
import com.cloudwebrtc.webrtc.exception.SetSdpException
import com.cloudwebrtc.webrtc.model.IceCandidate
import com.cloudwebrtc.webrtc.model.MediaType
import com.cloudwebrtc.webrtc.model.RtpTransceiverInit
import com.cloudwebrtc.webrtc.model.SessionDescription
import org.webrtc.AddIceObserver
import org.webrtc.MediaConstraints
import org.webrtc.PeerConnection
import org.webrtc.SdpObserver
import kotlin.coroutines.Continuation
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine
import org.webrtc.SessionDescription as WSessionDescription

class PeerConnectionProxy(val id: Int, peer: PeerConnection) : IWebRTCProxy<PeerConnection> {
    override var obj: PeerConnection = peer
    private var senders: HashMap<String, RtpSenderProxy> = HashMap()
    private var receivers: HashMap<String, RtpReceiverProxy> = HashMap()
    private var transceivers: HashMap<Int, RtpTransceiverProxy> = HashMap()
    private var onDisposeSubscribers: MutableList<(Int) -> Unit> = mutableListOf()

    init {
        syncWithObject();
    }

    companion object {
        private fun createSdpObserver(continuation: Continuation<SessionDescription>): SdpObserver {
            return object : SdpObserver {
                override fun onCreateSuccess(sdp: WSessionDescription) {
                    continuation.resume(SessionDescription.fromWebRtc(sdp))
                }

                override fun onSetSuccess() {
                    throw RuntimeException("onSetSuccess function can't be called when creating offer")
                }

                override fun onCreateFailure(msg: String?) {
                    var message = msg;
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

        private fun setSdpObserver(continuation: Continuation<Unit>): SdpObserver {
            return object : SdpObserver {
                override fun onCreateSuccess(sdp: org.webrtc.SessionDescription?) {
                    throw RuntimeException("onCreateSuccess function can't be called when settings offer")
                }

                override fun onSetSuccess() {
                    continuation.resume(Unit);
                }

                override fun onCreateFailure(msg: String?) {
                    throw RuntimeException("onCreateFailure function can't be called when settings offer")
                }

                override fun onSetFailure(msg: String?) {
                    var message = msg;
                    if (message == null) {
                        message = ""
                    }
                    continuation.resumeWithException(SetSdpException(message))
                }
            }
        }
    }

    override fun syncWithObject() {
        syncSenders();
        syncReceivers();
        syncTransceivers();
    }

    fun dispose() {
        obj.dispose();
        senders = HashMap();
        receivers = HashMap();
        onDisposeSubscribers.forEach { sub -> sub(id) }
    }

    fun onDispose(f: (Int) -> Unit) {
        onDisposeSubscribers.add(f);
    }

    fun getSenders(): List<RtpSenderProxy> {
        syncSenders();
        return senders.values.toList();
    }

    fun getReceivers(): List<RtpReceiverProxy> {
        syncReceivers();
        return receivers.values.toList();
    }

    fun getTransceivers(): List<RtpTransceiverProxy> {
        syncTransceivers();
        return transceivers.values.toList();
    }

    fun getLocalDescription(): SessionDescription {
        return SessionDescription.fromWebRtc(obj.localDescription);
    }

    fun getRemoteDescription(): SessionDescription? {
        val sdp = obj.remoteDescription;
        return if (sdp == null) {
            null
        } else {
            SessionDescription.fromWebRtc(sdp)
        }
    }

    suspend fun createOffer(): SessionDescription {
        return suspendCoroutine { continuation ->
            obj.createOffer(createSdpObserver(continuation), MediaConstraints())
        }
    }

    suspend fun createAnswer(): SessionDescription {
        return suspendCoroutine { continuation ->
            obj.createAnswer(createSdpObserver(continuation), MediaConstraints())
        }
    }

    suspend fun setLocalDescription(description: SessionDescription?) {
        suspendCoroutine<Unit> { continuation ->
            if (description == null) {
                obj.setLocalDescription(setSdpObserver(continuation))
            } else {
                obj.setLocalDescription(setSdpObserver(continuation), description.intoWebRtc())
            }
        }
    }

    suspend fun setRemoteDescription(description: SessionDescription) {
        suspendCoroutine<Unit> { continuation ->
            obj.setRemoteDescription(setSdpObserver(continuation), description.intoWebRtc())
        }
    }

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

    fun addTransceiver(mediaType: MediaType, init: RtpTransceiverInit?): RtpTransceiverProxy {
        return RtpTransceiverProxy(obj.addTransceiver(mediaType.intoWebRtc(), init?.intoWebRtc()))
    }

    fun addTransceiver(mediaType: MediaType): RtpTransceiverProxy {
        return RtpTransceiverProxy(obj.addTransceiver(mediaType.intoWebRtc()))
    }

    private fun syncSenders() {
        val newSenders = mutableMapOf<String, RtpSenderProxy>();
        val oldSenders = senders;

        val peerSenders = obj.senders;
        for (peerSender in peerSenders) {
            val peerSenderId = peerSender.id();

            val oldSender = oldSenders.remove(peerSenderId);
            if (oldSender == null) {
                newSenders[peerSenderId] = RtpSenderProxy(peerSender);
            } else {
                oldSender.updateObject(peerSender);
                newSenders[peerSenderId] = oldSender;
            }
        }

        // TODO(evdokimovs): Maybe we should do something with them?
//        val removedSenders = oldSenders.values;
    }

    private fun syncReceivers() {
        val newReceivers = mutableMapOf<String, RtpReceiverProxy>();
        val oldReceivers = receivers;

        val peerReceivers = obj.receivers;
        for (peerReceiver in peerReceivers) {
            val peerReceiverId = peerReceiver.id();

            val oldReceiver = oldReceivers.remove(peerReceiverId);
            if (oldReceiver == null) {
                newReceivers[peerReceiverId] = RtpReceiverProxy(peerReceiver);
            } else {
                oldReceiver.updateObject(peerReceiver);
                newReceivers[peerReceiverId] = oldReceiver;
            }
        }

        // TODO(evdokimovs): Maybe we should do something with them?
//        val removedReceivers = oldReceivers.values;
    }

    private fun syncTransceivers() {
        val peerTransceivers = obj.transceivers.withIndex();

        for ((id, peerTransceiver) in peerTransceivers) {
            val oldTransceiver = transceivers[id];
            if (oldTransceiver == null) {
                transceivers[id] = RtpTransceiverProxy(peerTransceiver);
            } else {
                oldTransceiver.updateObject(peerTransceiver);
            }
        }
    }
}