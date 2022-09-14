import 'package:flutter/services.dart';

import '/src/model/transceiver.dart';
import '/src/model/stats.dart';
import 'bridge.g.dart' as ffi;
import 'channel.dart';
import 'peer.dart';
import 'sender.dart';

abstract class RTCStats {
  static RTCStats fromMap(dynamic map) {
    return _RTCStatsChannel.fromMap(map);
  }

  static RTCStats fromFFI(ffi.RTCStats stats) {
    return _RTCStatsFFI(stats);
  }

  late String id;
  late int timestampUs;
  late RTCStatsType? type;
}

class _RTCStatsChannel extends RTCStats {
  _RTCStatsChannel.fromMap(dynamic map) {
    // todo
  }
}

/// FFI-based implementation of an [RTCStats].
class _RTCStatsFFI extends RTCStats {
  _RTCStatsFFI(ffi.RTCStats stats) {
    id = stats.id;
    timestampUs = stats.timestampUs;
    type = RTCStatsType.ffiFactory(stats.kind);
  }
}
