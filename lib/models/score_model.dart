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
