class RewardRecognitionModel {
  final String? sessionName;
  final String? studentName;
  final String? competitionName;
  final String? competitionType;
  final String? eventType;
  final String? prize;
  final String? eventDate;
  final String? eventName;

  RewardRecognitionModel({
    this.sessionName,
    this.studentName,
    this.competitionName,
    this.competitionType,
    this.eventType,
    this.prize,
    this.eventDate,
    this.eventName,
  });

  // Factory method to create a StudentCompetition from JSON
  factory RewardRecognitionModel.fromJson(Map<String, dynamic> json) {
    return RewardRecognitionModel(
      sessionName: json['sessionname'],
      studentName: json['studentname'],
      competitionName: json['competitionname'],
      competitionType: json['competitiontype'],
      eventType: json['eventtype'],
      prize: json['prize'],
      eventDate: json['eventdate'],
      eventName: json['eventname'],
    );
  }

  // Method to convert StudentCompetition to JSON
  Map<String, dynamic> toJson() {
    return {
      'sessionname': sessionName,
      'studentname': studentName,
      'competitionname': competitionName,
      'competitiontype': competitionType,
      'eventtype': eventType,
      'prize': prize,
      'eventdate': eventDate,
      'eventname': eventName,
    };
  }
}
