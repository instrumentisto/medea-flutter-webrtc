import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_webrtc/src/api/rtp_transceiver.dart';
import 'package:flutter_webrtc/src/api/utils/channel_name_generator.dart';
import 'package:flutter_webrtc/src/model/ice_candidate.dart';
import 'package:flutter_webrtc/src/model/media_type.dart';
import 'package:flutter_webrtc/src/model/peer_connection_config.dart';
import 'package:flutter_webrtc/src/model/peer_connections_states.dart';
import 'package:flutter_webrtc/src/model/rtp_transceiver_init.dart';
import 'package:flutter_webrtc/src/model/session_description.dart';
import 'package:flutter_webrtc/src/universal/native/media_stream_track.dart';

/// [MethodChannel] used for the messaging with a native side.
const _peerConnectionFactoryMethodChannel =
    MethodChannel('$CHANNEL_TAG/PeerConnectionFactory');

/// Typedef for the `on_track` callback.
typedef OnTrackCallback = void Function(NativeMediaStreamTrack, RtpTransceiver);

/// Typedef for the `on_ice_candidate` callback.
typedef OnIceCandidateCallback = void Function(IceCandidate);

/// Typedef for the `on_ice_connection_state_change` callback.
typedef OnIceConnectionStateChangeCallback = void Function(IceConnectionState);

/// Typedef for the `on_connection_state_change` callback.
typedef OnConnectionStateChangeCallback = void Function(PeerConnectionState);

class PeerConnection {
  /// Creates [PeerConnection] based on the [Map] received from the native side.
  PeerConnection._fromMap(dynamic map) {
    int channelId = map['channelId'];
    _methodChannel =
        MethodChannel(channelNameWithId('PeerConnection', channelId));
    _eventChannel =
        EventChannel(channelNameWithId('PeerConnectionEvent', channelId));
    // TODO(evdokimovs): Maybe we need to listen for errorEvents? But I think we don't
    _eventSubscription =
        _eventChannel.receiveBroadcastStream().listen(eventListener);
  }

  /// Listener for the all [PeerConnection] events received from the native side.
  void eventListener(dynamic event) {
    final dynamic e = event;
    switch (e['event']) {
      case 'onIceCandidate':
        dynamic iceCandidate = e['candidate'];
        _onIceCandidate?.call(IceCandidate.fromMap(iceCandidate));
        break;
      case 'onIceConnectionStateChange':
        var state = IceConnectionState.values[e['state']];
        _iceConnectionState = state;
        _onIceConnectionStateChange?.call(state);
        break;
      case 'onConnectionStateChange':
        var state = PeerConnectionState.values[e['state']];
        _connectionState = state;
        _onConnectionStateChange?.call(state);
        break;
      case 'onAddTrack':
        dynamic track = e['track'];
        dynamic transceiver = e['transceiver'];
        _onTrack?.call(NativeMediaStreamTrack.fromMap(track),
            RtpTransceiver.fromMap(transceiver));
        break;
    }
  }

  /// [MethodChannel] used for the messaging with a native side.
  late MethodChannel _methodChannel;

  /// [EventChannel] from which all [PeerConnection] events will be received.
  late EventChannel _eventChannel;

  /// [_eventChannel] subscription to the [PeerConnection] events.
  late StreamSubscription<dynamic>? _eventSubscription;

  /// `on_ice_connection_state_change` event subcriber.
  OnIceConnectionStateChangeCallback? _onIceConnectionStateChange;

  /// `on_ice_candidate` event subcriber.
  OnIceCandidateCallback? _onIceCandidate;

  /// `on_track` event subcriber.
  OnTrackCallback? _onTrack;

  /// `on_connection_state_change` event subcriber.
  OnConnectionStateChangeCallback? _onConnectionStateChange;

  /// Current [IceConnectionState] of this [PeerConnection].
  ///
  /// This field will be updated automatically based on the events received
  /// from the native side.
  IceConnectionState _iceConnectionState = IceConnectionState.new_;

  /// Current [PeerConnectionState] of this [PeerConnection].
  ///
  /// This field will be updated automatically based on the events received
  /// from the native side.
  PeerConnectionState _connectionState = PeerConnectionState.new_;

  /// All [RtpTransceiver]s owned by this [PeerConnection].
  ///
  /// This list will be automatically updated call of some action which
  /// theoretically can change it.
  ///
  /// This allows us, to make some publc APIs synchonous.
  final List<RtpTransceiver> _transceivers = [];

