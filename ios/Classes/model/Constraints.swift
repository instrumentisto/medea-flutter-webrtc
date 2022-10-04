import AVFoundation

enum FacingMode: Int {
  case user, environment

  func isFits(position: AVCaptureDevice.Position) -> Bool {
    return self.rawValue == position.rawValue
  }
}

enum ConstraintScore {
  case no, maybe, yes

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

class ConstraintChecker {
  var isMandatory: Bool = false

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

  func isFits(device: AVCaptureDevice) throws -> Bool {
    fatalError("isFits is not implemented")
  }
}

class DeviceIdConstraint: ConstraintChecker {
  var id: String

  init(id: String, isMandatory: Bool) {
    self.id = id
    super.init()
    super.isMandatory = isMandatory
  }

  override func isFits(device: AVCaptureDevice) throws -> Bool {
    return device.uniqueID == self.id
  }
}

class FacingModeConstraint: ConstraintChecker {
  var facingMode: FacingMode

  init(facingMode: FacingMode, isMandatory: Bool) {
    self.facingMode = facingMode
    super.init()
    super.isMandatory = isMandatory
  }

  override func isFits(device: AVCaptureDevice) throws -> Bool {
    return self.facingMode.isFits(position: device.position)
  }
}

class VideoConstraints {
  var deviceIdConstraints: [DeviceIdConstraint] = []
  var facingModeConstraints: [FacingModeConstraint] = []
  var width: Int?
  var height: Int?
  var fps: Int?

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

  func calculateScoreForDevice(device: AVCaptureDevice) -> Int? {
    var scores: [ConstraintScore] = []
    for c in self.facingModeConstraints {
      scores.append(try! c.score(device: device))
    }

    return ConstraintScore.totalScore(scores: scores)
  }
}

class Constraints {
  var video: VideoConstraints?

  init(map: [String: Any]) {
    let videoArg = map["video"] as? [String: Any]
    if videoArg != nil {
      self.video = VideoConstraints(map: videoArg!)
    }
  }
}
