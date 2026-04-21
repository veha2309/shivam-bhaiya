import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/utils/app_theme.dart';

class CategoryTabs extends StatelessWidget {
  const CategoryTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          const SizedBox(width: AppSpacing.lg),
          _TabItem(
            label: 'Attendance',
            icon: Icons.calendar_today_rounded,
            isSelected: true,
            onTap: () {},
          ),
          const SizedBox(width: 12),
          _TabItem(
            label: 'Discipline Concerns',
            icon: Icons.gavel_rounded,
            isSelected: false,
            onTap: () {},
          ),
          const SizedBox(width: 12),
          _TabItem(
            label: 'Homework Due',
            icon: Icons.book_rounded,
            isSelected: false,
            onTap: () {},
          ),
          const SizedBox(width: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.fullRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : Colors.white,
          borderRadius: AppRadius.fullRadius,
          border: Border.all(
            color: isSelected ? AppColors.primary.withOpacity(0.3) : AppColors.outlineVariant.withOpacity(0.3),
          ),
          boxShadow: isSelected ? null : AppShadows.soft,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
