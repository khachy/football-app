class RefereeInfo {
  final int id;
  final int fixtureId;
  final int refereeId;
  final int typeId;

  RefereeInfo({
    required this.id,
    required this.fixtureId,
    required this.refereeId,
    required this.typeId,
  });

  factory RefereeInfo.fromJson(Map<String, dynamic> json) {
    return RefereeInfo(
      id: json['id'],
      fixtureId: json['fixture_id'],
      refereeId: json['referee_id'],
      typeId: json['type_id'],
    );
  }

  @override
  String toString() {
    return 'Info{id: $id, fixtureId: $fixtureId, refereeId: $refereeId, typeId: $typeId}';
  }
}
