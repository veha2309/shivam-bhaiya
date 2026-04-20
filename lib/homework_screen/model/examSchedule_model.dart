class ExamScheduleModel {
  final Map<String, List<ExamSchedule>>? scheduleByDate;

  ExamScheduleModel({this.scheduleByDate});

  factory ExamScheduleModel.fromJson(Map<String, dynamic> json) {
    return ExamScheduleModel(
      scheduleByDate: json.map((key, value) {
        final List<ExamSchedule>? schedules = (value as List?)
            ?.map((item) => ExamSchedule.fromJson(item))
            .toList();
        return MapEntry(key, schedules ?? []);
      }),
    );
  }

  Map<String, dynamic>? toJson() {
    return scheduleByDate?.map((key, value) =>
        MapEntry(key, value.map((item) => item.toJson()).toList()));
  }
}

class ExamSchedule {
  final String? classCode;
  final String? freezeDate;
  final String? sessionCode;
  final String? examCode;
  final String? teacherName;
  final String? examName;
  final String? sessionName;
  final String? activityName;
  final String? sectionCode;
  final String? className;
  final String? teacherCode;
  final String? creationDate;
  final String? sectionName;
  final String? activityCode;
  final String? subactivityName;
  final String? createdBy;
  final String? subactivityCode;
  final String? subjectCode;
  final String? startDate;
  final String? subjectName;

  ExamSchedule({
    this.classCode,
    this.freezeDate,
    this.sessionCode,
    this.examCode,
    this.teacherName,
    this.examName,
    this.sessionName,
    this.activityName,
    this.sectionCode,
    this.className,
    this.teacherCode,
    this.creationDate,
    this.sectionName,
    this.activityCode,
    this.subactivityName,
    this.createdBy,
    this.subactivityCode,
    this.subjectCode,
    this.startDate,
    this.subjectName,
  });

  factory ExamSchedule.fromJson(Map<String, dynamic> json) {
    return ExamSchedule(
      classCode: json['classCode'],
      freezeDate: json['freezeDate'],
      sessionCode: json['sessionCode'],
      examCode: json['examCode'],
      teacherName: json['teacherName'],
      examName: json['examName'],
      sessionName: json['sessionName'],
      activityName: json['activityName'],
      sectionCode: json['sectionCode'],
      className: json['className'],
      teacherCode: json['teacherCode'],
      creationDate: json['creationDate'],
      sectionName: json['sectionName'],
      activityCode: json['activityCode'],
      subactivityName: json['subactivityName'],
      createdBy: json['createdBy'],
      subactivityCode: json['subactivityCode'],
      subjectCode: json['subjectCode'],
      startDate: json['startDate'],
      subjectName: json['subjectName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'classCode': classCode,
      'freezeDate': freezeDate,
      'sessionCode': sessionCode,
      'examCode': examCode,
      'teacherName': teacherName,
      'examName': examName,
      'sessionName': sessionName,
      'activityName': activityName,
      'sectionCode': sectionCode,
      'className': className,
      'teacherCode': teacherCode,
      'creationDate': creationDate,
      'sectionName': sectionName,
      'activityCode': activityCode,
      'subactivityName': subactivityName,
      'createdBy': createdBy,
      'subactivityCode': subactivityCode,
      'subjectCode': subjectCode,
      'startDate': startDate,
      'subjectName': subjectName,
    };
  }
}
