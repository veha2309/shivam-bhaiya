import 'package:flutter/material.dart';
import 'package:school_app/auth/model/user.dart';
import 'package:school_app/concerns/view/concerns_view.dart';
import 'package:school_app/concerns_detail/view/concerns_detail_view.dart';
import 'package:school_app/discipline_passbook/view_model/discipline_passbook_view_model.dart';
import 'package:school_app/discipline_passbook/model/discipline_student_model.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/home_screen/model/home.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/body.dart';

class StudentRuleViolationRecordScreen extends StatefulWidget {
  static const String routeName = '/student-rule-violation-record-screen';
  final String? title;
  const StudentRuleViolationRecordScreen({super.key, this.title});

  @override
  State<StudentRuleViolationRecordScreen> createState() =>
      _StudentRuleViolationRecordScreenState();
}

class _StudentRuleViolationRecordScreenState
    extends State<StudentRuleViolationRecordScreen>
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
          .getStudentListForDisciplinePassbook(
        homeModel?.sessionCode ?? '',
        loggedInUser!.sectionCode ?? '',
        loggedInUser!.name,
      );

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
        body: Column(
          children: [
            TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: 'Uniform Violation'),
                Tab(text: 'Penalty Cards'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 1st tab: Uniform Violation
                  ConcernsDetailView(
                    screenType: ConcernsViewScreenType.discipline,
                    studentId: loggedInUser?.username ?? "",
                    shouldShowScaffold: false,
                    studentName: loggedInUser?.name ?? "",
                  ),
                  // 2nd tab: Penalty Card
                  ConcernsDetailView(
                    studentId: loggedInUser?.username ?? "",
                    studentName: loggedInUser?.name ?? "",
                    shouldShowScaffold: false,
                    screenType: ConcernsViewScreenType.disciplineCard,
                  ),

                  // FutureBuilder<DisciplineStudentModel?>(
                  //   future: _fetchStudentDiscipline(),
                  //   builder: (context, snapshot) {
                  //     if (snapshot.connectionState == ConnectionState.waiting) {
                  //       return const Center(child: CircularProgressIndicator());
                  //     }

                  //     if (snapshot.hasError) {
                  //       return Center(child: Text('Error: ${snapshot.error}'));
                  //     }

                  //     if (!snapshot.hasData || snapshot.data == null) {
                  //       return const NoDataWidget();
                  //     }

                  //     return MyDisciplinePassbookScreen(
                  //         studentModel: snapshot.data!);
                  //   },
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
