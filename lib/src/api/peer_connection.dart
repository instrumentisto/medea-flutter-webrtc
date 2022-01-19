import 'package:flutter/services.dart';
import 'package:flutter_webrtc/src/api/media_stream_track.dart';
import 'package:flutter_webrtc/src/api/rtp_transceiver.dart';
import 'package:flutter_webrtc/src/api/utils/channel_name_generator.dart';
import 'package:flutter_webrtc/src/model/ice_candidate.dart';
import 'package:flutter_webrtc/src/model/media_type.dart';
import 'package:flutter_webrtc/src/model/peer_connection_config.dart';
import 'package:flutter_webrtc/src/model/peer_connections_states.dart';
import 'package:flutter_webrtc/src/model/rtp_transceiver_init.dart';
import 'package:flutter_webrtc/src/model/session_description.dart';

const _peerConnectionFactoryMethodChannel =
    MethodChannel('$CHANNEL_TAG/PeerConnectionFactory');

typedef OnTrackCallback = void Function(MediaStreamTrack, RtpTransceiver);
typedef OnIceCandidateCallback = void Function(IceCandidate);
typedef OnIceConnectionStateChangeCallback = void Function(IceConnectionState);
typedef OnConnectionStateChangeCallback = void Function(PeerConnectionState);

class PeerConnection {
  PeerConnection._fromMap(Map<String, dynamic> map) {
    int channelId = map['channelId'];
    _methodChannel =
        MethodChannel(channelNameWithId('PeerConnection', channelId));
    _eventChannel =
        EventChannel(channelNameWithId('PeerConnectionEvent', channelId));
    // TODO(evdokimovs): Maybe we need to listen for errorEvents? But I think we don't
    _eventChannel.receiveBroadcastStream().listen(eventListener);
  }

  void eventListener(dynamic event) {
    final Map<String, dynamic> e = event;
    switch (e['event']) {
      case 'onIceCandidate':
        Map<String, dynamic> iceCandidate = e['candidate'];
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
        Map<String, dynamic> track = e['track'];
        Map<String, dynamic> transceiver = e['transceiver'];
        _onTrack?.call(MediaStreamTrack.fromMap(track),
            RtpTransceiver.fromMap(transceiver));
        break;
    }
  }

  late MethodChannel _methodChannel;
  late EventChannel _eventChannel;

  OnIceConnectionStateChangeCallback? _onIceConnectionStateChange;
  OnIceCandidateCallback? _onIceCandidate;
  OnTrackCallback? _onTrack;
  OnConnectionStateChangeCallback? _onConnectionStateChange;

  IceConnectionState _iceConnectionState = IceConnectionState.new_;
  PeerConnectionState _connectionState = PeerConnectionState.new_;

  static Future<PeerConnection> create(
      IceTransportType iceTransportType, List<IceServer> iceServers) async {
    Map<String, dynamic> res =
        await _peerConnectionFactoryMethodChannel.invokeMethod('create', {
      'iceTransportType': iceTransportType.index,
      'iceServers': iceServers.map((s) => s.toMap()).toList(),
    });

    return PeerConnection._fromMap(res);
  }

  void onTrack(OnTrackCallback f) {
    _onTrack = f;
  }

  void onIceCandidate(OnIceCandidateCallback f) {
    _onIceCandidate = f;
  }

  void onIceConnectionStateChange(OnIceConnectionStateChangeCallback f) {
    _onIceConnectionStateChange = f;
  }

  void onConnectionStateChange(OnConnectionStateChangeCallback f) {
    _onConnectionStateChange = f;
  }

  Future<RtpTransceiver> addTransceiver(
      MediaType mediaType, RtpTransceiverInit init) async {
    Map<String, dynamic> res = await _methodChannel.invokeMethod(
        'addTransceiver', {'mediaType': mediaType.index, 'init': init.toMap()});

    return RtpTransceiver.fromMap(res);
  }

  Future<List<RtpTransceiver>> getTransceivers() async {
    List<Map<String, dynamic>> transceivers =
        await _methodChannel.invokeMethod('getTransceivers');
    return transceivers.map((t) => RtpTransceiver.fromMap(t)).toList();
  }

  Future<void> setRemoteDescription(SessionDescription description) async {
    await _methodChannel.invokeMethod(
        'setRemoteDescription', {'description': description.toMap()});
  }

  Future<void> setLocalDescription(SessionDescription description) async {
    await _methodChannel.invokeMethod(
        'setLocalDescription', {'description': description.toMap()});
  }

  Future<SessionDescription> createOffer() async {
    Map<String, dynamic> res = await _methodChannel.invokeMethod('createOffer');
    return SessionDescription.fromMap(res);
  }

  Future<SessionDescription> createAnswer() async {
    Map<String, dynamic> res =
        await _methodChannel.invokeMethod('createAnswer');
    return SessionDescription.fromMap(res);
  }

  Future<void> addIceCandidate(IceCandidate candidate) async {
    await _methodChannel
        .invokeMethod('addIceCandidate', {'candidate': candidate.toMap()});
  }

  PeerConnectionState connectionState() {
    return _connectionState;
  }

  IceConnectionState iceConnectionState() {
    return _iceConnectionState;
  }

  Future<void> close() async {
    await _methodChannel.invokeMethod('close');
  }
}
