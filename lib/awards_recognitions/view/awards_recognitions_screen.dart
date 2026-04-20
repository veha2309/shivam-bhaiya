import 'package:flutter/material.dart';
import 'package:school_app/auth/model/user.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/student_dossier_detail/View/components/award_recognition_view.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/body.dart';

class AwardsRecognitionScreen extends StatefulWidget {
  static const String routeName = '/awards-recognition';
  final String? title;
  const AwardsRecognitionScreen({super.key, this.title});

  @override
  State<AwardsRecognitionScreen> createState() =>
      _AwardsRecognitionScreenState();
}

class _AwardsRecognitionScreenState extends State<AwardsRecognitionScreen> {
  User? user = AuthViewModel.instance.getLoggedInUser();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: AppBody(
        title: widget.title ?? "Acheivement Profile",
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AwardRecognitionView(
            studentId: user?.username ?? "",
            cardView: false,
          ),
        ),
      ),
    );
  }
}
