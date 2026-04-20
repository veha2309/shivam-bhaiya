import 'package:flutter/cupertino.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/student_time_table/Model/student_time_table.dart';
import 'package:school_app/upload_marks/Model/upload_subject_marks.dart';
import 'package:school_app/upload_marks/View/upload_marks_entry_screen.dart';
import 'package:school_app/upload_marks/ViewModel/upload_marks_view_model.dart';
import 'package:school_app/utils/components/app_button.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/components/no_data_widget.dart';
import 'package:school_app/utils/components/table_widget.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/utils.dart';

enum UploadMarksScreenState {
  marksToBeUploaded(title: "Marks to be uploaded", status: "MARKSTOBEENTERED"),
  marksEntered(title: "Marks Entered", status: "MARKSENTERED"),
  expired(title: "Expired", status: "EXPIRED"),
  ;

  final String title;
  final String status;

  const UploadMarksScreenState({
    required this.title,
    required this.status,
  });
}

class UploadMarksScreen extends StatefulWidget {
  static const String routeName = '/upload-marks';
  final UploadMarksScreenState screenState;
  final String screenName;
  const UploadMarksScreen({
    super.key,
    required this.screenState,
    required this.screenName,
  });

  @override
  State<UploadMarksScreen> createState() => _UploadMarksScreenState();
}

