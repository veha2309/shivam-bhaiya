import 'package:flutter/material.dart';
import 'package:school_app/student_dossier/Model/student_dossier.dart';
import 'package:school_app/student_dossier_detail/View/components/academic_concerns_view.dart';
import 'package:school_app/student_dossier_detail/View/components/academic_record_view.dart';
import 'package:school_app/student_dossier_detail/View/components/attendance_record_view.dart';
import 'package:school_app/student_dossier_detail/View/components/award_recognition_view.dart';
import 'package:school_app/student_dossier_detail/View/components/dashboard_view.dart';
import 'package:school_app/student_dossier_detail/View/components/health_record_view.dart';
import 'package:school_app/student_dossier_detail/View/components/library_record_view.dart';
import 'package:school_app/student_dossier_detail/View/components/student_dossier_subsection_view.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/utils.dart';

enum DossierViewType {
  dashboards("Student's Details"),
  // feedbackBySubjectTeacher("Feedback By Subject Teacher"),
  academicRecord("Academic Record"),
  awardsAndRecognition("Awards & Recognition"),
  attendanceRecord("Attendance Record"),
  healthRecord("Health Record"),
  academicConcerns("Academic Concerns"),
  libraryRecord("Library Record");
  // disciplineRecord("Discipline Record");

  const DossierViewType(this.title);
  final String title;
}

class StudentDossierDetailScreen extends StatefulWidget {
  static const String routeName = '/student-dossier-detail';
  final String? title;
  final StudentDossier studentDossier;
  const StudentDossierDetailScreen(
      {super.key, this.title, required this.studentDossier});

  @override
  State<StudentDossierDetailScreen> createState() =>
      _StudentDossierDetailScreenState();
}

class _StudentDossierDetailScreenState
    extends State<StudentDossierDetailScreen> {
  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      studentName: widget.studentDossier.studentName,
      isLoadingNotifier: isLoadingNotifier,
      body: AppBody(
        title: widget.title ?? "Student Dossier Detail",
        body: studentDossierDetailScreenBody(context),
      ),
    );
  }

  Widget studentDossierDetailScreenBody(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 16.0,
          children: [
            getOptionGrid(),
          ],
        ),
      ),
    );
  }

  Widget getOptionGrid() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children:
          DossierViewType.values.map((value) => getOption(value)).toList(),
    );
  }

  Widget getOption(DossierViewType viewType) {
    return InkWell(
      splashColor: Colors.white,
      splashFactory: InkRipple.splashFactory,
      onTap: () {
        navigateToScreen(
            context,
            StudentDossierSubsectionDetailScreen(
                studentDossier: widget.studentDossier, viewType: viewType));
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12.0),
        height: 70,
        decoration: const BoxDecoration(
          color: ColorConstant.primaryColor,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        padding: const EdgeInsets.all(4),
        alignment: Alignment.center,
        child: Text(
          viewType.title,
          textAlign: TextAlign.center,
          textScaler: const TextScaler.linear(1.0),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
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
      //   return const SizedBox.shrink();
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
      //   return const SizedBox.shrink();
      //   return DisciplineRecordView(
      //     studentId: widget.studentDossier.studentId,
      //   );
    }
  }
}
