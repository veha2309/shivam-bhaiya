import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/home_screen/view/components/dashboard_utils.dart';
import 'package:school_app/home_screen/view/components/hud_background.dart';
import 'package:school_app/utils/app_theme.dart';
import 'package:school_app/utils/components/app_scaffold.dart';

class InboxScreen extends StatelessWidget {
  static const String routeName = '/inbox-records';
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showAppBar: true,
      appBarTitle: Text("My Inbox", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16)),
      body: SophisticatedHUDBackground(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 8,
          itemBuilder: (context, index) {
            return _buildMessageTile(index);
          },
        ),
      ),
    );
  }

  Widget _buildMessageTile(int index) {
    final titles = [
      'Science Exhibition Update',
      'Parent-Teacher Meeting',
      'Sports Day Schedule',
      'Holiday Homework',
      'Monthly Fee Receipt',
      'Library Book Overdue',
      'New Club Formation',
      'Exam Time Table'
    ];
    final senders = [
      'Ms. Priya (Class Teacher)',
      'School Admin',
      'Mr. David (Sports Dept)',
      'Mrs. Sharma (Science)',
      'Accounts Dept',
      'Librarian',
      'Principal Office',
      'Examination Cell'
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: DashboardUtils.futuristicDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mail_outline_rounded, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        titles[index % titles.length],
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${index + 1}h ago',
                      style: GoogleFonts.inter(fontSize: 10, color: AppColors.outline),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  senders[index % senders.length],
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Dear student, please find the attached documents for the upcoming event. Make sure to review them by tomorrow.',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
