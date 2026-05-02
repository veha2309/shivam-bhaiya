import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:school_app/attendance_screen/model/attendance_model.dart';
import 'package:school_app/attendance_screen/view_model/attendance_view_model.dart';
import 'package:school_app/home_screen/view/components/attendance_pie_chart.dart';
import 'package:school_app/utils/app_theme.dart';
import 'package:school_app/utils/components/components.dart';
import 'package:school_app/utils/utils.dart';

final class StudentAttendanceScreen extends StatelessWidget {
  static const String routeName = '/student-attendance';
  final String? title;

  const StudentAttendanceScreen({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AttendanceViewModel(),
      child: Consumer<AttendanceViewModel>(
        builder: (context, vm, child) {
          final data = vm.data;
          if (data == null) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          return Scaffold(
            backgroundColor: AppColors.surface,
            drawer: const AppDrawer(),
            body: SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 12, AppSpacing.lg, 8),
                      child: _Header(
                        title: title ?? 'Attendance',
                        onFilter: () {
                          _showToast(context, 'Filters coming soon');
                        },
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: _MonthSelector(
                        monthCursor: vm.monthCursor,
                        onPrev: vm.prevMonth,
                        onNext: vm.nextMonth,
                        onPick: () => _pickMonth(context, vm),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: _OverviewCard(
                        percent: data.attendancePercentage,
                        present: data.presentDays.toDouble(),
                        absent: data.absentDays.toDouble(),
                        leave: data.leaveDays.toDouble(),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: _LegendRow(
                        items: [
                          _LegendItem(label: 'Present', color: Color(0xFF22C55E)),
                          _LegendItem(label: 'Absent', color: Color(0xFFEF4444)),
                          _LegendItem(label: 'Leave', color: Color(0xFFF59E0B)),
                          _LegendItem(label: 'Holiday', color: Color(0xFF94A3B8)),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: _DateStripRow(
                        monthCursor: vm.monthCursor,
                        dayTypes: data.dayTypes,
                        selectedDate: vm.selectedDate,
                        onDateTap: (date) {
                          vm.setSelectedDate(date);
                          final type = data.dayTypes[date.day - 1];
                          final label = switch (type) {
                            AttendanceDayType.present => 'Present',
                            AttendanceDayType.absent => 'Absent',
                            AttendanceDayType.leave => 'Leave',
                            AttendanceDayType.holiday => 'Holiday',
                            AttendanceDayType.notApplicable => 'N/A',
                          };
                          _showToast(context, '${getDDMMYYYYInNum(date)}: $label');
                        },
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: _SummaryRow(
                        totalDays: data.totalWorkingDays,
                        present: data.presentDays,
                        absent: data.absentDays,
                        leave: data.leaveDays,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 18)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: _RecentAbsences(
                        items: data.recentAbsences,
                        onViewAll: () {
                          _showToast(context, 'View all coming soon');
                        },
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 18)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 28),
                      child: _BottomCtaCard(
                        onTap: () => _openFullCalendar(context, vm),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickMonth(BuildContext context, AttendanceViewModel vm) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: vm.monthCursor,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'Select month',
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) vm.setMonth(picked);
  }

  Future<void> _openFullCalendar(BuildContext context, AttendanceViewModel vm) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: AppRadius.xxlRadius,
                boxShadow: AppShadows.medium,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.outlineVariant.withOpacity(0.6),
                      borderRadius: AppRadius.fullRadius,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Calendar',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
                    child: _MonthGrid(
                      monthCursor: vm.monthCursor,
                      dayTypes: vm.data!.dayTypes,
                      onDayTap: (date) {
                        final type = vm.data!.dayTypes[date.day - 1];
                        final label = switch (type) {
                          AttendanceDayType.present => 'Present',
                          AttendanceDayType.absent => 'Absent',
                          AttendanceDayType.leave => 'Leave',
                          AttendanceDayType.holiday => 'Holiday',
                          AttendanceDayType.notApplicable => 'N/A',
                        };
                        Navigator.of(context).pop();
                        vm.setSelectedDate(date);
                        _showToast(context, '${getDDMMYYYYInNum(date)}: $label');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showToast(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _ToastOverlay(
        message: message,
        onDone: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }
}

final class _Header extends StatelessWidget {
  final String title;
  final VoidCallback onFilter;
  const _Header({required this.title, required this.onFilter});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Builder(
          builder: (ctx) => InkWell(
            onTap: () => Scaffold.of(ctx).openDrawer(),
            borderRadius: AppRadius.fullRadius,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
                boxShadow: AppShadows.soft,
              ),
              child: const Icon(Icons.menu_rounded, color: AppColors.onSurface),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Center(
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
          ),
        ),
        InkWell(
          onTap: onFilter,
          borderRadius: AppRadius.fullRadius,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
              boxShadow: AppShadows.soft,
            ),
            child: const Icon(Icons.filter_alt_outlined, color: AppColors.onSurface),
          ),
        ),
      ],
    );
  }
}

final class _MonthSelector extends StatelessWidget {
  final DateTime monthCursor;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onPick;

  const _MonthSelector({
    required this.monthCursor,
    required this.onPrev,
    required this.onNext,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.xlRadius,
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.35)),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          _IconPillButton(icon: Icons.chevron_left_rounded, onTap: onPrev),
          const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              onTap: onPick,
              borderRadius: AppRadius.lgRadius,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: AppRadius.lgRadius,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_month_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '${monthIntToString(monthCursor.month)} ${monthCursor.year}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.expand_more_rounded, size: 18, color: AppColors.onSurfaceVariant),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _IconPillButton(icon: Icons.chevron_right_rounded, onTap: onNext),
        ],
      ),
    );
  }
}

final class _IconPillButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconPillButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.fullRadius,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: AppRadius.fullRadius,
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.35)),
        ),
        child: Icon(icon, color: AppColors.onSurface),
      ),
    );
  }
}

