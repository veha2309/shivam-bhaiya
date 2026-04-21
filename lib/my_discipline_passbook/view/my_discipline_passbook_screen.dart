import 'package:flutter/material.dart';
import 'package:school_app/auth/model/user.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/discipline_passbook/model/discipline_student_model.dart';
import 'package:school_app/my_discipline_passbook/model/discipline_transaction_model.dart';
import 'package:school_app/my_discipline_passbook/view_model/discipline_transaction_view_model.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/components/table_widget.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/utils.dart';

class MyDisciplinePassbookScreen extends StatefulWidget {
  static const String routeName = '/my-discipline-passbook';
  final String? title;
  final DisciplineStudentModel studentModel;
  final bool shouldShowScaffold;

  const MyDisciplinePassbookScreen({
    super.key,
    this.title,
    required this.studentModel,
    this.shouldShowScaffold = true,
  });

  @override
  State<MyDisciplinePassbookScreen> createState() =>
      _MyDisciplinePassbookScreenState();
}

class _MyDisciplinePassbookScreenState
    extends State<MyDisciplinePassbookScreen> {
  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);
  late DisciplineStudentModel studentModel;
  Future<ApiResponse<List<DisciplineTransactionModel>>>?
      getDisciplineTransactionDetail;
  List<DisciplineTransactionModel> disciplineTransactionList = [];
  User? loggedInUser;

  @override
  void initState() {
    super.initState();
    loggedInUser = AuthViewModel.instance.getLoggedInUser();
    callGetDisciplineTransactionDetailFuture();
  }

  void callGetDisciplineTransactionDetailFuture() {
    studentModel = widget.studentModel;
    getDisciplineTransactionDetail = DisciplineTransactionViewModel.instance
        .getDisciplineTransactionDetail(studentModel.studentId ?? "")
        .then(
      (response) {
        if (response.success) {
          disciplineTransactionList = response.data!;
          setState(() {});
        }
        return response;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.shouldShowScaffold) {
      return AppScaffold(
        isLoadingNotifier: isLoadingNotifier,
        body: AppBody(
          title: widget.title ?? "Discipline Passbook",
          body: getMyDisciplinePassBookBody(context),
        ),
      );
    } else {
      return getMyDisciplinePassBookBody(context);
    }
  }

  Widget getMyDisciplinePassBookBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                getStudentInfoCard(),
                getPointTransactionTable(),
                const SizedBox(height: 50),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                getZoneCard(),
                const Divider(
                  color: ColorConstant.primaryColor,
                ),
                getMonthlyAttendance(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getStudentInfoCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16.0,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            loggedInUser?.userType == "Teacher"
                ? Expanded(
                    child: getStatCard("Name", studentModel.studentName ?? "-"))
                : const SizedBox(),
            Expanded(
                child: getStatCard("Class", studentModel.className ?? "-")),
            Expanded(child: getStatCard("Zone", studentModel.zone ?? "-")),
          ],
        )
      ],
    );
  }

  Widget getPointTransactionTable() {
    return SizedBox(
      child: DataTableWidget(
        headers: [
          TableColumnConfiguration(text: "S.No", width: 30),
          TableColumnConfiguration(text: "Date", width: 75),
          TableColumnConfiguration(text: "Credit", width: 35),
          TableColumnConfiguration(text: "Debit", width: 35),
          TableColumnConfiguration(text: "Area\nof\nconcern", width: 60),
          TableColumnConfiguration(text: "Penalty\nCard", width: 50),
          TableColumnConfiguration(text: "Action", width: 70),
          TableColumnConfiguration(text: "Balance", width: 50),
        ],
        data: disciplineTransactionList.asMap().entries.map((disciplineMap) {
          String sNo = (disciplineMap.key + 1).toString();
          DisciplineTransactionModel discipline = disciplineMap.value;
          return TableRowConfiguration(
            rowHeight: 35,
            cells: [
              TableCellConfiguration(text: sNo, width: 30),
              TableCellConfiguration(
                  text: formatAnyDateToDDMMYY(discipline.entryDate ?? ""), width: 75),
              TableCellConfiguration(text: discipline.credit.toString(), width: 40),
              TableCellConfiguration(text: discipline.debit.toString(), width: 35),
              TableCellConfiguration(text: discipline.reason, width: 60),
              TableCellConfiguration(text: discipline.penaltyCard, width: 50),
              TableCellConfiguration(text: discipline.actionTaken, width: 70),
              TableCellConfiguration(text: discipline.balance.toString(), width: 50),
            ],
          );
        }).toList(),
        horizontalMargin: 0,
        headingTextStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 9,
        ),
      ),
    );
  }

  Widget getZoneCard() {
    return SizedBox(
      child: Column(
        spacing: 8.0,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Zone Classification",
            textScaler: TextScaler.linear(1.0),
            style: TextStyle(
              color: ColorConstant.secondaryTextColor,
              fontSize: 20,
              fontFamily: fontFamily,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: getStatCard("Ideal", "100 points")),
              Expanded(child: getStatCard("Safe", "90-99 points")),
              Expanded(child: getStatCard("Alert", "80-89 points")),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: getStatCard("Danger", "60-79 points")),
              Expanded(child: getStatCard("Arrest", "40-59 points")),
              Expanded(child: getStatCard("Quarantine", "below 40 points")),
            ],
          )
        ],
      ),
    );
  }

  Widget getMonthlyAttendance() {
    return SizedBox(
      child: Column(
        spacing: 8.0,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Monthly Attendance Classification",
            textScaler: TextScaler.linear(1.0),
            style: TextStyle(
              color: ColorConstant.secondaryTextColor,
              fontSize: 20,
              fontFamily: fontFamily,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: getStatCard("75-80%", "1 point deduction")),
              Expanded(child: getStatCard("60-74.9%", "2 points deduction")),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: getStatCard("50-59.9%", "5 points deduction")),
              Expanded(child: getStatCard("Below 50%", "10 points deduction")),
            ],
          )
        ],
      ),
    );
  }
}

Widget getStatCard(String title, String subtitle) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        textScaler: const TextScaler.linear(1.0),
        style: const TextStyle(
          fontSize: 16,
          fontFamily: fontFamily,
          fontWeight: FontWeight.w500,
          color: ColorConstant.primaryColor,
        ),
      ),
      Text(
        subtitle,
        textScaler: const TextScaler.linear(1.0),
        style: const TextStyle(
          fontSize: 11,
          fontFamily: fontFamily,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
      ),
    ],
  );
}

Widget getRowStatCard(String title, String subtitle) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    spacing: 10,
    children: [
      Text(
        title,
        textScaler: const TextScaler.linear(1.0),
        style: const TextStyle(
          fontSize: 16,
          fontFamily: fontFamily,
          fontWeight: FontWeight.w500,
          color: ColorConstant.primaryColor,
        ),
      ),
      const Text(
        ":",
        textScaler: TextScaler.linear(1.0),
        style: TextStyle(
          fontSize: 11,
          fontFamily: fontFamily,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
      ),
      Text(
        subtitle,
        textScaler: const TextScaler.linear(1.0),
        style: const TextStyle(
          fontSize: 11,
          fontFamily: fontFamily,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
      ),
    ],
  );
}
