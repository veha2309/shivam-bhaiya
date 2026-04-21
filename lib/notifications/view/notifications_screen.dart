import 'package:flutter/material.dart';
import 'package:school_app/notifications/model/school_message.dart';
import 'package:school_app/notifications/viewmodel/notification_viewmodel.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/components/no_data_widget.dart';
import 'package:school_app/utils/components/read_more_popup.dart';
import 'package:school_app/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationsScreen extends StatefulWidget {
  static const String routeName = '/notifications';
  final String? title;
  const NotificationsScreen({super.key, this.title});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();
  List<NotificationModel> notifications = [];
  int page = 1;
  bool isLoading = false; // Prevents duplicate calls
  bool hasMore = true; // Tracks if more data is available

  @override
  void initState() {
    super.initState();
    _fetchNotifications(); // Load initial data

    _scrollController.addListener(_onScroll); // Listen for scroll
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void refresh() {
    setState(() {
      notifications.clear();
      hasMore = true;
      page = 1;
    });
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    final response =
        await NotificationViewModel.instance.getNotifications(page);

    if (response.success) {
      setState(() {
        final newNotifications = response.data ?? [];
        if (newNotifications.isEmpty) {
          hasMore = false; // No more data
        } else {
          notifications.addAll(newNotifications);
          page++; // Move to the next page
        }
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent -
                200 && // Trigger near bottom
        !isLoading) {
      _fetchNotifications();
    }
  }

  void _openAttachment(String url) async {
    if (url.isNotEmpty) {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint("Could not launch $url");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: AppBody(
        title: widget.title ?? "Notifications",
        body: notifications.isEmpty && !isLoading
            ? const Center(
                child: NoDataWidget(),
              ) // Show NoDataWidget if no notifications
            : ListView.builder(
                controller: _scrollController,
                itemCount: notifications.length + (isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == notifications.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final notification = notifications[index];
                  return InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(notification.messageHead ?? ""),
                          content: SingleChildScrollView(
                            child: Text(notification.messageText ?? "",
                                style: const TextStyle(fontSize: 16)),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                refresh();
                              },
                              child: const Text("Close"),
                            ),
                          ],
                        ),
                      );
                      NotificationViewModel.instance
                          .updateReadNotificationStatus(
                              messageId: notification.messageId ?? "",
                              sendDate: (notification.messageDate ?? "")
                                  .replaceAll('/', '-'));
                    },
                    child: Card(
                      elevation: 4,
                      color: ColorConstant.backgroundColor,
                      clipBehavior: Clip.hardEdge,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  notification.messageHead ?? "-",
                                  textScaler: const TextScaler.linear(1.0),
                                  maxLines: 2,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 16,
                                    color: notification.status?.toUpperCase() ==
                                            "READ"
                                        ? ColorConstant.inactiveColor
                                            .withOpacity(0.5)
                                        : ColorConstant.primaryColor,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Text(
                                    notification.messageDate ?? "-",
                                    textScaler: const TextScaler.linear(1.0),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: ReadMorePopupText(
                                heading: notification.messageHead ?? "-",
                                text: notification.messageText ?? "",
                              ),
                              onTap: () => _openAttachment(
                                  notification.attachmentPath ?? "-"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
