import 'package:flutter/material.dart';
import 'package:school_app/auth/model/user.dart';
import 'package:school_app/discipline_passbook/view_model/discipline_passbook_view_model.dart';
import 'package:school_app/discipline_passbook/model/discipline_student_model.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/home_screen/model/home.dart';
import 'package:school_app/my_discipline_passbook/view/my_discipline_passbook_screen.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/components/no_data_widget.dart';

class StudentDisciplinePassbookScreen extends StatefulWidget {
  static const String routeName = '/student-discipline-passbook';
  final String? title;
  const StudentDisciplinePassbookScreen({super.key, this.title});

  @override
  State<StudentDisciplinePassbookScreen> createState() =>
      _StudentDisciplinePassbookScreenState();
}

class _StudentDisciplinePassbookScreenState
    extends State<StudentDisciplinePassbookScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final User? loggedInUser = AuthViewModel.instance.getLoggedInUser();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<DisciplineStudentModel?> _fetchStudentDiscipline() async {
    try {
      if (loggedInUser == null) {
        return null;
      }

      HomeModel? homeModel = AuthViewModel.instance.homeModel;

      final response = await DisciplinePassbookViewModel.instance
          .getStudentListForDisciplinePassbook(homeModel?.sessionCode ?? '',
              loggedInUser!.sectionCode ?? '', "");

      if (response.data != null && response.data!.isNotEmpty) {
        final disciplineStudent = response.data!.firstWhere(
          (student) => student.studentId == loggedInUser!.username,
          orElse: () => DisciplineStudentModel(),
        );
        return disciplineStudent;
      }
      return null;
    } catch (e) {
      print('Error fetching student discipline: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: AppBody(
        title: widget.title,
        body: FutureBuilder<DisciplineStudentModel?>(
          future: _fetchStudentDiscipline(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return const NoDataWidget();
            }

            return MyDisciplinePassbookScreen(
              studentModel: snapshot.data!,
              shouldShowScaffold: false,
            );
          },
        ),
      ),
    );
  }
}
