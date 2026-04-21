// Main model class for Student
class StudentProfile {
  String? admissionNo;
  String? studentName;
  String? dob;
  String? address;
  String? mobileNo;
  String? memail;
  String? fatherName;
  String? motherName;
  String? fmobileno;
  String? femail;
  String? mmobileno;
  String? dateOfAdm;
  String? userImage;
  String? teacherName;
  String? rollNo;
  String? className;
  String? routeName;
  List<StudentProfileReportCard>? reportCards;
  List<StudentProfileMedicalVisit>? medicalVisits;
  List<StudentProfileExamMarks>? examMarks;
  List<StudentProfileAttendance>? attendance;
  List<dynamic>? telent;
  List<dynamic>? feedback;
  List<dynamic>? awards;
  List<dynamic>? feeStatus;

  StudentProfile({
    required this.admissionNo,
    required this.studentName,
    required this.dob,
    required this.address,
    required this.mobileNo,
    required this.memail,
    required this.fatherName,
    required this.motherName,
    required this.fmobileno,
    required this.femail,
    required this.mmobileno,
    required this.dateOfAdm,
    required this.reportCards,
    required this.medicalVisits,
    required this.examMarks,
    required this.attendance,
    required this.className,
    required this.userImage,
    required this.teacherName,
    required this.rollNo,
    required this.routeName,
    required this.telent,
    required this.feedback,
    required this.awards,
    required this.feeStatus,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      admissionNo: json['admissionno'],
      studentName: json['studentName'],
      dob: json['dob'],
      address: json['address'],
      mobileNo: json['mobileNo'],
      memail: json['memail'],
      fatherName: json['fatherName'],
      motherName: json['motherName'],
      fmobileno: json['fmobileno'],
      femail: json['femail'],
      mmobileno: json['mmobileno'],
      className: json['className'],
      dateOfAdm: json['dateOfAdm'],
      userImage: json['userImage'],
      teacherName: json['classTeacher'],
      rollNo: json['rollNo'],
      routeName: json['routeName'],
      reportCards: List<StudentProfileReportCard>.from(
          (json['reportcard'] ?? [])
              .map((x) => StudentProfileReportCard.fromJson(x))),
      medicalVisits: List<StudentProfileMedicalVisit>.from(
          (json['medical'] ?? [])
              .map((x) => StudentProfileMedicalVisit.fromJson(x))),
      examMarks: List<StudentProfileExamMarks>.from((json['examMarks'] ?? [])
          .map((x) => StudentProfileExamMarks.fromJson(x))),
      attendance: List<StudentProfileAttendance>.from((json['attendance'] ?? [])
          .map((x) => StudentProfileAttendance.fromJson(x))),
      telent: json['telent'] ?? [],
      feedback: json['feedback'] ?? [],
      awards: json['awards'] ?? [],
      feeStatus: json['feeStatus'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'admissionno': admissionNo,
      'studentName': studentName,
      'dob': dob,
      'address': address,
      'mobileNo': mobileNo,
      'memail': memail,
      'fatherName': fatherName,
      'motherName': motherName,
      'fmobileno': fmobileno,
      'femail': femail,
      'mmobileno': mmobileno,
      'dateOfAdm': dateOfAdm,
      'reportcard': reportCards?.map((x) => x.toJson()).toList() ?? [],
      'medical': medicalVisits?.map((x) => x.toJson()).toList() ?? [],
      'examMarks': examMarks?.map((x) => x.toJson()).toList() ?? [],
      'attendance': attendance?.map((x) => x.toJson()).toList() ?? [],
      'className': className,
      'userImage': userImage,
      'classTeacher': teacherName,
      'rollNo': rollNo,
      'routeName': routeName,
      'telent': telent ?? [],
      'feedback': feedback ?? [],
      'awards': awards ?? [],
      'feeStatus': feeStatus ?? [],
    };
  }
}

// ReportCard Model
class StudentProfileReportCard {
  String? sectionCode;
  String? reportCardStatus;
  String? session;
  String? classCode;
  String? sessionCode;
  String? reportUrl;
  String? termName;
  String? className;

  StudentProfileReportCard({
    required this.sectionCode,
    required this.reportCardStatus,
    required this.session,
    required this.classCode,
    required this.sessionCode,
    required this.reportUrl,
    required this.termName,
    required this.className,
  });

  factory StudentProfileReportCard.fromJson(Map<String, dynamic> json) {
    return StudentProfileReportCard(
      sectionCode: json['Sectioncode'],
      reportCardStatus: json['reportcardstatus'],
      session: json['session'],
      classCode: json['classcode'],
      sessionCode: json['Sessioncode'],
      reportUrl: json['reporturl'],
      termName: json['termname'],
      className: json['class'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Sectioncode': sectionCode,
      'reportcardstatus': reportCardStatus,
      'session': session,
      'classcode': classCode,
      'Sessioncode': sessionCode,
      'reporturl': reportUrl,
      'termname': termName,
      'class': className,
    };
  }
}

// MedicalVisit Model
class StudentProfileMedicalVisit {
  String? diagnosis;
  String? referral;
  String? visitDate;
  String? followUp;