final class _OverviewCard extends StatelessWidget {
  final int percent;
  final double present;
  final double absent;
  final double leave;

  const _OverviewCard({
    required this.percent,
    required this.present,
    required this.absent,
    required this.leave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.xlRadius,
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.35)),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            height: 110,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AttendancePieChart(
                  present: present,
                  absent: absent,
                  leave: leave,
                  size: 110,
                  holeColor: AppColors.surfaceContainerLowest,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$percent%',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      'Attendance',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Excellent!',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'from last month',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Great job! You have maintained excellent attendance.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    height: 1.35,
                    color: AppColors.onSurfaceVariant,
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

final class _LegendRow extends StatelessWidget {
  final List<_LegendItem> items;
  const _LegendRow({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.xlRadius,
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.35)),
      ),
      child: Wrap(
        spacing: 14,
        runSpacing: 10,
        children: items.map((i) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: i.color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              i.label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        )).toList(),
      ),
    );
  }
}

final class _LegendItem {
  final String label;
  final Color color;
  const _LegendItem({required this.label, required this.color});
}

final class _DateStripRow extends StatelessWidget {
  final DateTime monthCursor;
  final List<AttendanceDayType> dayTypes;
  final DateTime? selectedDate;
  final void Function(DateTime date) onDateTap;

  const _DateStripRow({
    required this.monthCursor,
    required this.dayTypes,
    required this.selectedDate,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(monthCursor.year, monthCursor.month + 1, 0).day;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.xlRadius,
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.35)),
        boxShadow: AppShadows.soft,
      ),
      child: SizedBox(
        height: 85,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: daysInMonth,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, i) {
            final day = i + 1;
            final date = DateTime(monthCursor.year, monthCursor.month, day);
            final isSelected = selectedDate != null && DateUtils.isSameDay(selectedDate, date);
            final weekday = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];
            final type = dayTypes[day - 1];
            final dot = switch (type) {
              AttendanceDayType.present => const Color(0xFF22C55E),
              AttendanceDayType.absent => const Color(0xFFEF4444),
              AttendanceDayType.leave => const Color(0xFFF59E0B),
              AttendanceDayType.holiday => const Color(0xFF94A3B8),
              AttendanceDayType.notApplicable => AppColors.outlineVariant,
            };

            return InkWell(
              onTap: () => onDateTap(date),
              borderRadius: AppRadius.xlRadius,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 54,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
                  borderRadius: AppRadius.xlRadius,
                  border: Border.all(
                    color: isSelected ? AppColors.primary.withOpacity(0.3) : AppColors.outlineVariant.withOpacity(0.25),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      weekday,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white.withOpacity(0.92) : AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      day.toString(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isSelected ? Colors.white : AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : dot,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

final class _SummaryRow extends StatelessWidget {
  final int totalDays;
  final int present;
  final int absent;
  final int leave;

  const _SummaryRow({
    required this.totalDays,
    required this.present,
    required this.absent,
    required this.leave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Present',
            value: present.toString(),
            icon: Icons.check_circle_rounded,
            accent: const Color(0xFF22C55E),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: 'Absent',
            value: absent.toString(),
            icon: Icons.cancel_rounded,
            accent: const Color(0xFFEF4444),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: 'Leave',
            value: leave.toString(),
            icon: Icons.event_busy_rounded,
            accent: const Color(0xFFF59E0B),
          ),
        ),
      ],
    );
  }
}

