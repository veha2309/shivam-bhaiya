import 'package:flutter/material.dart';
import 'package:school_app/student_dossier/Model/student_dossier.dart';
import 'package:school_app/student_dossier_detail/View/components/academic_concerns_view.dart';
import 'package:school_app/student_dossier_detail/View/components/academic_record_view.dart';
import 'package:school_app/student_dossier_detail/View/components/attendance_record_view.dart';
import 'package:school_app/student_dossier_detail/View/components/award_recognition_view.dart';
import 'package:school_app/student_dossier_detail/View/components/dashboard_view.dart';
// import 'package:school_app/student_dossier_detail/View/components/discipline_record_view.dart';
// import 'package:school_app/student_dossier_detail/View/components/feed_subject_teacher_view.dart';
import 'package:school_app/student_dossier_detail/View/components/health_record_view.dart';
import 'package:school_app/student_dossier_detail/View/components/library_record_view.dart';
import 'package:school_app/student_dossier_detail/View/student_dossier_detail_screen.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/body.dart';

class StudentDossierSubsectionDetailScreen extends StatefulWidget {
  static const String routeName = '/student-dossier-subsection-detail';
  final StudentDossier studentDossier;
  final DossierViewType viewType;

  const StudentDossierSubsectionDetailScreen(
      {super.key, required this.studentDossier, required this.viewType});

  @override
  State<StudentDossierSubsectionDetailScreen> createState() =>
      _StudentDossierSubsectionDetailScreenState();
}

class _StudentDossierSubsectionDetailScreenState
    extends State<StudentDossierSubsectionDetailScreen> {
  ValueNotifier<DossierViewType> selectedViewType =
      ValueNotifier(DossierViewType.dashboards);
  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      isLoadingNotifier: isLoadingNotifier,
      studentName: widget.viewType == DossierViewType.dashboards
          ? null
          : widget.studentDossier.studentName,
      body: AppBody(
        title: widget.viewType.title,
        body: getStudentDossierDetailBody(context),
      ),
    );
  }

  Widget getStudentDossierDetailBody(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: getViewBasedOnSelectedTab(widget.viewType),
      ),
    );
  }

  Widget getViewBasedOnSelectedTab(DossierViewType selectedViewType) {
    switch (selectedViewType) {
      case DossierViewType.dashboards:
        return DashboardView(
          studentId: widget.studentDossier.studentId ?? "",
        );
      // case DossierViewType.feedbackBySubjectTeacher:
      //   return FeedSubjectTeacherView(
      //     student: widget.studentDossier,
      //   );
      case DossierViewType.academicRecord:
        return AcademicRecordView(
          studentId: widget.studentDossier.studentId ?? "",
        );
      case DossierViewType.awardsAndRecognition:
        return AwardRecognitionView(
          studentId: widget.studentDossier.studentId ?? "",
        );
      case DossierViewType.attendanceRecord:
        return AttendanceRecordView(
          studentId: widget.studentDossier.studentId ?? "",
        );
      case DossierViewType.healthRecord:
        return HealthRecordView(
          studentId: widget.studentDossier.studentId ?? "",
        );
      case DossierViewType.academicConcerns:
        return AcademicConcernsView(
          studentId: widget.studentDossier.studentId ?? "",
        );
      case DossierViewType.libraryRecord:
        return LibraryRecordView(
          studentId: widget.studentDossier.studentId ?? "",
        );
      // case DossierViewType.disciplineRecord:
      //   return DisciplineRecordView(
      //     studentId: widget.studentDossier.studentId,
      //   );
    }
  }
}
