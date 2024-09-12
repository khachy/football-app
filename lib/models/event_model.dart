class Events {
  final int id;
  final int fixtureId;
  final int participantId;
  final String playerName;
  final String? relatedPlayerName;
  final bool? isInjured;
  final int minute;
  final String? result;
  final int? extraTime;
  final String? info;
  final String? addition;
  final Type type;

  Events({
    required this.id,
    required this.fixtureId,
    required this.participantId,
    required this.playerName,
    this.relatedPlayerName,
    required this.minute,
    this.isInjured,
    this.extraTime,
    this.result,
    this.addition,
    this.info,
    required this.type,
  });

  factory Events.fromJson(Map<String, dynamic> json) {
    return Events(
      id: json['id'],
      fixtureId: json['fixture_id'],
      participantId: json['participant_id'],
      playerName: json['player_name'],
      relatedPlayerName: json['related_player_name'],
      minute: json['minute'],
      isInjured: json['injured'],
      result: json['result'],
      info: json['info'],
      extraTime: json['extra_minute'],
      addition: json['addition'],
      type: Type.fromJson(json['type']),
    );
  }

  @override
  String toString() {
    return 'Events{id: $id, fixtureId: $fixtureId, participantId: $participantId,playerName: $playerName, relatedPlayerName: $relatedPlayerName, injured: $isInjured, result: $result, info: $info, minute: $minute, addition: $addition, type: $type, extraTime: $extraTime}';
  }
}

class Type {
  final int id;
  final String name;

  Type({
    required this.id,
    required this.name,
  });

  factory Type.fromJson(Map<String, dynamic> json) {
    return Type(
      id: json['id'],
      name: json['name'],
    );
  }

  @override
  String toString() {
    return 'Type{id: $id, name: $name}';
  }
}
