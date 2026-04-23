import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:school_app/home_screen/model/home.dart';
import 'package:school_app/utils/app_theme.dart';

final class HomeOverview extends StatelessWidget {
  final HomeModel? homeModel;
  final List<MenuDetail> menuDetails;
  final void Function(MenuDetail detail) onNavigate;

  const HomeOverview({
    super.key,
    required this.homeModel,
    required this.menuDetails,
    required this.onNavigate,
  });

  MenuDetail? _firstMenuById(List<String> ids) {
    for (final id in ids) {
      final match = menuDetails.where((m) => (m.mobileMenuId?.trim() ?? "") == id.trim()).toList();
      if (match.isNotEmpty) return match.first;
    }
    return null;
  }

  MenuDetail _fallbackMenu(String id, String name) {
    return MenuDetail(mobileMenuId: id, menuName: name);
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final name = (homeModel?.studentName?.trim().isNotEmpty ?? false)
        ? homeModel?.studentName?.trim() ?? 'Student'
        : (homeModel?.name?.trim().isNotEmpty ?? false)
            ? homeModel?.name?.trim() ?? 'Student'
            : 'Aarav';

    final homeworkMenu = _firstMenuById(['1']) ?? _fallbackMenu('1', 'Homework');
    final noticeMenu = _firstMenuById(['2', '65']) ?? _fallbackMenu('2', 'Notice Board');
    final attendanceMenu = _firstMenuById(['12']) ?? _fallbackMenu('12', 'Attendance');
    final feeMenu = _firstMenuById(['59', '9', '804']);
    final docsMenu = _firstMenuById(['64', '810', '19']);
    final disciplineMenu = _firstMenuById(['14', '808', '15', '801']);
    final classWorkMenu = _firstMenuById(['11', '812', '10103']) ?? _fallbackMenu('11', 'Class Work');
    final reportMenu = _firstMenuById(['5', '22', '16', '805']);
    final timetableMenu = _firstMenuById(['7', '23', '50', '51']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(
          greeting: _greeting(),
          name: name,
        ),
        const SizedBox(height: 16),
        _SmartUpdateCard(
          onTap: () {
            final target = noticeMenu ?? homeworkMenu;
            if (target != null) onNavigate(target);
          },
        ),
        const SizedBox(height: 16),
        _StatsRow(
          onHomeworkTap: () => onNavigate(homeworkMenu),
          onNoticesTap: () => onNavigate(noticeMenu),
          onAttendanceTap: () => onNavigate(attendanceMenu),
        ),
        const SizedBox(height: 16),
        _DueTodayCard(
          onViewHomework: () => onNavigate(homeworkMenu),
        ),
        const SizedBox(height: 16),
        _QuickTilesGrid(
          tiles: [
            _QuickTileData(
              title: 'Class Work',
              subtitle: 'Daily Topics',
              value: 'New',
              icon: Icons.auto_stories_rounded,
              accent: const Color(0xFF0EA5E9),
              onTap: classWorkMenu == null ? null : () => onNavigate(classWorkMenu),
            ),
            _QuickTileData(
              title: 'Exam Marks',
              subtitle: 'Results',
              value: '87%',
              icon: Icons.analytics_rounded,
              accent: const Color(0xFF8B5CF6),
              onTap: reportMenu == null ? null : () => onNavigate(reportMenu),
            ),
            _QuickTileData(
              title: 'Fee Summary',
              subtitle: 'Paid',
              value: '₹12,450',
              icon: Icons.account_balance_wallet_rounded,
              accent: const Color(0xFF16A34A),
              onTap: feeMenu == null ? null : () => onNavigate(feeMenu),
            ),
            _QuickTileData(
              title: 'Documents',
              subtitle: 'View Docs',
              value: '18',
              icon: Icons.folder_copy_rounded,
              accent: const Color(0xFF6366F1),
              onTap: docsMenu == null ? null : () => onNavigate(docsMenu),
            ),
            _QuickTileData(
              title: 'Discipline',
              subtitle: 'Good Record',
              value: '230',
              icon: Icons.verified_user_rounded,
              accent: const Color(0xFFEF4444),
              onTap: disciplineMenu == null
                  ? null
                  : () => onNavigate(disciplineMenu),
            ),
            _QuickTileData(
              title: 'Communications',
              subtitle: 'Notices',
              value: '2',
              icon: Icons.campaign_rounded,
              accent: const Color(0xFFF59E0B),
              onTap: (noticeMenu ?? timetableMenu) == null
                  ? null
                  : () => onNavigate((noticeMenu ?? timetableMenu)!),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _RecentNotices(
          onViewAll: noticeMenu == null ? null : () => onNavigate(noticeMenu),
          items: [
            _NoticeItem(
              badge: 'NOTICE',
              badgeColor: const Color(0xFF16A34A),
              title: 'Annual Day Celebration',
              subtitle: 'Annual Day will be celebrated in the coming week.',
              dateText: DateFormat('d MMM yyyy').format(DateTime.now()),
            ),
            _NoticeItem(
              badge: 'ALERT',
              badgeColor: const Color(0xFFF59E0B),
              title: 'Summer Vacation',
              subtitle:
                  'School will remain closed from 1st June for Summer Break.',
              dateText: DateFormat('d MMM yyyy').format(DateTime.now().subtract(const Duration(days: 2))),
            ),
          ],
        ),
      ],
    );
  }
}

final class _Header extends StatelessWidget {
  final String greeting;
  final String name;

  const _Header({required this.greeting, required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting,',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1F2937),
                  height: 1.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF6366F1),
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('👋', style: TextStyle(fontSize: 24)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Keep going! You're doing great.",
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 100,
          width: 120,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.school_rounded,
              size: 60, color: Color(0xFF6366F1)),
        ),
      ],
    );
  }
}

