import 'package:flutter/material.dart';
import 'package:school_app/utils/constants.dart';

class TableColumnConfiguration {
  double? width;
  double? height;
  Color? color;
  Widget? child;
  String? text;
  int? rowFlex;

  TableColumnConfiguration({
    this.width,
    this.height,
    this.color,
    this.child,
    this.text,
    this.rowFlex,
  }) : assert(text != null || child != null);
}

class TableCellConfiguration {
  Widget? child;
  double? width;
  double? height;
  String? text;
  TextStyle? textStyle;
  Function(int)? onTap;
  EdgeInsets? padding;

  TableCellConfiguration({
    this.child,
    this.width,
    this.height,
    this.text,
    this.textStyle,
    this.onTap,
    this.padding,
  });
}

class TableRowConfiguration {
  Function(int)? onTap;
  double? rowHeight;
  List<TableCellConfiguration> cells;
  final Function()? onLongRowLongPress;
  Color? backgroundColor;

  TableRowConfiguration({
    required this.cells,
    this.onTap,
    this.rowHeight,
    this.onLongRowLongPress,
    this.backgroundColor,
  });
}

final class TableWidget extends StatelessWidget {
  final List<TableRowConfiguration> rows;
  final bool showBorder;
  const TableWidget({super.key, required this.rows, this.showBorder = true});

  @override
  Widget build(BuildContext context) {
    return Table(
      border: showBorder
          ? TableBorder.all(
              color: ColorConstant.primaryColor,
            )
          : null,
      children: rows
          .map((row) => TableRow(
                children: row.cells
                    .map(
                      (cell) => InkWell(
                        onTap: () {
                          if (cell.onTap != null) {
                            cell.onTap?.call(row.cells.indexOf(cell));
                          } else {
                            row.onTap?.call(rows.indexOf(row));
                          }
                        },
                        child: Container(
                          color: row.backgroundColor ?? Colors.transparent,
                          padding: cell.padding,
                          width: cell.width,
                          height: cell.height ?? row.rowHeight,
                          child: cell.child ??
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      cell.text ?? " ",
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.left,
                                      textScaler: const TextScaler.linear(1.0),
                                      style: cell.textStyle ??
                                          const TextStyle(
                                            fontSize: 12,
                                            fontFamily: fontFamily,
                                            color: ColorConstant.inactiveColor,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                        ),
                      ),
                    )
                    .toList(),
              ))
          .toList(),
    );
  }
}

final class DataTableWidget extends StatelessWidget {
  final List<TableColumnConfiguration> headers;
  final List<TableRowConfiguration> data;
  final TableBorder? border;
  final Color? headingRowColor;

  final double? headingRowHeight;
  final double? horizontalMargin;
  final Color? dataRowColor;
  final TextStyle? dataTextStyle;
  final TextStyle? headingTextStyle;
  final bool enableHorizontalScroll;
  final double? minColumnWidth;
  final double? maxColumnWidth;

