import 'package:flutter/material.dart';
import 'package:school_app/homework_screen/model/pendingTest_model.dart';
import 'package:school_app/utils/components/table_widget.dart';
import 'package:school_app/utils/constants.dart';

class AddHomeworkTestTable extends StatefulWidget {
  final List<PendingtestModel> pendingTestModels;

  const AddHomeworkTestTable({
    super.key,
    required this.pendingTestModels,
  });

  @override
  State<AddHomeworkTestTable> createState() => _AddHomeworkTestTableState();
}

class _AddHomeworkTestTableState extends State<AddHomeworkTestTable> {
  @override
  Widget build(BuildContext context) {
    return DataTableWidget(
      headers: [
        TableColumnConfiguration(
          text: 'S.No',
          width: 30,
        ),
        TableColumnConfiguration(
          text: 'Subject Name',
          width: 150,
        ),
        TableColumnConfiguration(
          text: 'Test Date',
          width: 120,
        ),
        TableColumnConfiguration(
          text: 'Select',
          width: 80,
        ),
      ],
      data: widget.pendingTestModels.asMap().entries.map((entry) {
        final index = entry.key;
        final test = entry.value;
        return TableRowConfiguration(
          cells: [
            TableCellConfiguration(
              text: '${index + 1}',
              textStyle: const TextStyle(
                fontSize: 14,
                color: ColorConstant.secondaryTextColor,
                fontFamily: fontFamily,
              ),
            ),
            TableCellConfiguration(
              text: test.subjectName,
              textStyle: const TextStyle(
                fontSize: 14,
                color: ColorConstant.secondaryTextColor,
                fontFamily: fontFamily,
              ),
            ),
            TableCellConfiguration(
              text: test.testDate,
              textStyle: const TextStyle(
                fontSize: 14,
                color: ColorConstant.secondaryTextColor,
                fontFamily: fontFamily,
              ),
            ),
            TableCellConfiguration(
              child: Checkbox(
                value: test.isSelected ?? false,
                onChanged: (bool? value) {
                  setState(() {
                    test.isSelected = !test.isSelected;
                  });
                },
                activeColor: ColorConstant.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        );
      }).toList(),
      headingRowColor: ColorConstant.primaryColor,
      dataRowColor: Colors.white,
      headingTextStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: ColorConstant.primaryTextColor,
        fontFamily: fontFamily,
      ),
      dataTextStyle: const TextStyle(
        fontSize: 14,
        color: ColorConstant.secondaryTextColor,
        fontFamily: fontFamily,
      ),
    );
  }
}
