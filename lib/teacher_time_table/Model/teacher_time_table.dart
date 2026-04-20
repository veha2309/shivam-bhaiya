class TeacherTimetableModel {
  final List<DaySchedule>? schedule;

  TeacherTimetableModel({this.schedule});

  // Convert JSON to TimetableModel object
  factory TeacherTimetableModel.fromJson(dynamic json) =>
      TeacherTimetableModel.fromMap(json);

  factory TeacherTimetableModel.fromMap(List<dynamic> json) =>
      TeacherTimetableModel(
          schedule: json.map((x) => DaySchedule.fromMap(x)).toList());

  List<Map<String, dynamic>>? toMap() =>
      schedule?.map((x) => x.toMap() ?? {}).toList();
}

class DaySchedule {
  final String? day;
  final List<Lecture>? timetable;

  DaySchedule({this.day, this.timetable});

  factory DaySchedule.fromMap(Map<String, dynamic> json) => DaySchedule(
        day: json["day"],
        timetable: (json["timetable"] as List?)
            ?.map((x) => Lecture.fromMap(x))
            .toList(),
      );

  Map<String, dynamic>? toMap() => {
        "day": day,
        "timetable": timetable?.map((x) => x.toMap()).toList(),
      };
}

class Lecture {
  final String? subject;
  final String? timing;
  final String? lecture;
  final String? lectureName;
  final String? className;

  Lecture(
      {this.subject,
      this.timing,
      this.lecture,
      this.lectureName,
      this.className});

  factory Lecture.fromMap(Map<String, dynamic> json) => Lecture(
        subject: json["subject"],
        timing: json["timing"],
        lecture: json["lecture"],
        lectureName: json["lecturename"],
        className: json["class"],
      );

  Map<String, dynamic>? toMap() => {
        "subject": subject,
        "timing": timing,
        "lecture": lecture,
        "lecturename": lectureName,
        "class": className,
      };
}
