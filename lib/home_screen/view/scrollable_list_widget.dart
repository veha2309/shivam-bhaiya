import 'package:flutter/material.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
import 'package:school_app/notifications/viewmodel/notification_viewmodel.dart';
import 'package:school_app/utils/components/app_button.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/utils.dart';
import '../model/scrollable_list_item.dart';
import 'package:flutter_html/flutter_html.dart';

class ScrollableListWidget extends StatelessWidget {
  final List<ScrollableListItem> items;
  final EdgeInsets? padding;
  final ScrollController? controller;
  final VoidCallback? onShowAllPressed;
  final VoidCallback? onCancel;
  final int? unreadNotificationsCount;

  const ScrollableListWidget({
    super.key,
    required this.items,
    this.padding,
    this.controller,
    this.onShowAllPressed,
    this.onCancel,
    this.unreadNotificationsCount,
  });

  @override
  Widget build(BuildContext context) {
    const itemHeight = 100.0; // Approximate height of each item
    const maxVisibleItems = 5;
    final hasMoreItems = items.length > maxVisibleItems;
    final visibleItems = items.take(maxVisibleItems).toList();

    // Calculate total height including padding and show all button if needed
    final totalHeight = (itemHeight * 2) +
        (padding?.vertical ?? 16.0) +
        (hasMoreItems ? 60.0 : 0.0); // 60.0 for show all button

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: ColorConstant.inactiveColor,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      height: totalHeight,
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(top: 12.0, left: 8.0),
            child: Text(
              'Daily Updates ${unreadNotificationsCount == 0 ? "" : "($unreadNotificationsCount)"}',
              textScaler: const TextScaler.linear(1.0),
              textAlign: TextAlign.left,
              style: const TextStyle(
                  fontSize: 18,
                  color: ColorConstant.inactiveColor,
                  fontFamily: fontFamily,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: controller,
              child: Padding(
                padding: padding ?? const EdgeInsets.all(8.0),
                child: Column(
                  children: visibleItems
                      .map((item) => _buildListItem(context, item))
                      .toList(),
                ),
              ),
            ),
          ),
          if (hasMoreItems)
            Padding(
              padding:
                  const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
              child: AppButton(
                onPressed: (_) => onShowAllPressed?.call(),
                text: 'View All Notifications',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildListItem(BuildContext context, ScrollableListItem item) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(item.text ?? ""),
            content: SingleChildScrollView(
              child: Html(
                data: item.subtext,
                style: {
                  "*": Style(fontSize: FontSize(16)),
                },
                extensions: const [
                  TableHtmlExtension(),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  onCancel?.call();
                  Navigator.pop(context);
                },
                child: const Text("Close"),
              ),
            ],
          ),
        );

        item.status = "READ";

        NotificationViewModel.instance.updateReadNotificationStatus(
          messageId: item.messageId ?? "",
          sendDate: item.date == null ? "" : getDDMMYYYYInNum(item.date!),
        );
      },
      child: Container(
        decoration: const BoxDecoration(
          color: ColorConstant.onPrimary,
          border: Border(
            bottom: BorderSide(
              width: 1,
              color: ColorConstant.inactiveColor,
            ),
          ),
        ),
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 50,
                width: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: item.status?.toUpperCase() == "READ"
                      ? ColorConstant.inactiveColor.withOpacity(0.5)
                      : ColorConstant.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  "VS",
                  textScaler: TextScaler.linear(1.0),
                  style: TextStyle(
                      fontSize: 18,
                      color: ColorConstant.onPrimary,
                      fontFamily: fontFamily,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FittedBox(
                          fit: BoxFit.contain,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            item.text ?? "",
                            maxLines: 2,
                            textScaler: const TextScaler.linear(1.0),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                              color: item.status?.toUpperCase() == "READ"
                                  ? ColorConstant.inactiveColor.withOpacity(0.5)
                                  : ColorConstant.primaryColor,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${item.date?.day}/${item.date?.month}/${item.date?.year}',
                              textScaler: const TextScaler.linear(1.0),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 12),
                            ),
                            const SizedBox(width: 16),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Html(
                      data: item.subtext,
                      style: {
                        "*": Style(fontSize: FontSize(16)),
                      },
                      extensions: const [
                        TableHtmlExtension(),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