final class _SmartUpdateCard extends StatelessWidget {
  final VoidCallback? onTap;

  const _SmartUpdateCard({this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F3FF), // Light purple
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Here's your smart update for today",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF4338CA),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'You have 1 homework due today and 2 new notices from school.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF6366F1),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF6366F1)),
          ],
        ),
      ),
    );
  }
}

final class _StatsRow extends StatelessWidget {
  final VoidCallback? onHomeworkTap;
  final VoidCallback? onNoticesTap;
  final VoidCallback? onAttendanceTap;

  const _StatsRow({
    required this.onHomeworkTap,
    required this.onNoticesTap,
    required this.onAttendanceTap,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.edit_note_rounded,
              value: '12',
              label: 'Homework',
              subLabel: 'Pending',
              color: const Color(0xFF6366F1),
              onTap: onHomeworkTap,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.notifications_rounded,
              value: '2',
              label: 'Notices',
              subLabel: 'New',
              color: const Color(0xFFEF4444),
              onTap: onNoticesTap,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.bar_chart_rounded,
              value: '92%',
              label: 'Attendance',
              subLabel: 'Today',
              color: const Color(0xFF10B981),
              onTap: onAttendanceTap,
            ),
          ),
        ],
      ),
    );
  }
}

final class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final String subLabel;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.subLabel,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        value,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                Container(
                  width: 4,
                  height: 4,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            Flexible(
              child: Text(
                subLabel,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withOpacity(0.10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        'View details',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.arrow_forward_rounded, size: 12, color: color),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _DueTodayCard extends StatelessWidget {
  final VoidCallback? onViewHomework;

  const _DueTodayCard({required this.onViewHomework});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED), // Light orange
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEDD5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Due Today',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF9A3412),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Mathematics Homework',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Algebra Worksheet',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Due by 11:59 PM',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: Colors.grey.shade500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 130),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEDD5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.assignment_rounded,
                      size: 40, color: Color(0xFFF97316)),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: onViewHomework,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF97316),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'View Homework',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
final class _QuickTilesGrid extends StatelessWidget {
  final List<_QuickTileData> tiles;

  const _QuickTilesGrid({required this.tiles});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3, // Wider aspect for 2 columns
      ),
      itemCount: tiles.length,
      itemBuilder: (context, i) => _QuickTileCard(data: tiles[i]),
    );
  }
}
final class _QuickTileCard extends StatelessWidget {
  final _QuickTileData data;

  const _QuickTileCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: data.onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP ROW: Main Icon + Clickable Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: data.accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(data.icon, color: data.accent, size: 20),
                ),
                // The new subtle chevron
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey.shade300, // Kept very light so it doesn't distract from the data
                  size: 20,
                ),
              ],
            ),

            // MIDDLE: Pushes everything below it to the absolute bottom
            const Spacer(), 

            // BOTTOM: Tightly grouped text hierarchy
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                data.value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                  height: 1.0, // Removes built-in Flutter text padding
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              data.title,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
                height: 1.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis, 
            ),
            const SizedBox(height: 2),
            Text(
              data.subtitle,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: data.accent,
                height: 1.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

final class _QuickTileData {
  final String title;
  final String subtitle;
  final String value;
  final IconData icon;
  final Color accent;
  final VoidCallback? onTap;

  const _QuickTileData({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
    required this.accent,
    required this.onTap,
  });
}

final class _RecentNotices extends StatelessWidget {
  final VoidCallback? onViewAll;
  final List<_NoticeItem> items;

  const _RecentNotices({
    required this.onViewAll,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              'Recent Notices',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: onViewAll,
              child: const Text('View All',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final item in items) ...[
          _NoticeRow(item: item),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

final class _NoticeItem {
  final String badge;
  final Color badgeColor;
  final String title;
  final String subtitle;
  final String dateText;

  const _NoticeItem({
    required this.badge,
    required this.badgeColor,
    required this.title,
    required this.subtitle,
    required this.dateText,
  });
}

final class _NoticeRow extends StatelessWidget {
  final _NoticeItem item;

  const _NoticeRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: item.badgeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item.badge == 'ALERT'
                  ? Icons.warning_amber_rounded
                  : Icons.notifications_rounded,
              color: item.badgeColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: item.badgeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.badge,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: item.badgeColor,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        item.dateText,
                        style: TextStyle(
                            fontSize: 10, color: Colors.grey.shade400),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  item.subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        ],
      ),
    );
  }
}
