/// Type of the [SessionDescription].
enum SessionDescriptionType {
  /// Indicates that description is the initial proposal in an
  /// offer/answer exchange.
  offer,

  /// Indicates that the description is a provisional answer and may be
  /// changed when the definitive choice will be given.
  pranswer,

  /// Indicates that description is the definitive choice in an
  /// offer/answer exchange.
  answer,

  /// Indicates that description rolls back to offer/answer state to the
  /// last stable state.
  rollback,
}

/// SDP offer which can be set to `PeerConnection`.
class SessionDescription {
  /// Constructs new [SessionDescription] with a provided type and SDP.
  SessionDescription(this.type, this.description);

  /// Creates [SessionDescription] based on the [Map] received from
  /// the native side.
  SessionDescription.fromMap(dynamic map) {
    type = SessionDescriptionType.values[map['type']];
    description = map['description'];
  }

  /// Type of this [SessionDescription].
  late SessionDescriptionType type;

  /// SDP of this [SessionDescription].
  late String description;

  /// Converts this model to the [Map] expected by Flutter.
  dynamic toMap() { // TODO(#31): Map<String, dynamic>?
    return {
      'type': type.index,
      'description': description,
    };
  }
}
