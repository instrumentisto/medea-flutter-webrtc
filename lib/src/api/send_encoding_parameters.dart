import '/src/api/bridge.g.dart' as ffi;
import '/src/api/peer.dart';

/// Encoding describing a single configuration of a codec for an RTCRtpSender.
class SendEncodingParameters {
  SendEncodingParameters(this.rid, this.active,
      {this.maxBitrate,
      this.maxFramerate,
      this.scalabilityMode,
      this.scaleResolutionDownBy});

  /// String which, if set, specifies an RTP stream ID (RID) to be sent using
  /// the RID header extension.
  late String rid;

  /// If true, the described encoding is currently actively being used.
  late bool active;

  /// Indicator of the maximum number of bits per second to allow for this
  /// encoding.
  int? maxBitrate;

  /// Value specifying the maximum number of frames per second to allow for
  /// this encoding.
  double? maxFramerate;

  /// Double-precision floating-point value specifying a factor by which to
  /// scale down the video during encoding.
  double? scaleResolutionDownBy;

  /// Scalability mode describes layers within the media stream.
  String? scalabilityMode;

  /// Create a new [SendEncodingParameters] from the provided [ffi.RtcRtpEncodingParameters].
  static SendEncodingParameters fromFFI(ffi.RtcRtpEncodingParameters e) {
    return _SendEncodingParametersFFI(e.parameters, e.rid, e.active,
        maxBitrate: e.maxBitrate,
        maxFramerate: e.maxFramerate,
        scalabilityMode: e.scalabilityMode,
        scaleResolutionDownBy: e.scaleResolutionDownBy);
  }

  /// Creates an [SendEncodingParameters] basing on the [Map] received from the native side.
  static SendEncodingParameters fromMap(dynamic e) {
    return _SendEncodingParametersChannel(e['index'], e['rid'], e['active'],
        maxBitrate: e['maxBitrate'],
        maxFramerate: (e['maxFramrate'] as int?)?.toDouble(),
        scaleResolutionDownBy: e['scaleResolutionDownBy']);
  }

  /// Converts this [SendEncodingParameters] to the [Map] expected by Flutter.
  Map<String, dynamic> toMap() {
    return {
      'rid': rid,
      'active': active,
      'maxBitrate': maxBitrate,
      'maxFramerate': maxFramerate?.toInt(),
      'scaleResolutionDownBy': scaleResolutionDownBy,
      'scalabilityMode': scalabilityMode
    };
  }

  /// Tries to convert this [SendEncodingParameters] to the [ffi.ArcRtpEncodingParameters].
  Future<ffi.ArcRtpEncodingParameters?> toFFI() async {
    return null; // no-op
  }
}

/// [MethodChannel]-based implementation of a [SendEncodingParameters].
class _SendEncodingParametersChannel extends SendEncodingParameters {
  _SendEncodingParametersChannel(this._index, String rid, bool active,
      {int? maxBitrate,
      double? maxFramerate,
      String? scalabilityMode,
      double? scaleResolutionDownBy})
      : super(rid, active,
            maxBitrate: maxBitrate,
            maxFramerate: maxFramerate,
            scalabilityMode: scalabilityMode,
            scaleResolutionDownBy: scaleResolutionDownBy);

  final int _index;

  @override
  Map<String, dynamic> toMap() {
    var res = super.toMap();
    res['index'] = _index;

    return res;
  }
}

/// FFI-based implementation of a [SendEncodingParameters].
class _SendEncodingParametersFFI extends SendEncodingParameters {
  _SendEncodingParametersFFI(this._encoding, String rid, bool active,
      {int? maxBitrate,
      double? maxFramerate,
      String? scalabilityMode,
      double? scaleResolutionDownBy})
      : super(rid, active,
            maxBitrate: maxBitrate,
            maxFramerate: maxFramerate,
            scalabilityMode: scalabilityMode,
            scaleResolutionDownBy: scaleResolutionDownBy);

  /// Underlying [ffi.ArcRtpEncodingParameters].
  final ffi.ArcRtpEncodingParameters _encoding;

  @override
  Future<ffi.ArcRtpEncodingParameters?> toFFI() async {
    await api!.updateEncodingParameters(
        encoding: _encoding,
        active: super.active,
        maxBitrate: super.maxBitrate,
        maxFramerate: super.maxFramerate,
        scalabilityMode: super.scalabilityMode,
        scaleResolutionDownBy: super.scaleResolutionDownBy);

    return _encoding;
  }
}
