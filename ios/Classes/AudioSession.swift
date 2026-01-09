import AVFoundation

/// Small wrapper around `AVAudioSession` that can disable all automatic session
/// management (category/activation/etc.) while still allowing device
/// enumeration and explicit device switching.
final class AudioSession {
  private let session: AVAudioSession

  /// Whether automatic `AVAudioSession` management is enabled.
  ///
  /// If `false`, this wrapper will not call any "management" APIs like
  /// `setCategory` / `setActive`.
  var autoManagementEnabled: Bool = true

  /// Creates a new `AVAudioSession`.
  init(session: AVAudioSession = AVAudioSession.sharedInstance()) {
    self.session = session
  }

  /// Returns the inputs that are currently available for routing.
  var availableInputs: [AVAudioSessionPortDescription]? {
    return self.session.availableInputs
  }

  /// Selects the preferred input device.
  func setPreferredInput(_ input: AVAudioSessionPortDescription) throws {
    try self.session.setPreferredInput(input)
  }

  /// Overrides the output audio port (e.g. speaker vs default route).
  func overrideOutputAudioPort(_ portOverride: AVAudioSession
    .PortOverride) throws
  {
    try self.session.overrideOutputAudioPort(portOverride)
  }

  /// Sets the audio session category with the provided options.
  ///
  /// Mirrors `AVAudioSession.setCategory(_:options:)`. If
  /// `autoManagementEnabled` is false, this is a no-op.
  func setCategory(
    _ category: AVAudioSession.Category,
    options: AVAudioSession.CategoryOptions = []
  ) throws {
    guard self.autoManagementEnabled else { return }

    try self.session.setCategory(category, options: options)
  }

  /// Sets the audio session category, mode, and options.
  ///
  /// Mirrors `AVAudioSession.setCategory(_:mode:options:)`. If
  /// `autoManagementEnabled` is false, this is a no-op.
  func setCategory(
    _ category: AVAudioSession.Category,
    mode: AVAudioSession.Mode,
    options: AVAudioSession.CategoryOptions = []
  ) throws {
    guard self.autoManagementEnabled else { return }

    try self.session.setCategory(category, mode: mode, options: options)
  }

  /// Activates or deactivates the audio session.
  ///
  /// Mirrors `AVAudioSession.setActive(_:)` and
  /// `AVAudioSession.setActive(_:options:)`. If `autoManagementEnabled` is
  /// false, this is a no-op.
  func setActive(
    _ active: Bool,
    notifyOthersOnDeactivation: Bool = false
  ) throws {
    guard self.autoManagementEnabled else { return }

    if active {
      try self.session.setActive(true)
    } else if notifyOthersOnDeactivation {
      try self.session.setActive(false, options: .notifyOthersOnDeactivation)
    } else {
      try self.session.setActive(false)
    }
  }
}
