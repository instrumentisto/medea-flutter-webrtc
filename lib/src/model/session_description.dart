enum SessionDescriptionType {
  offer,
  pranswer,
  answer,
  rollback,
}

class SessionDescription {
  SessionDescription.fromMap(dynamic map) {
    type = SessionDescriptionType.values[map['type']];
    description = map['description'];
  }

  SessionDescription(this.type, this.description);

  late SessionDescriptionType type;
  late String description;

  dynamic toMap() {
    return {
      'type': type.index,
      'description': description,
    };
  }
}
