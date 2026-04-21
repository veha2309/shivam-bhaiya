import 'package:flutter/material.dart';
import 'package:school_app/fee_history/Model/fee_history_model.dart';
import 'package:school_app/fee_history/ViewModel/fee_history_view_model.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/components/no_data_widget.dart';
import 'package:school_app/utils/components/table_widget.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/utils.dart';

class FeeHistoryScreen extends StatefulWidget {
  static const String routeName = '/fee-history';
  final String? title;
  const FeeHistoryScreen({super.key, this.title});

  @override
  State<FeeHistoryScreen> createState() => _FeeHistoryScreenState();
}

class _FeeHistoryScreenState extends State<FeeHistoryScreen> {
  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);
  Future<ApiResponse<List<FeeHistoryModel>>>? getFeeHistoryFuture;
  List<FeeHistoryModel>? feeHistory;

  @override
  void initState() {
    super.initState();
    getFeeHistoryFuture =
        FeeHistoryViewModel.instance.getFeeHistory().then((response) {
      if (response.success) {
        feeHistory = response.data;
      }
      return response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      isLoadingNotifier: isLoadingNotifier,
      body: AppBody(
        title: widget.title ?? "Fee History",
        body: AppFutureBuilder(
          future: getFeeHistoryFuture,
          builder: (context, snapshot) {
            if (feeHistory?.isEmpty ?? true) {
              return const NoDataWidget();
            }
            return studentProfileBody(context);
          },
        ),
      ),
    );
  }

  Widget studentProfileBody(BuildContext context) {
    if (feeHistory == null || feeHistory!.isEmpty) return const SizedBox();

    FeeHistoryModel data = feeHistory!.first;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        spacing: 16.0,
        children: [
          TableWidget(rows: [
            TableRowConfiguration(rowHeight: 40, cells: [
              TableCellConfiguration(
                text: "Transaction No",
                padding: const EdgeInsets.only(left: 10),
              ),
              TableCellConfiguration(
                  text: data.transactionNo ?? "-",
                  padding: const EdgeInsets.only(left: 10))
            ]),
            TableRowConfiguration(rowHeight: 40, cells: [
              TableCellConfiguration(
                  text: "Month", padding: const EdgeInsets.only(left: 10)),
              TableCellConfiguration(
                  text: data.monthName ?? "-",
                  padding: const EdgeInsets.only(left: 10))
            ]),
            TableRowConfiguration(rowHeight: 40, cells: [
              TableCellConfiguration(
                  text: "Gross Amount",
                  padding: const EdgeInsets.only(left: 10)),
              TableCellConfiguration(
                  text: data.grossAmount ?? "-",
                  padding: const EdgeInsets.only(left: 10))
            ]),
            TableRowConfiguration(rowHeight: 40, cells: [
              TableCellConfiguration(
                  text: "Net Payable",
                  padding: const EdgeInsets.only(left: 10)),
              TableCellConfiguration(
                  text: data.netPayable ?? "-",
                  padding: const EdgeInsets.only(left: 10))
            ]),
            TableRowConfiguration(rowHeight: 40, cells: [
              TableCellConfiguration(
                  text: "Paid Amount",
                  padding: const EdgeInsets.only(left: 10)),
              TableCellConfiguration(
                  text: data.paidAmount ?? "-",
                  padding: const EdgeInsets.only(left: 10))
            ]),
            TableRowConfiguration(rowHeight: 40, cells: [
              TableCellConfiguration(
                  text: "Balance", padding: const EdgeInsets.only(left: 10)),
              TableCellConfiguration(
                  text: data.balance ?? "-",
                  padding: const EdgeInsets.only(left: 10))
            ]),
            if (data.url != null) // Only show download row if URL exists
              TableRowConfiguration(rowHeight: 40, cells: [
                TableCellConfiguration(
                    text: "Receipt", padding: const EdgeInsets.only(left: 10)),
                TableCellConfiguration(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () {
                        if (data.url != null) {
                          launchURLString(data.url!);
                        }
                      },
                      child: const Row(
                        spacing: 8,
                        children: [
                          Text(
                            "View Receipt",
                            textScaler: TextScaler.linear(1.0),
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: fontFamily,
                              color: ColorConstant.primaryColor,
                              decoration: TextDecoration.underline,
                              decorationColor: ColorConstant.primaryColor,
                            ),
                          ),
                          Icon(
                            Icons.picture_as_pdf,
                            size: 18,
                            color: ColorConstant.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.only(left: 10),
                )
              ]),
          ]),
        ],
      ),
    );
  }
}
