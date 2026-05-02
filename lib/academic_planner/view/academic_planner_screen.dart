import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/home_screen/view/components/dashboard_utils.dart';
import 'package:school_app/home_screen/view/components/hud_background.dart';
import 'package:school_app/utils/app_theme.dart';
import 'package:school_app/utils/components/app_scaffold.dart';

class AcademicPlannerScreen extends StatefulWidget {
  static const String routeName = '/academic-planner';
  final bool isInsideParent;
  const AcademicPlannerScreen({super.key, this.isInsideParent = false});

  @override
  State<AcademicPlannerScreen> createState() => _AcademicPlannerScreenState();
}

class _AcademicPlannerScreenState extends State<AcademicPlannerScreen> {
  String selectedClass = 'Grade 8';
  final List<String> classes = ['Grade 6', 'Grade 7', 'Grade 8', 'Grade 9', 'Grade 10', 'Grade 11', 'Grade 12'];

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        _buildHeader(),
        _buildClassSelector(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCalendarSection(),
                const SizedBox(height: 24),
                _buildUpcomingEventsHeader(),
                const SizedBox(height: 16),
                _buildEventsList(),
              ],
            ),
          ),
        ),
      ],
    );

    if (widget.isInsideParent) return content;

    return AppScaffold(
      showAppBar: false,
      body: SophisticatedHUDBackground(
        child: content,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Builder(
            builder: (innerContext) => IconButton(
              onPressed: () => Scaffold.of(innerContext).openDrawer(),
              icon: const Icon(Icons.menu_rounded, color: AppColors.darkTeal),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.darkTeal,
              ),
            ),
          ),
          Text(
            'Academic Planner',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.darkTeal,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
            child: const Icon(Icons.filter_list_rounded, color: AppColors.darkTeal),
          ),
        ],
      ),
    );
  }

  Widget _buildClassSelector() {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: classes.length,
        itemBuilder: (context, index) {
          final isSelected = selectedClass == classes[index];
          return GestureDetector(
            onTap: () => setState(() => selectedClass = classes[index]),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.darkTeal : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? AppColors.darkTeal : AppColors.outlineVariant),
              ),
              alignment: Alignment.center,
              child: Text(
                classes[index],
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: DashboardUtils.futuristicDecoration(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('May 2024', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16)),
              Row(
                children: [
                  const Icon(Icons.chevron_left_rounded, size: 20),
                  const SizedBox(width: 16),
                  const Icon(Icons.chevron_right_rounded, size: 20),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: days.map((d) => Text(d, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.outline))).toList(),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 10, crossAxisSpacing: 10),
          itemCount: 31,
          itemBuilder: (context, index) {
            final day = index + 1;
            final hasEvent = day == 15 || day == 22 || day == 25;
            return Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: hasEvent ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                shape: BoxShape.circle,
                border: hasEvent ? Border.all(color: AppColors.primary.withOpacity(0.5)) : null,
              ),
              child: Text(
                '$day',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: hasEvent ? FontWeight.w800 : FontWeight.w500,
                  color: hasEvent ? AppColors.primary : AppColors.onSurface,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildUpcomingEventsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Upcoming Events', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16)),
        Text('View Full', style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildEventsList() {
    return Column(
      children: [
        _buildEventTile('Parent Teacher Meeting', '15 May 2024', '09:00 AM', Colors.indigo, Icons.groups_rounded),
        _buildEventTile('Unit Test II Starts', '22 May 2024', '08:30 AM', Colors.red, Icons.assignment_rounded),
        _buildEventTile('Summer Fest 2024', '25 May 2024', '10:00 AM', Colors.amber, Icons.celebration_rounded),
        _buildEventTile('Holiday - Buddha Purnima', '23 May 2024', 'All Day', Colors.green, Icons.hotel_rounded),
      ],
    );
  }

  Widget _buildEventTile(String title, String date, String time, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: DashboardUtils.futuristicDecoration(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.outline),
                    const SizedBox(width: 6),
                    Text(date, style: GoogleFonts.inter(fontSize: 11, color: AppColors.outline)),
                    const SizedBox(width: 12),
                    const Icon(Icons.access_time_rounded, size: 12, color: AppColors.outline),
                    const SizedBox(width: 6),
                    Text(time, style: GoogleFonts.inter(fontSize: 11, color: AppColors.outline)),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.outline),
        ],
      ),
    );
  }
}
