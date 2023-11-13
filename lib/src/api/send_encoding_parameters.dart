import '/src/api/bridge.g.dart' as ffi;
import '/src/api/peer.dart';

/// Encoding describing a single configuration of a codec for an RTCRtpSender.
abstract class SendEncodingParameters {
  static SendEncodingParameters create(String rid, bool active,
      {int? maxBitrate,
      double? maxFramerate,
      String? scalabilityMode,
      double? scaleResolutionDownBy}) {
    if (isDesktop) {
      return _SendEncodingParametersFFI(rid, active,
          maxBitrate: maxBitrate,
          scalabilityMode: scalabilityMode,
          maxFramerate: maxFramerate,
          scaleResolutionDownBy: scaleResolutionDownBy);
    } else {
      return _SendEncodingParametersChannel(rid, active,
          maxBitrate: maxBitrate,
          scalabilityMode: scalabilityMode,
          maxFramerate: maxFramerate,
          scaleResolutionDownBy: scaleResolutionDownBy);
    }
  }

  /// Create a new [SendEncodingParameters] from the provided [ffi.RtcRtpEncodingParameters].
  static SendEncodingParameters fromFFI(ffi.RtcRtpEncodingParameters e,
      ffi.ArcRtpEncodingParameters sysEncoding) {
    return _SendEncodingParametersFFI(e.rid, e.active,
        maxBitrate: e.maxBitrate,
        maxFramerate: e.maxFramerate,
        scalabilityMode: e.scalabilityMode,
        scaleResolutionDownBy: e.scaleResolutionDownBy,
        encoding: sysEncoding);
  }

  /// Creates an [SendEncodingParameters] basing on the [Map] received from the native side.
  static SendEncodingParameters fromMap(dynamic e) {
    return _SendEncodingParametersChannel(e['rid'], e['active'],
        maxBitrate: e['maxBitrate'],
        maxFramerate: (e['maxFramerate'] as int?)?.toDouble(),
        scaleResolutionDownBy: e['scaleResolutionDownBy'],
        index: e['index']);
  }

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

  /// Converts this [SendEncodingParameters] to the [Map] expected by Flutter.
  Map<String, dynamic> toMap();

  /// Tries to convert this [SendEncodingParameters] to the [ffi.ArcRtpEncodingParameters].
  (ffi.RtcRtpEncodingParameters, ffi.ArcRtpEncodingParameters?) toFFI();
}

/// [MethodChannel]-based implementation of a [SendEncodingParameters].
class _SendEncodingParametersChannel extends SendEncodingParameters {
  _SendEncodingParametersChannel(String rid, bool active,
      {int? maxBitrate,
      double? maxFramerate,
      double? scaleResolutionDownBy,
      String? scalabilityMode,
      int? index})
      : _index = index {
    this.rid = rid;
    this.active = active;
    this.maxBitrate = maxBitrate;
    this.maxFramerate = maxFramerate;
    this.scaleResolutionDownBy = scaleResolutionDownBy;
    this.scalabilityMode = scalabilityMode;
  }

  final int? _index;

  @override
  Map<String, dynamic> toMap() {
    return {
      'index': _index,
      'rid': rid,
      'active': active,
      'maxBitrate': maxBitrate,
      'maxFramerate': maxFramerate?.toInt(),
      'scaleResolutionDownBy': scaleResolutionDownBy,
      'scalabilityMode': scalabilityMode
    };
  }

  @override
  (ffi.RtcRtpEncodingParameters, ffi.ArcRtpEncodingParameters?) toFFI() {
    throw UnimplementedError();
  }
}

/// FFI-based implementation of a [SendEncodingParameters].
class _SendEncodingParametersFFI extends SendEncodingParameters {
  _SendEncodingParametersFFI(String rid, bool active,
      {int? maxBitrate,
      double? maxFramerate,
      double? scaleResolutionDownBy,
      String? scalabilityMode,
      ffi.ArcRtpEncodingParameters? encoding}) {
    this.rid = rid;
    this.active = active;
    this.maxBitrate = maxBitrate;
    this.maxFramerate = maxFramerate;
    this.scaleResolutionDownBy = scaleResolutionDownBy;
    this.scalabilityMode = scalabilityMode;
    _encoding = encoding;
  }

  /// Underlying [ffi.ArcRtpEncodingParameters].
  ffi.ArcRtpEncodingParameters? _encoding;

  @override
  (ffi.RtcRtpEncodingParameters, ffi.ArcRtpEncodingParameters?) toFFI() {
    return (
      ffi.RtcRtpEncodingParameters(
          rid: rid,
          active: active,
          maxBitrate: maxBitrate,
          maxFramerate: maxFramerate,
          scaleResolutionDownBy: scaleResolutionDownBy,
          scalabilityMode: scalabilityMode),
      _encoding
    );
  }

  @override
  Map<String, dynamic> toMap() {
    throw UnimplementedError();
  }
}
