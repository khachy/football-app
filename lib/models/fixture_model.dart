class Fixture {
  final int id;
  final int seasonId;
  final String startingAt;
  final int? length;
  final String? resultInfo;
  final String name;
  final League league;
  final List<Scores> scores;
  final List<Participants> participants;
  // final List<Events> events;

  Fixture({
    required this.id,
    required this.seasonId,
    required this.name,
    required this.startingAt,
    required this.length,
    required this.resultInfo,
    required this.league,
    required this.scores,
    required this.participants,
    // required this.events,
  });

  factory Fixture.fromJson(Map<String, dynamic> json) {
    List<dynamic> participantsList = json['participants'];
    List<Participants> participants = participantsList
        .map((participantJson) => Participants.fromJson(participantJson))
        .toList();
    List<dynamic> scoreList = json['scores'];
    List<Scores> scores =
        scoreList.map((scoreJson) => Scores.fromJson(scoreJson)).toList();
    // List<dynamic> eventList = json['events'];
    // List<Events> events =
    //     eventList.map((eventJson) => Events.fromJson(eventJson)).toList();
    return Fixture(
      id: json['id'],
      seasonId: json['season_id'],
      name: json['name'],
      startingAt: json['starting_at'],
      league: League.fromJson(json['league']),
      scores: scores,
      participants: participants,
      length: json['length'],
      resultInfo: json['result_info'],
      // events: events,
    );
  }

  @override
  String toString() {
    return 'Fixture{startingAt: $startingAt, league: $league, participants: $participants, scores: $scores, result_info: $resultInfo}';
  }
}

class League {
  final String name;
  final String imagePath;
  final String shortCode;

  League({
    required this.name,
    required this.imagePath,
    required this.shortCode,
  });

  factory League.fromJson(Map<String, dynamic> json) {
    return League(
      name: json['name'],
      imagePath: json['image_path'],
      shortCode: json['short_code'],
    );
  }

  @override
  String toString() {
    return 'League{name: $name, imagePath: $imagePath, shortCode: $shortCode}';
  }
}

class Scores {
  final int id;
  final int participantId;
  final int goals;
  final String description;

  Scores({
    required this.id,
    required this.participantId,
    required this.goals,
    required this.description,
  });

  factory Scores.fromJson(Map<String, dynamic> json) {
    return Scores(
      id: json['id'],
      participantId: json['participant_id'],
      goals: json['score']['goals'],
      description: json['description'],
    );
  }
  @override
  String toString() {
    return 'Scores{id: $id, participantId: $participantId, goals: $goals, desc: $description}';
  }
}

class Participants {
  final int id;
  final String name;
  final String imagePath;
  final Meta meta;

  Participants({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.meta,
  });

  factory Participants.fromJson(Map<String, dynamic> json) {
    return Participants(
        id: json['id'],
        name: json['name'],
        imagePath: json['image_path'],
        meta: Meta.fromJson(json['meta']));
  }

  @override
  String toString() {
    return 'Participants{id: $id, name: $name, imagePath: $imagePath, meta: $meta}';
  }
}

class Meta {
  final String location;
  final bool? winner;

  Meta({
    required this.location,
    required this.winner,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      location: json['location'],
      winner: json['winner'],
    );
  }
  @override
  String toString() {
    return 'Meta{location: $location, winner: $winner}';
  }
}