  StudentProfileMedicalVisit({
    required this.diagnosis,
    required this.referral,
    required this.visitDate,
    required this.followUp,
  });

  factory StudentProfileMedicalVisit.fromJson(Map<String, dynamic> json) {
    return StudentProfileMedicalVisit(
      diagnosis: json['diagnosis'],
      referral: json['Refferal'],
      visitDate: json['visit_date'],
      followUp: json['follow_up'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'diagnosis': diagnosis,
      'Refferal': referral,
      'visit_date': visitDate,
      'follow_up': followUp,
    };
  }
}

// ExamMarks Model
class StudentProfileExamMarks {
  List<StudentProfileExamSubject>? subjects;

  StudentProfileExamMarks({
    required this.subjects,
  });

  factory StudentProfileExamMarks.fromJson(Map<String, dynamic> json) {
    return StudentProfileExamMarks(
      subjects: List<StudentProfileExamSubject>.from((json['subjects'] ?? [])
          .map((x) => StudentProfileExamSubject.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subjects': subjects?.map((x) => x.toJson()).toList() ?? [],
    };
  }
}

class StudentProfileExamSubject {
  String? subjectName;
  List<StudentProfileSubjectMarks>? terms;

  StudentProfileExamSubject({
    required this.subjectName,
    required this.terms,
  });

  factory StudentProfileExamSubject.fromJson(Map<String, dynamic> json) {
    return StudentProfileExamSubject(
      subjectName: json['subjectName'],
      terms: List<StudentProfileSubjectMarks>.from((json['terms'] ?? [])
          .map((x) => StudentProfileSubjectMarks.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subjectName': subjectName,
      'terms': terms?.map((x) => x.toJson()).toList() ?? [],
    };
  }
}

class StudentProfileSubjectMarks {
  List<StudentProfileSubject>? subjects;
  String? termCode;

  StudentProfileSubjectMarks({
    required this.subjects,
    required this.termCode,
  });

  factory StudentProfileSubjectMarks.fromJson(Map<String, dynamic> json) {
    return StudentProfileSubjectMarks(
      subjects: List<StudentProfileSubject>.from((json['subjects'] ?? [])
          .map((x) => StudentProfileSubject.fromJson(x))),
      termCode: json['termCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subjects': subjects?.map((x) => x.toJson()).toList() ?? [],
      'termCode': termCode,
    };
  }
}

class StudentProfileSubject {
  String? subjectName;
  String? mm;
  String? mo;
  String? subjectAct;

  StudentProfileSubject({
    required this.subjectName,
    required this.mm,
    required this.mo,
    required this.subjectAct,
  });

  factory StudentProfileSubject.fromJson(Map<String, dynamic> json) {
    return StudentProfileSubject(
      subjectName: json['subjectName'],
      mm: json['mm'],
      mo: json['mo'],
      subjectAct: json['subjectAct'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subjectName': subjectName,
      'mm': mm,
      'mo': mo,
      'subjectAct': subjectAct,
    };
  }
}

// Attendance Model
class StudentProfileAttendance {
  String? sequ;
  String? className;
  String? sessionName;
  String? reportUrl;
  List<StudentProfileAttendanceStatus>? sessionAttendanceStats;

  StudentProfileAttendance({
    required this.sequ,
    required this.className,
    required this.sessionName,
    required this.reportUrl,
    required this.sessionAttendanceStats,
  });

  factory StudentProfileAttendance.fromJson(Map<String, dynamic> json) {
    return StudentProfileAttendance(
      sequ: json['sequ'],
      className: json['classname'],
      sessionName: json['sessionname'],
      reportUrl: json['reporturl'],
      sessionAttendanceStats: List<StudentProfileAttendanceStatus>.from(
          json['sessionattendacestats']
                  ?.map((x) => StudentProfileAttendanceStatus.fromJson(x)) ??
              []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sequ': sequ,
      'classname': className,
      'sessionname': sessionName,
      'reporturl': reportUrl,
      'sessionattendacestats':
          sessionAttendanceStats?.map((x) => x.toJson()).toList() ?? [],
    };
  }
}

class StudentProfileAttendanceStatus {
  String? attendanceStatus;
  String? typeCount;

  StudentProfileAttendanceStatus({
    required this.attendanceStatus,
    required this.typeCount,
  });

  factory StudentProfileAttendanceStatus.fromJson(Map<String, dynamic> json) {
    return StudentProfileAttendanceStatus(
      attendanceStatus: json['attendancestatus'],
      typeCount: json['typecount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attendancestatus': attendanceStatus,
      'typecount': typeCount,
    };
  }
}
