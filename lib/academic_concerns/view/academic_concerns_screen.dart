import 'package:flutter/material.dart';
import 'package:school_app/auth/model/user.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/student_dossier_detail/View/components/academic_concerns_view.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/body.dart';

class AcademicConcernsScreen extends StatefulWidget {
  static const String routeName = '/academic-concerns';
  final String? title;

  const AcademicConcernsScreen({super.key, this.title});

  @override
  State<AcademicConcernsScreen> createState() => _AcademicConcernsScreenState();
}

class _AcademicConcernsScreenState extends State<AcademicConcernsScreen> {
  User? user = AuthViewModel.instance.getLoggedInUser();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: AppBody(
        title: widget.title ?? "Academic Norm Violation",
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: AcademicConcernsView(
              studentId: user?.username ?? "",
              cardView: false,
            ),
          ),
        ),
      ),
    );
  }
}
