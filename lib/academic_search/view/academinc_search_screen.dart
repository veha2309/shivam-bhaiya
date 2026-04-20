import 'package:flutter/material.dart';
import 'package:school_app/utils/components/app_button.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/app_textfield.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/components/table_widget.dart';
import 'package:school_app/utils/constants.dart';

class AcademicSearchScreen extends StatefulWidget {
  static const String routeName = '/academic-search';
  const AcademicSearchScreen({super.key});

  @override
  State<AcademicSearchScreen> createState() => _AcademicSearchScreenState();
}

class _AcademicSearchScreenState extends State<AcademicSearchScreen> {
  late ValueNotifier<bool> isLoadingNotifier;

  @override
  void initState() {
    super.initState();
    isLoadingNotifier = ValueNotifier(false);
  }

  @override
  void didUpdateWidget(AcademicSearchScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    isLoadingNotifier = ValueNotifier(false);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      isLoadingNotifier: isLoadingNotifier,
      body: AppBody(
        title: "Academic Search",
        body: getAcademicSearchScreenBody(context),
      ),
    );
  }

  Widget getAcademicSearchScreenBody(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 16,
          children: [
            AppTextfield(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Container(),
                );
              },
              hintText: "Select Class",
            ),
            AppTextfield(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Container(),
                );
              },
              enabled: false,
              hintText: "Select Section",
            ),
            const Text(
              "OR",
              textScaler: TextScaler.linear(1.0),
              style: TextStyle(
                fontSize: 16,
                fontFamily: fontFamily,
                color: ColorConstant.inactiveColor,
              ),
            ),
            AppTextfield(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Container(),
                );
              },
              enabled: false,
              hintText: "Select Class",
            ),
            AppButton(
              onPressed: (_) {},
              text: "Search",
            ),
            SizedBox(
              child: DataTableWidget(
                headers: [
                  TableColumnConfiguration(text: "Class", width: 40),
                  TableColumnConfiguration(text: "Name", width: 170),
                  TableColumnConfiguration(text: "Action", width: 100)
                ],
                data: [
                  TableRowConfiguration(
                    rowHeight: 30,
                    cells: [
                      TableCellConfiguration(text: "I", width: 40),
                      TableCellConfiguration(text: "Abhishek Tyagi"),
                      TableCellConfiguration(
                          child: const Align(
                        alignment: Alignment.center,
                        child: Text(
                          "View",
                          textAlign: TextAlign.center,
                          textScaler: TextScaler.linear(1.0),
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: fontFamily,
                          ),
                        ),
                      ))
                    ],
                  ),
                  TableRowConfiguration(
                    rowHeight: 30,
                    cells: [
                      TableCellConfiguration(text: "I", width: 40),
                      TableCellConfiguration(text: "Abhishek Tyagi"),
                      TableCellConfiguration(
                        child: const Align(
                          alignment: Alignment.center,
                          child: Text(
                            "View",
                            textScaler: TextScaler.linear(1.0),
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: fontFamily,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  TableRowConfiguration(
                    rowHeight: 30,
                    cells: [
                      TableCellConfiguration(text: "I", width: 40),
                      TableCellConfiguration(text: "Abhishek Tyagi"),
                      TableCellConfiguration(
                        child: const Align(
                          alignment: Alignment.center,
                          child: Text(
                            "View",
                          ),
                        ),
                      )
                    ],
                  ),
                  TableRowConfiguration(
                    rowHeight: 30,
                    cells: [
                      TableCellConfiguration(text: "I", width: 40),
                      TableCellConfiguration(text: "Abhishek Tyagi"),
                      TableCellConfiguration(
                        child: const Align(
                          alignment: Alignment.center,
                          child: Text("View"),
                        ),
                      )
                    ],
                  ),
                  TableRowConfiguration(
                    rowHeight: 30,
                    cells: [
                      TableCellConfiguration(text: "I", width: 40),
                      TableCellConfiguration(text: "Abhishek Tyagi"),
                      TableCellConfiguration(
                        child: const Align(
                          alignment: Alignment.center,
                          child: Text("View"),
                        ),
                      )
                    ],
                  ),
                  TableRowConfiguration(
                    rowHeight: 30,
                    cells: [
                      TableCellConfiguration(text: "I", width: 40),
                      TableCellConfiguration(text: "Abhishek Tyagi"),
                      TableCellConfiguration(
                        child: const Align(
                          alignment: Alignment.center,
                          child: Text("View"),
                        ),
                      )
                    ],
                  ),
                  TableRowConfiguration(
                    rowHeight: 30,
                    cells: [
                      TableCellConfiguration(text: "I", width: 40),
                      TableCellConfiguration(text: "Abhishek Tyagi"),
                      TableCellConfiguration(
                        child: const Align(
                          alignment: Alignment.center,
                          child: Text("View"),
                        ),
                      )
                    ],
                  ),
                  TableRowConfiguration(
                    rowHeight: 30,
                    cells: [
                      TableCellConfiguration(text: "I", width: 40),
                      TableCellConfiguration(text: "Abhishek Tyagi"),
                      TableCellConfiguration(
                        child: const Align(
                          alignment: Alignment.center,
                          child: Text("View"),
                        ),
                      )
                    ],
                  ),
                ],
                headingRowHeight: 35,
                headingTextStyle:
                    const TextStyle(fontWeight: FontWeight.w300, fontSize: 12),
                headingRowColor: ColorConstant.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
