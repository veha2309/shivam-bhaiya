import 'package:flutter/material.dart';
import 'package:school_app/utils/utils.dart';
import '../view_model/notice_board_view_model.dart';
import '../model/notice_board_model.dart';
import '../../utils/components/app_scaffold.dart';
import '../../utils/components/body.dart';
import '../../utils/components/app_future_builder.dart';

class NoticeBoardContent extends StatefulWidget {
  const NoticeBoardContent({super.key});

  @override
  State<NoticeBoardContent> createState() => _NoticeBoardContentState();
}

class _NoticeBoardContentState extends State<NoticeBoardContent> {
  late Future<List<NoticeBoardModel>> _noticesFuture;

  @override
  void initState() {
    super.initState();
    _noticesFuture = NoticeBoardViewModel.instance.getNotices();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: AppBody(
        title: 'Notice Board',
        body: AppFutureBuilder<List<NoticeBoardModel>>(
          future: _noticesFuture,
          builder: (context, snapshot) {
            final notices = snapshot.data ?? [];
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notices.length,
              itemBuilder: (context, index) {
                final notice = notices[index];
                return NoticeCard(notice: notice);
              },
            );
          },
        ),
      ),
    );
  }
}

class NoticeCard extends StatelessWidget {
  final NoticeBoardModel notice;

  const NoticeCard({
    super.key,
    required this.notice,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    notice.category ?? 'General',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  notice.date ?? "",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              notice.subject ?? "",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              notice.message ?? "",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                launchURLString(notice.attachmentUrl ?? "");
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.attachment,
                    size: 20,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'View Attachment',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
