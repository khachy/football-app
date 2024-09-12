class Comments {
  final String comment;
  final int? minute;
  final int? extraMinute;
  final bool isGoal;
  final bool isImportant;

  Comments({
    required this.comment,
    this.minute,
    this.extraMinute,
    required this.isGoal,
    required this.isImportant,
  });

  factory Comments.fromJson(Map<String, dynamic> json) {
    return Comments(
      comment: json['comment'],
      minute: json['minute'],
      extraMinute: json['extra_minute'] ?? 0,
      isGoal: json['is_goal'],
      isImportant: json['is_important'],
    );
  }

  @override
  String toString() {
    return ' Comment{comment: $comment, minute: $minute, extraMinute: $extraMinute, isImportant: $isImportant}';
  }
}
