class Lecture {
  String? teacher;
  String? lectureType;
  String? subject;
  String? lecture;

  Lecture({
    this.teacher,
    this.lectureType,
    this.subject,
    this.lecture,
  });

  factory Lecture.fromJson(Map<String, dynamic> json) {
    return Lecture(
      teacher: json['teacher'],
      lectureType: json['lecturetype'],
      subject: json['subject'],
      lecture: json['lecture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teacher': teacher,
      'lecturetype': lectureType,
      'subject': subject,
      'lecture': lecture,
    };
  }
}

enum WeekDay { Mon, Tue, Wed, Thu, Fri, Sat }

extension WeekDayString on WeekDay {
  String get value {
    switch (this) {
      case WeekDay.Mon:
        return 'Mon';
      case WeekDay.Tue:
        return 'Tue';
      case WeekDay.Wed:
        return 'Wed';
      case WeekDay.Thu:
        return 'Thu';
      case WeekDay.Fri:
        return 'Fri';
      case WeekDay.Sat:
        return 'Sat';
    }
  }

  // Add this for full lowercase string
  String get fullLowercase {
    switch (this) {
      case WeekDay.Mon:
        return 'monday';
      case WeekDay.Tue:
        return 'tuesday';
      case WeekDay.Wed:
        return 'wednesday';
      case WeekDay.Thu:
        return 'thursday';
      case WeekDay.Fri:
        return 'friday';
      case WeekDay.Sat:
        return 'saturday';
    }
  }
}

class DaySchedule {
  WeekDay? day;
  List<Lecture>? timetable;

  DaySchedule({
    this.day,
    this.timetable,
  });

  factory DaySchedule.fromJson(Map<String, dynamic> json) {
    return DaySchedule(
      day: _parseWeekDay(json['day']),
      timetable: (json['timetable'] as List?)
          ?.map((item) => Lecture.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day?.toString().split('.').last,
      'timetable': timetable?.map((lecture) => lecture.toJson()).toList(),
    };
  }
}

// Helper function to parse string to WeekDay enum
WeekDay _parseWeekDay(String day) {
  final normalizedDay = day.substring(0, 3).capitalize();
  return WeekDay.values.firstWhere(
    (e) => e.toString().split('.').last == normalizedDay,
    orElse: () => WeekDay.Mon, // Default value if parsing fails
  );
}

// Extension to capitalize first letter
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

// Function to parse a list of schedules
List<DaySchedule> parseTimetable(List<dynamic> jsonData) {
  return jsonData.map((item) => DaySchedule.fromJson(item)).toList();
}
