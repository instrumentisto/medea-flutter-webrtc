export '/src/api/ffi/devices.dart'
    if (dart.library.html) '/src/api/channel/devices.dart';

/// Shortcut for the `on_device_change` callback.
typedef OnDeviceChangeCallback = void Function();
