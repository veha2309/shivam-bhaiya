import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/utils/app_theme.dart';

class CalendarStrip extends StatefulWidget {
  final DateTime? selectedDate;
  final Function(DateTime)? onDateSelected;

  const CalendarStrip({
    super.key,
    this.selectedDate,
    this.onDateSelected,
  });

  @override
  State<CalendarStrip> createState() => _CalendarStripState();
}

class _CalendarStripState extends State<CalendarStrip> {
  late DateTime _selectedDate;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? DateTime.now();
    // Start with the current date centered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToDate(_selectedDate);
    });
  }

  void _scrollToDate(DateTime date) {
    // Basic implementation: find the index and scroll to it
    // For a strip of 30 days around current date
  }

  @override
  Widget build(BuildContext context) {
    // Generate dates for the current month
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final dates = List.generate(daysInMonth, (index) => DateTime(now.year, now.month, index + 1));

    return SizedBox(
      height: 80,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = DateUtils.isSameDay(date, _selectedDate);
          final isToday = DateUtils.isSameDay(date, DateTime.now());

          return _CalendarItem(
            date: date,
            isSelected: isSelected,
            isToday: isToday,
            onTap: () {
              setState(() => _selectedDate = date);
              if (widget.onDateSelected != null) {
                widget.onDateSelected!(date);
              }
            },
          );
        },
      ),
    );
  }
}

class _CalendarItem extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  const _CalendarItem({
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdRadius,
        child: Column(
          children: [
            Text(
              days[date.weekday - 1],
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : (isToday ? AppColors.primaryContainer.withOpacity(0.3) : Colors.transparent),
                shape: BoxShape.circle,
                border: isToday && !isSelected 
                    ? Border.all(color: AppColors.primary.withOpacity(0.5), width: 1.5)
                    : null,
                boxShadow: isSelected ? AppShadows.soft : null,
              ),
              child: Center(
                child: Text(
                  date.day.toString(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppColors.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
