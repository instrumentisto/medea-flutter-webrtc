import AVFoundation

///  Direction in which the camera produces the video.
///
///  [Int] value is representation of this enum which will be expected on the Flutter side.
enum FacingMode: Int {
  /**
    Indicates that the video source is facing toward the user (this includes, for example, the
    front-facing camera on a smartphone).
  */
  case user = 2

  /**
    Indicates that the video source is facing away from the user, thereby viewing their
    environment. This is the back camera on a smartphone.
  */
  case environment = 1

  /**
    Checks that provided position fits into this `FacingMode`.

    - Returns: `true` if provided position fits into this `FacingMode`.
  */
  func isFits(position: AVCaptureDevice.Position) -> Bool {
    return self.rawValue == position.rawValue
  }
}

///  Score of [VideoConstraints].
///
///  This score will be determined by a `ConstraintChecker` and basing on it, more suitable video
///  device will be selected by `getUserMedia` request.
enum ConstraintScore {
  /**
    Indicates that the constraint is not suitable at all.

    So, the device with this score wouldn't used event if there is no other devices.
  */
  case no

  /// Indicates that the constraint can be used, but more suitable devices can be found.
  case maybe

  /// Indicates that the constraint suits ideally.
  case yes

  /**
    Calculates the total score based on which media devices will be sorted.

    - Parameters:
      - scores: List of `ConstraintScore`s of some device.

    - Returns: Total score calculated based on the provided list.
  */
  static func totalScore(scores: [ConstraintScore]) -> Int? {
    var total = 1
    for score in scores {
      switch score {
      case .no:
        return nil
      case .yes:
        total += 1
        return total
      case .maybe:
        ()
      }
    }

    return total
  }
}

/// Interface for all the video constraints which can check suitability of some device.
class ConstraintChecker {
  /// Indicates that this constraint is mandatory or not.
  var isMandatory: Bool = false

  /**
    Calculates a `ConstraintScore` of the device based on the underlying algorithm of the concrete
    constraint.

    - Parameters:
      - device: Actual device for scoring.

    - Returns: `ConstraintScore` based on the underlying scoring algorithm.
  */
  func score(device: AVCaptureDevice) throws -> ConstraintScore {
    let fits = try self.isFits(device: device)
    if fits {
      return ConstraintScore.yes
    } else if self.isMandatory && !fits {
      return ConstraintScore.no
    } else {
      return ConstraintScore.maybe
    }
  }

  /**
    Calculates suitability to the provided device.

    - Parameters:
      - device: Actual device for scoring.

    - Returns: `true` if device is suitable, or `false` otherwise.
   */
  func isFits(device: AVCaptureDevice) throws -> Bool {
    fatalError("isFits is not implemented")
  }
}

/// Constraint searching for a device with some concrete `deviceId`.
class DeviceIdConstraint: ConstraintChecker {
  /// Concrete `deviceId` to be searched.
  var id: String

  /**
    Creates Constraint searcher for a device with some concrete `deviceId`.

    - Parameters:
      - id: Concrete `deviceId` to be searched.
      - isMandatory: Indicates that this constraint is mandatory.
  */
  init(id: String, isMandatory: Bool) {
    self.id = id
    super.init()
    super.isMandatory = isMandatory
  }

  /**
    Calculates suitability to the provided device.

    - Parameters:
      - device: Actual device for scoring.

    - Returns: `true` if device is suitable, or `false` otherwise.
   */
  override func isFits(device: AVCaptureDevice) throws -> Bool {
    return device.uniqueID == self.id
  }
}

/// Constraint searching for a device with some [FacingMode].
class FacingModeConstraint: ConstraintChecker {
  /// Indicates that this constraint is mandatory.
  var facingMode: FacingMode

  /**
    Creates Constraint searcher for a device with some `FacingMode`.

    - Parameters:
      - facingMode: [FacingMode] which will be searched.
      - isMandatory: Indicates that this constraint is mandatory.
  */
  init(facingMode: FacingMode, isMandatory: Bool) {
    self.facingMode = facingMode
    super.init()
    super.isMandatory = isMandatory
  }

  /**
    Calculates suitability to the provided device.

    - Parameters:
      - device: Actual device for scoring.

    - Returns: `true` if device is suitable, or `false` otherwise.
   */
  override func isFits(device: AVCaptureDevice) throws -> Bool {
    return self.facingMode.isFits(position: device.position)
  }
}

/// List of constraints for video devices.
class VideoConstraints {
  /// List of the `DeviceIdConstraint`s provided by user.
  var deviceIdConstraints: [DeviceIdConstraint] = []

  /// List of the `FacingModeConstraint`s provided by user.
  var facingModeConstraints: [FacingModeConstraint] = []

  /// Width of the device video.
  var width: Int?

  /// Height of the device video.
  var height: Int?

  /// FPS of the device video.
  var fps: Int?

  /**
    Creates new `VideoConstraints` object based on the method call received from the Flutter
    side.
  */
  init(map: [String: Any]) {
    let mandatoryArgs = map["mandatory"] as? [String: Any]
    for (key, value) in mandatoryArgs! {
      switch key {
      case "deviceId":
        deviceIdConstraints.append(DeviceIdConstraint(id: value as! String, isMandatory: true))
      case "facingMode":
        facingModeConstraints.append(
          FacingModeConstraint(facingMode: FacingMode(rawValue: value as! Int)!, isMandatory: true))
      case "width":
        width = value as! Int
      case "height":
        height = value as! Int
      case "fps":
        fps = value as! Int
      default:
        ()
      }
    }

    let optionalArgs = map["optional"] as? [String: Any]
    for (key, value) in mandatoryArgs! {
      switch key {
      case "deviceId":
        deviceIdConstraints.append(DeviceIdConstraint(id: value as! String, isMandatory: false))
      case "facingMode":
        facingModeConstraints.append(
          FacingModeConstraint(facingMode: FacingMode(rawValue: value as! Int)!, isMandatory: false)
        )
      case "width":
        width = value as! Int
      case "height":
        height = value as! Int
      case "fps":
        fps = value as! Int
      default:
        ()
      }
    }
  }

  /**
    Calculates a score for the device with the provided ID.

    - Parameters:
      - device: Actual device for scoring.

    - Returns: Total Score calculated based on the provided list.
  */
  func calculateScoreForDevice(device: AVCaptureDevice) -> Int? {
    var scores: [ConstraintScore] = []
    for c in self.facingModeConstraints {
      scores.append(try! c.score(device: device))
    }
    for c in self.deviceIdConstraints {
      scores.append(try! c.score(device: device))
    }

    return ConstraintScore.totalScore(scores: scores)
  }
}

/// List of constraints for audio devices.
class AudioConstraints {

}

/// Audio and video constraints data.
class Constraints {
  /// Optional constraints to lookup video devices with.
  var video: VideoConstraints?

  /// Optional constraints to lookup audio devices with.
  var audio: AudioConstraints?

  /// Creates new `Constraints` object based on the method call received from the Flutter side.
  init(map: [String: Any]) {
    let videoArg = map["video"] as? [String: Any]
    if videoArg != nil {
      self.video = VideoConstraints(map: videoArg!)
    }
    let audioArg = map["audio"] as? [String: Any]
    if audioArg != nil {
      self.audio = AudioConstraints()
    }
  }
}