final class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.xlRadius,
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.35)),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: AppRadius.lgRadius,
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

final class _RecentAbsences extends StatelessWidget {
  final List<RecentAbsenceItem> items;
  final VoidCallback onViewAll;

  const _RecentAbsences({required this.items, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.xlRadius,
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.35)),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Recent Absences',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.onSurface,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onViewAll,
                child: Text(
                  'View All',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          for (final item in items) ...[
            _AbsenceRow(item: item),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

final class _AbsenceRow extends StatelessWidget {
  final RecentAbsenceItem item;
  const _AbsenceRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final date = item.date;
    final dayText = date.day.toString().padLeft(2, '0');
    final monthText = getMonthIntToStringShort(date.month).toUpperCase();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppRadius.xlRadius,
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: item.accent.withOpacity(0.12),
              borderRadius: AppRadius.lgRadius,
            ),
            child: Column(
              children: [
                Text(
                  dayText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: item.accent,
                  ),
                ),
                Text(
                  monthText,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: item.accent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
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

final class _BottomCtaCard extends StatelessWidget {
  final VoidCallback onTap;
  const _BottomCtaCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.xlRadius,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppGradients.tealHero,
          borderRadius: AppRadius.xlRadius,
          boxShadow: AppShadows.medium,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Consistency is the key!',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Keep it up to achieve 100% attendance.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadius.fullRadius,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_month_rounded, size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            'View Calendar',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: AppRadius.xlRadius,
                border: Border.all(color: Colors.white.withOpacity(0.25)),
              ),
              child: const Icon(Icons.auto_graph_rounded, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

final class _MonthGrid extends StatelessWidget {
  final DateTime monthCursor;
  final List<AttendanceDayType> dayTypes;
  final void Function(DateTime date) onDayTap;

  const _MonthGrid({
    required this.monthCursor,
    required this.dayTypes,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(monthCursor.year, monthCursor.month + 1, 0).day;
    final firstDay = DateTime(monthCursor.year, monthCursor.month, 1).weekday;
    final leadingPadding = (firstDay - 1) % 7;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
              .map((d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: daysInMonth + leadingPadding,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemBuilder: (context, i) {
            if (i < leadingPadding) return const SizedBox();
            final day = i - leadingPadding + 1;
            final date = DateTime(monthCursor.year, monthCursor.month, day);
            final type = dayTypes[day - 1];
            final color = switch (type) {
              AttendanceDayType.present => const Color(0xFF22C55E),
              AttendanceDayType.absent => const Color(0xFFEF4444),
              AttendanceDayType.leave => const Color(0xFFF59E0B),
              AttendanceDayType.holiday => const Color(0xFF94A3B8),
              AttendanceDayType.notApplicable => AppColors.outlineVariant,
            };

            return InkWell(
              onTap: () => onDayTap(date),
              borderRadius: AppRadius.mdRadius,
              child: Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: AppRadius.mdRadius,
                  border: Border.all(color: color.withOpacity(0.25)),
                ),
                child: Center(
                  child: Text(
                    day.toString(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

final class _ToastOverlay extends StatefulWidget {
  final String message;
  final VoidCallback onDone;
  const _ToastOverlay({required this.message, required this.onDone});

  @override
  State<_ToastOverlay> createState() => _ToastOverlayState();
}

final class _ToastOverlayState extends State<_ToastOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 180));
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));

    _c.forward();
    Future<void>.delayed(const Duration(milliseconds: 1500), () async {
      if (!mounted) return;
      await _c.reverse();
      widget.onDone();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: SlideTransition(
            position: _slide,
            child: FadeTransition(
              opacity: _fade,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.82),
                    borderRadius: AppRadius.fullRadius,
                  ),
                  child: Text(
                    widget.message,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void _showToast(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _ToastOverlay(
      message: message,
      onDone: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}
