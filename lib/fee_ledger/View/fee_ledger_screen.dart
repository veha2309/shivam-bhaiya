import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/components/table_widget.dart';
import 'package:school_app/utils/constants.dart';

class FeeLedgerScreen extends StatefulWidget {
  static const String routeName = '/fee-ledger';
  final String? title;
  const FeeLedgerScreen({super.key, this.title});

  @override
  State<FeeLedgerScreen> createState() => _FeeLedgerScreenState();
}

class _FeeLedgerScreenState extends State<FeeLedgerScreen> {
  int day = 1;
  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      isLoadingNotifier: isLoadingNotifier,
      body: AppBody(
        title: widget.title ?? "Fee Ledger",
        body: feeLedgerBody(context),
      ),
    );
  }

  Widget feeLedgerBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        spacing: 16.0,
        children: [
          SizedBox(
            width: double.infinity,
            child: DataTableWidget(
              headingRowHeight: 45,
              headingTextStyle: const TextStyle(
                fontFamily: fontFamily,
                fontWeight: FontWeight.w300,
                fontSize: 12,
              ),
              headingRowColor: ColorConstant.primaryColor,
              dataTextStyle: const TextStyle(
                fontFamily: fontFamily,
                fontSize: 12,
              ),
              headers: [
                TableColumnConfiguration(text: "Unpaid (Months)", width: 100),
                TableColumnConfiguration(text: "Status", width: 100),
                TableColumnConfiguration(text: "Action", width: 100),
              ],
              data: data.map((row) {
                return TableRowConfiguration(
                  rowHeight: 45,
                  cells: row
                      .map((cell) => TableCellConfiguration(text: cell))
                      .toList(),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  List<List<String>> data = [
    ["Quater 1", "Unpaid", "Pay"],
    ["Quater 2", "Unpaid", "Pay"],
    ["Quater 3", "Unpaid", "Pay"],
    ["Quater 4", "Unpaid", "Pay"],
  ];
}
