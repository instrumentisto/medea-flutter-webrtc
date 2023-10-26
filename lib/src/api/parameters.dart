import 'package:medea_flutter_webrtc/src/api/bridge.g.dart';
import 'package:medea_flutter_webrtc/src/model/transceiver.dart';

import 'bridge.g.dart' as ffi;
import 'channel.dart';
import 'peer.dart';

abstract class RtpParameters {
  static fromFFI(ArcRtpParameters params) {
    return _RtpParametersFFI(params);
  }

  static forChannel() {
    return _RtpParametersChannel();
  }

  ffi.ArcRtpParameters? toFFI();

  Future<List<SendEncodingParameters>> encodings();

  Future<void> setEncodings(SendEncodingParameters encoding);
}

class _RtpParametersChannel extends RtpParameters {
  @override
  Future<List<SendEncodingParameters>> encodings() async {
    return List.empty();
  }

  @override
  Future<void> setEncodings(SendEncodingParameters encoding) async {

  }

  @override
  ffi.ArcRtpParameters? toFFI() {
    return null;
  }
} 

class _RtpParametersFFI extends RtpParameters {
  _RtpParametersFFI(this._params);

  final ffi.ArcRtpParameters _params;

  @override
  Future<List<SendEncodingParameters>> encodings() async {
    return (await api!.parametersGetEncodings(params: _params))
        .map((e) => SendEncodingParameters.fromFFI(e))
        .toList();
  }

  @override
  Future<void> setEncodings(SendEncodingParameters encoding) async {
    await api!.parametersSetEncoding(
        params: _params, encoding: (await encoding.toFFI())!);
  }

  @override
  ffi.ArcRtpParameters? toFFI() {
    return _params;
  }
}