  const DataTableWidget({
    super.key,
    required this.headers,
    required this.data,
    this.border,
    this.headingRowColor,
    this.headingRowHeight,
    this.horizontalMargin,
    this.dataRowColor,
    this.dataTextStyle,
    this.headingTextStyle,
    this.enableHorizontalScroll = true,
    this.minColumnWidth,
    this.maxColumnWidth,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // --- REVISED COLUMN WIDTH CALCULATION ---

        List<double> columnWidths = [];

        // Calculate total specified width to determine if scrolling is needed and for proportional distribution.
        double totalSpecifiedWidth = 0;
        for (final header in headers) {
          totalSpecifiedWidth += header.width ??
              120.0; // Default width of 120 acts as a flex factor.
        }

        // Determine if we need horizontal scrolling.
        bool needsHorizontalScroll =
            totalSpecifiedWidth > constraints.maxWidth &&
                enableHorizontalScroll;

        if (needsHorizontalScroll) {
          // If scrolling is needed, use the specified widths, clamped.
          for (final header in headers) {
            double columnWidth = header.width ?? 120.0;
            columnWidth = columnWidth.clamp(
                minColumnWidth ?? 80.0, maxColumnWidth ?? double.infinity);
            columnWidths.add(columnWidth);
          }
        } else {
          // If not scrolling, distribute the available width proportionally.
          final availableWidth = constraints.maxWidth;
          if (totalSpecifiedWidth > 0) {
            for (final header in headers) {
              final flex = header.width ?? 120.0;
              final newWidth = (flex / totalSpecifiedWidth) * availableWidth;
              columnWidths.add(newWidth);
            }
          }
        }

        final double totalContentWidth =
            columnWidths.isNotEmpty ? columnWidths.reduce((a, b) => a + b) : 0;

        Widget tableWidget = DataTable(
          border: border ??
              TableBorder.all(
                color: Colors.blueGrey,
              ),
          clipBehavior: Clip.hardEdge,
          dataTextStyle: dataTextStyle,
          headingTextStyle: headingTextStyle,
          dataRowMaxHeight: double.infinity,
          dataRowMinHeight: 20,
          showCheckboxColumn: false,
          headingRowHeight: headingRowHeight,
          columnSpacing: 0,
          checkboxHorizontalMargin: 0,
          dataRowColor: dataRowColor != null
              ? WidgetStatePropertyAll<Color>(dataRowColor!)
              : null,
          headingRowColor: WidgetStatePropertyAll<Color>(
            headingRowColor ?? ColorConstant.primaryColor,
          ),
          horizontalMargin: horizontalMargin ?? 0,
          columns: headers.asMap().entries.map(
            (entry) {
              int index = entry.key;
              TableColumnConfiguration header = entry.value;
              return DataColumn(
                headingRowAlignment: MainAxisAlignment.center,
                label: Container(
                  alignment: Alignment.center,
                  width: columnWidths[index],
                  height: header.height,
                  child: header.child ??
                      Text(
                        header.text ?? " ",
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        textScaler: const TextScaler.linear(1.0),
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontFamily: fontFamily,
                          fontSize: 12,
                          color: ColorConstant.backgroundColor,
                        ),
                      ),
                ),
              );
            },
          ).toList(),
          rows: data
              .map(
                (row) => DataRow(
                  onLongPress: () {
                    if (row.onLongRowLongPress != null) {
                      row.onLongRowLongPress?.call();
                    }
                  },
                  cells: row.cells.asMap().entries.map(
                    (entry) {
                      int index = entry.key;
                      TableCellConfiguration cell = entry.value;
                      return DataCell(
                        // --- FIX 1: ADDED ALIGNMENT & SIMPLIFIED CHILD ---
                        Container(
                          alignment: Alignment.center,
                          width: columnWidths[index],
                          height: cell.height ?? row.rowHeight,
                          color: row.backgroundColor ?? Colors.transparent,
                          padding: cell.padding,
                          child: cell.child ??
                              Text(
                                cell.text ?? " ",
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                textScaler: const TextScaler.linear(1.0),
                                style: cell.textStyle ??
                                    const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: fontFamily,
                                    ),
                              ),
                        ),
                        onTap: () {
                          if (cell.onTap != null) {
                            cell.onTap?.call(row.cells.indexOf(cell));
                          } else {
                            row.onTap?.call(data.indexOf(row));
                          }
                        },
                        onLongPress: () {
                          if (row.onLongRowLongPress != null) {
                            row.onLongRowLongPress?.call();
                          }
                        },
                      );
                    },
                  ).toList(),
                ),
              )
              .toList(),
        );

        // Wrap with horizontal scroll if needed
        if (needsHorizontalScroll) {
          return Scrollbar(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: totalContentWidth,
                child: tableWidget,
              ),
            ),
          );
        } else {
          // If no horizontal scroll needed, the table will now fill the available space.
          return SizedBox(
            width: constraints.maxWidth,
            child: tableWidget,
          );
        }
      },
    );
  }
}
