import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:school_app/homework_screen/model/homework_model.dart';
import 'package:school_app/homework_screen/view_model/homework_view_model.dart';
import 'package:school_app/utils/app_theme.dart';
import 'package:school_app/utils/utils.dart';

class HomeWorkScreen extends StatelessWidget {
  const HomeWorkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeworkViewModel(),
      child: Consumer<HomeworkViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: AppColors.surface,
            body: SafeArea(
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        _buildAppBar(context),
                        _buildFilterTabs(vm),
                        _buildStatsRow(vm),
                        _buildHomeworkHeader(),
                        _buildHomeworkList(vm),
                        _buildBottomCta(),
                        const SliverToBoxAdapter(child: SizedBox(height: 100)),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 12),
        child: Row(
          children: [
            _IconButton(
              icon: Icons.chevron_left_rounded,
              onTap: () => Navigator.pop(context),
            ),
            Expanded(
              child: Text(
                'Homework',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
                image: const DecorationImage(
                  image: NetworkImage('https://i.pravatar.cc/150?u=student_hw'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs(HomeworkViewModel vm) {
    final filters = [
      {'label': 'All', 'value': HomeworkFilter.all},
      {'label': 'Pending', 'value': HomeworkFilter.pending},
      {'label': 'Submitted', 'value': HomeworkFilter.submitted},
      {'label': 'Overdue', 'value': HomeworkFilter.overdue},
    ];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 40,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  scrollDirection: Axis.horizontal,
                  itemCount: filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final f = filters[i];
                    final isSelected = vm.currentFilter == f['value'];
                    return InkWell(
                      onTap: () => vm.setFilter(f['value'] as HomeworkFilter),
                      borderRadius: AppRadius.fullRadius,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.darkTeal : Colors.transparent,
                          borderRadius: AppRadius.fullRadius,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          f['label'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.lg),
              child: _IconButton(icon: Icons.tune_rounded, size: 40, iconSize: 20, onTap: () {}),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(HomeworkViewModel vm) {
    return SliverToBoxAdapter(
      child: Container(
        height: 115,
        margin: const EdgeInsets.fromLTRB(AppSpacing.lg, 16, AppSpacing.lg, 0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.xlRadius,
                  boxShadow: AppShadows.soft,
                  border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Total Homework',
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${vm.totalCount}',
                      style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 10, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text('Tasks', style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            _buildSmallStatCard('Submitted', vm.submittedCount, const Color(0xFF0EA5E9), Icons.fact_check_rounded),
            const SizedBox(width: 8),
            _buildSmallStatCard('Pending', vm.pendingCount, const Color(0xFFF59E0B), Icons.schedule_rounded),
            const SizedBox(width: 8),
            _buildSmallStatCard('Overdue', vm.overdueCount, const Color(0xFFEF4444), Icons.error_outline_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallStatCard(String label, int count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: AppRadius.xlRadius,
          border: Border.all(color: color.withOpacity(0.12)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w900, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeworkHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 24, AppSpacing.lg, 12),
        child: Text(
          'Homework List',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildHomeworkList(HomeworkViewModel vm) {
    if (vm.filteredHomework.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: Text('No homework found')),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) => _HomeworkCard(data: vm.filteredHomework[i]),
          childCount: vm.filteredHomework.length,
        ),
      ),
    );
  }

  Widget _buildBottomCta() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.lg),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF007A82), Color(0xFF0EA5E9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppRadius.xlRadius,
          boxShadow: AppShadows.medium,
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 60,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://img.freepik.com/free-vector/student-studying-laptop_23-2148181347.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stay on Track!',
                    style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Complete your pending homework to keep your performance strong.',
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withOpacity(0.9)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: AppRadius.fullRadius),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_rounded, color: Color(0xFF007A82), size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'View Calendar',
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF007A82)),
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

class _HomeworkCard extends StatelessWidget {
  final HomeworkData data;
  const _HomeworkCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final bool isSubmitted = data.checkStatus?.toLowerCase() == 'y';
    bool isOverdue = false;
    if (!isSubmitted && data.dueDate != null) {
      try {
        final dueDate = formatAnyDateIntoDateTime(data.dueDate!);
        isOverdue = dueDate.isBefore(DateTime.now());
      } catch (_) {}
    }

    final statusLabel = isSubmitted ? 'Submitted' : (isOverdue ? 'Overdue' : 'Pending');
    final color = isSubmitted ? const Color(0xFF0EA5E9) : (isOverdue ? const Color(0xFFEF4444) : const Color(0xFFF59E0B));
    final icon = _getIconForSubject(data.subject ?? "");

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.xlRadius,
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: AppRadius.lgRadius),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${data.subject ?? "General"} Assignment',
                  style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.onSurface),
                ),
                const SizedBox(height: 4),
                Text(
                  data.homework ?? 'General Homework',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_month_rounded, size: 12, color: color),
                    const SizedBox(width: 4),
                    Text(
                      'Due: ${data.dueDate ?? "N/A"}',
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: color),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: AppRadius.fullRadius),
                child: Text(
                  statusLabel,
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: color),
                ),
              ),
              const SizedBox(height: 12),
              const Icon(Icons.chevron_right_rounded, color: AppColors.outlineVariant),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getIconForSubject(String subject) {
    subject = subject.toLowerCase();
    if (subject.contains('math')) return Icons.calculate_rounded;
    if (subject.contains('science')) return Icons.science_rounded;
    if (subject.contains('english')) return Icons.edit_note_rounded;
    if (subject.contains('social')) return Icons.public_rounded;
    if (subject.contains('hindi')) return Icons.language_rounded;
    return Icons.menu_book_rounded;
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double iconSize;

  const _IconButton({
    required this.icon,
    required this.onTap,
    this.size = 44,
    this.iconSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.fullRadius,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4)),
          boxShadow: AppShadows.soft,
        ),
        child: Icon(icon, color: AppColors.onSurface, size: iconSize),
      ),
    );
  }
}