  /// Creates new [PeerConnection] with a provided [IceTransportType]
  /// and [IceServer]s.
  static Future<PeerConnection> create(
      IceTransportType iceTransportType, List<IceServer> iceServers) async {
    dynamic res =
        await _peerConnectionFactoryMethodChannel.invokeMethod('create', {
      'iceTransportType': iceTransportType.index,
      'iceServers': iceServers.map((s) => s.toMap()).toList(),
    });

    return PeerConnection._fromMap(res);
  }

  /// Subscribes provided callback to the `on_track` events of
  /// this [PeerConnection]
  void onTrack(OnTrackCallback f) {
    _onTrack = f;
  }

  /// Subscribes provided callback to the `on_ice_candidate` events of
  /// this [PeerConnection]
  void onIceCandidate(OnIceCandidateCallback f) {
    _onIceCandidate = f;
  }

  /// Subscribes provided callback to the `on_ice_connection_state_change`
  /// events of this [PeerConnection]
  void onIceConnectionStateChange(OnIceConnectionStateChangeCallback f) {
    _onIceConnectionStateChange = f;
  }

  /// Subscribes provided callback to the `on_connection_state_change`
  /// events of this [PeerConnection]
  void onConnectionStateChange(OnConnectionStateChangeCallback f) {
    _onConnectionStateChange = f;
  }

  /// Synchonizes mids of the [_transceivers] owned by this [PeerConnection].
  Future<void> _syncTransceiversMids() async {
    for (var transceiver in _transceivers) {
      await transceiver.syncMid();
    }
  }

  /// Adds new [RtpTransceiver] to this [PeerConnection].
  Future<RtpTransceiver> addTransceiver(
      MediaType mediaType, RtpTransceiverInit init) async {
    dynamic res = await _methodChannel.invokeMethod(
        'addTransceiver', {'mediaType': mediaType.index, 'init': init.toMap()});
    var transceiver = RtpTransceiver.fromMap(res);
    _transceivers.add(transceiver);

    return transceiver;
  }

  /// Returns all [RtpTransceiver]s owned by this [PeerConnection].
  Future<List<RtpTransceiver>> getTransceivers() async {
    List<dynamic> res = await _methodChannel.invokeMethod('getTransceivers');
    var transceivers = res.map((t) => RtpTransceiver.fromMap(t)).toList();
    _transceivers.addAll(transceivers);

    return transceivers;
  }

  /// Sets provided remote [SessionDescription] to the [PeerConnection].
  Future<void> setRemoteDescription(SessionDescription description) async {
    await _methodChannel.invokeMethod(
        'setRemoteDescription', {'description': description.toMap()});
    await _syncTransceiversMids();
  }

  /// Sets provided local [SessionDescription] to the [PeerConnection].
  Future<void> setLocalDescription(SessionDescription description) async {
    await _methodChannel.invokeMethod(
        'setLocalDescription', {'description': description.toMap()});
    await _syncTransceiversMids();
  }

  /// Creates new [SessionDescription] offer.
  Future<SessionDescription> createOffer() async {
    dynamic res = await _methodChannel.invokeMethod('createOffer');
    return SessionDescription.fromMap(res);
  }

  /// Creates new [SessionDescription] answer.
  Future<SessionDescription> createAnswer() async {
    dynamic res = await _methodChannel.invokeMethod('createAnswer');
    return SessionDescription.fromMap(res);
  }

  /// Adds new [IceCandidate] to the [PeerConnection].
  Future<void> addIceCandidate(IceCandidate candidate) async {
    await _methodChannel
        .invokeMethod('addIceCandidate', {'candidate': candidate.toMap()});
  }

  /// Requests [PeerConnection] to [IceCandidate] gathering redone.
  Future<void> restartIce() async {
    await _methodChannel.invokeMethod('restartIce');
  }

  /// Returns current [PeerConnectionState] of this [PeerConnection].
  PeerConnectionState connectionState() {
    return _connectionState;
  }

  /// Returns current [IceConnectionState] of this [PeerConnection].
  IceConnectionState iceConnectionState() {
    return _iceConnectionState;
  }

  /// Closes this [PeerConnection] and all it's owned entitied (for example
  /// [RtpTransceiver]).
  Future<void> close() async {
    _transceivers.forEach((e) => e.stoppedByPeer());
    await _eventSubscription?.cancel();
    await _methodChannel.invokeMethod('dispose');
  }
}
