import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:school_app/home_screen/model/scrollable_list_item.dart';
import 'package:school_app/home_screen/view/scrollable_list_widget.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/notifications/model/school_message.dart';
import 'package:school_app/notifications/view/notifications_screen.dart';
import 'package:school_app/notifications/viewmodel/notification_viewmodel.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/constants.dart';

class NotificationListWidget extends StatefulWidget {
  const NotificationListWidget({super.key});

  @override
  State<NotificationListWidget> createState() => _NotificationListWidgetState();
}

class _NotificationListWidgetState extends State<NotificationListWidget> {
  Future<ApiResponse<List<NotificationModel>>>? _notificationsFuture;
  List<NotificationModel> _notifications = [];
  bool shouldShowNotifications = true;
  int _unreadTodayCount = -1;

  @override
  void initState() {
    super.initState();

    _loadNotifications();
  }

  void _loadNotifications() {
    _notificationsFuture =
        NotificationViewModel.instance.getNotifications(1).then((response) {
      if (response.success) {
        setState(() {
          _notifications = response.data ?? [];

          // Get today's date in the same format as messageDate
          String today = "${DateTime.now().day.toString().padLeft(2, '0')}-"
              "${DateTime.now().month.toString().padLeft(2, '0')}-"
              "${DateTime.now().year}";

          // Count unread notifications for today
          int unreadTodayCount = _notifications
              .where((n) =>
                  (n.status == "UNREAD") &&
                  ((n.messageDate ?? "").replaceAll('/', '-') == today))
              .length;

          // Store in a variable (make sure to declare it in your class)
          _unreadTodayCount = unreadTodayCount;

          if (_unreadTodayCount <= 0) {
            shouldShowNotifications = false;
          }
        });
        if (_notifications.isNotEmpty) {
          NotificationViewModel.instance.markNotificationsAsShownForToday();
        }
      }
      return response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppFutureBuilder(
      future: _notificationsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image:
                    const AssetImage(ImageConstants.yellowSquareBoxImagePath),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.blue[400]!.withOpacity(0.9),
                  //Color(0x003a567d),
                  BlendMode.colorBurn,
                ),
              ),
              borderRadius: BorderRadius.circular(12.0),
            ),
            height: 150,
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          );
        }

        if (_notifications.isEmpty) {
          return const SizedBox();
        }

        // Convert NotificationModel to ScrollableListItem
        final items = _notifications.map((notification) {
          // Parse date and time
          DateTime dateTime = DateTime.now();
          String timeStr = '';

          if (notification.messageDate != null &&
              notification.messageDate!.isNotEmpty) {
            try {
              // Try to parse the date string
              dateTime =
                  DateFormat('dd/MM/yyyy').parse(notification.messageDate!);
            } catch (e) {
              // If parsing fails, use current date and empty time
              debugPrint('Error parsing date: $e');
            }
          }

          return ScrollableListItem(
            text: notification.messageHead ?? 'Notification',
            subtext: notification.messageText ?? '',
            imageUrl: notification.attachmentPath ?? '',
            date: dateTime,
            time: timeStr,
            status: notification.status,
            messageId: notification.messageId ?? "",
          );
        }).toList();

        return ScrollableListWidget(
          unreadNotificationsCount: _unreadTodayCount,
          onCancel: () {
            refresh();
          },
          onShowAllPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationsScreen(),
              ),
            );
            refresh();
          },
          items: items,
        );
      },
    );
  }

  void refresh() {
    setState(() {
      _notifications.clear();
      _loadNotifications();
    });
  }
}
