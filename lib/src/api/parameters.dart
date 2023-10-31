import 'package:flutter/services.dart';

import 'package:medea_flutter_webrtc/src/api/bridge.g.dart';
import 'bridge.g.dart' as ffi;
import 'peer.dart';
import 'send_encoding_parameters.dart';

/// [RtpParameters][1] implementation.
///
/// [1]: https://w3.org/TR/webrtc/#dom-rtcrtpparameters
abstract class RtpParameters {
  /// Create a new [RtpParameters] from the provided [ArcRtpParameters].
  static fromFFI(ArcRtpParameters params) {
    return _RtpParametersFFI(params);
  }

  /// Create a new [RtpParameters] from the provided [MethodChannel].
  static fromChannel(MethodChannel chan) {
    return _RtpParametersChannel(chan);
  }

  /// Tries to convert this [RtpParameters] into [ffi.ArcRtpParameters].
  ffi.ArcRtpParameters? toFFI() {
    return null;
  }

  /// Converts this [RtpParameters] to the [Map] expected by Flutter.
  Map<String, dynamic> toMap() {
    return {};
  }

  /// Returns [SendEncodingParameters] of this [RtpParameters].
  Future<List<SendEncodingParameters>> encodings();

  /// Sets the provided [SendEncodingParameters] for this [RtpParameters].
  Future<void> setEncodings(SendEncodingParameters encoding);
}

/// [MethodChannel]-based implementation of a [RtpParameters].
class _RtpParametersChannel extends RtpParameters {
  _RtpParametersChannel(this._chan);

  /// Underlying [MethodChannel].
  final MethodChannel _chan;

  /// The [SendEncodingParameters] which has been set.
  final List<SendEncodingParameters> _setEncodings = List.empty(growable: true);

  @override
  Future<List<SendEncodingParameters>> encodings() async {
    List<dynamic>? res = await _chan.invokeMethod('encodings');

    return res!.map((e) => SendEncodingParameters.fromMap(e)).toList();
  }

  @override
  Future<void> setEncodings(SendEncodingParameters encoding) async {
    _setEncodings.add(encoding);
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'encodings': _setEncodings.map((e) => e.toMap()).toList(),
    };
  }
}

/// FFI-based implementation of a [RtpParameters].
class _RtpParametersFFI extends RtpParameters {
  _RtpParametersFFI(this._params);

  /// Underlying [ffi.ArcRtpParameters].
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
