class Period {
  final String description;
  final int? timeAdded;

  Period({required this.description, this.timeAdded});

  factory Period.fromJson(Map<String, dynamic> json) {
    return Period(
      description: json['description'],
      timeAdded: json['time_added'],
    );
  }
}
