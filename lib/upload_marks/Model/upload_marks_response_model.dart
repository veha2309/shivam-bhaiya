class UploadMarksResponseModel {
  final String? session;
  final String? classCode;
  final String? section;
  final String? examNameCode;
  final String? subjectCode;
  final String? examActivityCode;
  final String? subActivityCode;
  final String? maxMarks;
  final String? createdBy;
  final String? mode;
  final String? entryType;
  final String? subjectName;
  final String? className;
  final String? examName;
  final String? activityName;
  final List<UploadMarksStudentMark>? studentMarks;
  final List<String>? studentIds;

  UploadMarksResponseModel({
    this.session,
    this.classCode,
    this.section,
    this.examNameCode,
    this.subjectCode,
    this.examActivityCode,
    this.subActivityCode,
    this.maxMarks,
    this.createdBy,
    this.mode,
    this.entryType,
    this.subjectName,
    this.className,
    this.examName,
    this.activityName,
    this.studentMarks,
    this.studentIds,
  });

  // Factory method to create an instance from a JSON object
  factory UploadMarksResponseModel.fromJson(Map<String, dynamic> json) {
    return UploadMarksResponseModel(
      session: json['session1'],
      classCode: json['class1'],
      section: json['section'],
      examNameCode: json['examNameCode'],
      subjectCode: json['subjectCode'],
      examActivityCode: json['examactivitycode'],
      subActivityCode: json['subActivityCode'],
      maxMarks: json['maxMarks'],
      createdBy: json['createdBy'],
      mode: json['mode'],
      entryType: json['entryType'],
      subjectName: json['subjectName'],
      className: json['className'],
      examName: json['examName'],
      activityName: json['activityName'],
      studentMarks: (json['studentMarks'] as List<dynamic>)
          .map((e) => UploadMarksStudentMark.fromString(e.toString()))
          .toList(),
      studentIds: (json['studentId'] as String)
          .split(',')
          .where((id) => id.isNotEmpty)
          .toList(),
    );
  }

  // Convert instance to JSON format
  Map<String, dynamic> toJson() {
    return {
      'session1': session,
      'class1': classCode,
      'section': section,
      'examNameCode': examNameCode,
      'subjectCode': subjectCode,
      'examactivitycode': examActivityCode,
      'subActivityCode': subActivityCode,
      'maxMarks': maxMarks.toString(),
      'createdBy': createdBy,
      'mode': mode,
      'entryType': entryType,
      'subjectName': subjectName,
      'className': className,
      'examName': examName,
      'activityName': activityName,
      'studentMarks': studentMarks?.map((e) => e.toString()).toList(),
      'studentId': studentIds?.join(','),
    };
  }

  @override
  String toString() {
    return 'ExamMarks(examName: $examName, subject: $subjectName, maxMarks: $maxMarks, students: ${studentMarks?.length})';
  }
}

class UploadMarksStudentMark {
  final String studentId;
  final String? marks;
  final String paramValue;
  final String attendanceValue;
  final String group;

  UploadMarksStudentMark({
    required this.studentId,
    required this.marks,
    required this.paramValue,
    required this.attendanceValue,
    required this.group,
  });

  // Parsing string format "R7734#2#P#0#-"
  factory UploadMarksStudentMark.fromString(String data) {
    List<String> parts = data.split('#');
    return UploadMarksStudentMark(
      studentId: parts[0],
      marks: parts[1],
      paramValue: parts[2],
      attendanceValue: parts[3],
      group: parts[4],
    );
  }

  @override
  String toString() {
    if (marks == null) {
      return '$studentId##$paramValue#$attendanceValue#$group';
    }
    return '$studentId#$marks#$paramValue#$attendanceValue#$group';
  }
}