class _UploadMarksScreenState extends State<UploadMarksScreen> {
  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);

  Future<ApiResponse<List<UploadSubjectMarks>>>? uploadMarksList;
  List<UploadSubjectMarks>? marksData;

  @override
  void initState() {
    super.initState();
    callGetSubjectForMarksWithStatus();
  }

  void callGetSubjectForMarksWithStatus() {
    uploadMarksList = UploadMarksViewModel.instance
        .getSubjectForMarksWithStatus(widget.screenState.status)
        .then((response) {
      if (response.success) {
        marksData = response.data;
      }
      return response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      isLoadingNotifier: isLoadingNotifier,
      body: AppBody(
        title: widget.screenName,
        body: uploadMarksTableBody(context),
      ),
    );
  }

  Widget uploadMarksTableBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          spacing: 16.0,
          children: [
            AppFutureBuilder(
                future: uploadMarksList,
                builder: (context, snapshot) {
                  if (marksData == null || marksData!.isEmpty) {
                    return const NoDataWidget();
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: marksData?.length ?? 0,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 20),
                    itemBuilder: (context, index) => TableWidget(
                      rows: rows(
                        marksData![index],
                      ),
                    ),
                  );
                })
          ],
        ),
      ),
    );
  }

  List<TableRowConfiguration> rows(UploadSubjectMarks subjectMarks) {
    DateTime? startDate;
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    bool shouldShowAction = true;
    try {
      startDate = formatAnyDateIntoDateTime(subjectMarks.startDate ?? "");
      if (today.isBefore(startDate)) {
        shouldShowAction = false;
      }
    } catch (_) {}

    return [
      TableRowConfiguration(rowHeight: 35, cells: [
        TableCellConfiguration(
            text: "Class", padding: const EdgeInsets.only(left: 10)),
        TableCellConfiguration(
            text: subjectMarks.className,
            padding: const EdgeInsets.only(left: 10))
      ]),
      TableRowConfiguration(rowHeight: 35, cells: [
        TableCellConfiguration(
            text: "Exam", padding: const EdgeInsets.only(left: 10)),
        TableCellConfiguration(
            text: subjectMarks.exam, padding: const EdgeInsets.only(left: 10))
      ]),
      TableRowConfiguration(rowHeight: 35, cells: [
        TableCellConfiguration(
            text: "Activity", padding: const EdgeInsets.only(left: 10)),
        TableCellConfiguration(
            text: subjectMarks.activity,
            padding: const EdgeInsets.only(left: 10))
      ]),
      TableRowConfiguration(rowHeight: 35, cells: [
        TableCellConfiguration(
            text: "Sub Activity", padding: const EdgeInsets.only(left: 10)),
        TableCellConfiguration(
            text: subjectMarks.subActivity,
            padding: const EdgeInsets.only(left: 10))
      ]),
      TableRowConfiguration(rowHeight: 35, cells: [
        TableCellConfiguration(
            text: "Subject", padding: const EdgeInsets.only(left: 10)),
        TableCellConfiguration(
            text: subjectMarks.subject,
            padding: const EdgeInsets.only(left: 10))
      ]),
      TableRowConfiguration(rowHeight: 35, cells: [
        TableCellConfiguration(
            text: "Marks Type", padding: const EdgeInsets.only(left: 10)),
        TableCellConfiguration(
            text: subjectMarks.entryType?.capitalize() ?? "",
            padding: const EdgeInsets.only(left: 10))
      ]),
      TableRowConfiguration(rowHeight: 35, cells: [
        TableCellConfiguration(
            text: "Exam Date", padding: const EdgeInsets.only(left: 10)),
        TableCellConfiguration(
            text: formatAnyDateToDDMMYY(subjectMarks.examDate ?? ""),
            padding: const EdgeInsets.only(left: 10))
      ]),
      TableRowConfiguration(rowHeight: 35, cells: [
        TableCellConfiguration(
            text: "Start Date", padding: const EdgeInsets.only(left: 10)),
        TableCellConfiguration(
            text: formatAnyDateToDDMMYY(subjectMarks.startDate ?? ""),
            padding: const EdgeInsets.only(left: 10))
      ]),
      TableRowConfiguration(rowHeight: 35, cells: [
        TableCellConfiguration(
            text: "Freeze Date", padding: const EdgeInsets.only(left: 10)),
        TableCellConfiguration(
            text: formatAnyDateToDDMMYY(subjectMarks.freezeDate ?? ""),
            padding: const EdgeInsets.only(left: 10))
      ]),
      TableRowConfiguration(rowHeight: 35, cells: [
        TableCellConfiguration(
            text: "Status", padding: const EdgeInsets.only(left: 10)),
        TableCellConfiguration(
            text: subjectMarks.status?.capitalize() ?? "",
            padding: const EdgeInsets.only(left: 10))
      ]),
      if (shouldShowAction)
        TableRowConfiguration(rowHeight: 35, cells: [
          TableCellConfiguration(
              text: "Action", padding: const EdgeInsets.only(left: 10)),
          TableCellConfiguration(
            height: 40,
            onTap: (_) async {
              await navigateToScreen(
                  context,
                  UploadMarksEntryScreen(
                    subject: subjectMarks,
                    screenState: widget.screenState,
                    marksEntryEnabled:
                        !(widget.screenState == UploadMarksScreenState.expired),
                  ));
              callGetSubjectForMarksWithStatus();
              setState(() {});
            },
            child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.center,
                child: () {
                  String action;
                  if (widget.screenState == UploadMarksScreenState.expired) {
                    action = "View Marks";
                  } else if (widget.screenState ==
                      UploadMarksScreenState.marksEntered) {
                    action = "Edit Marks";
                  } else {
                    action = "Enter Marks";
                  }

                  return AppButton(
                    text: action,
                    onPressed: (_) async {
                      await navigateToScreen(
                          context,
                          UploadMarksEntryScreen(
                            subject: subjectMarks,
                            screenState: widget.screenState,
                            marksEntryEnabled: !(widget.screenState ==
                                UploadMarksScreenState.expired),
                          ));
                      callGetSubjectForMarksWithStatus();
                      setState(() {});
                    },
                    textStyle: const TextStyle(
                        fontSize: 14, color: ColorConstant.backgroundColor),
                    height: 25,
                    padding: const EdgeInsets.all(2),
                  );
                }()

                // Icon(
                //   widget.screenState == UploadMarksScreenState.expired
                //       ? CupertinoIcons.xmark
                //       : CupertinoIcons.pencil,
                //   size: 18,
                // ),
                ),
            text: "Enter Link",
            padding: const EdgeInsets.only(),
          )
        ])
    ];
  }
}
