import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/home_screen/view/components/attendance_pie_chart.dart';
import 'package:school_app/home_screen/view/components/dashboard_utils.dart';
import 'package:school_app/utils/app_theme.dart';
import 'package:school_app/utils/utils.dart';

class MidLevelCards extends StatefulWidget {
  final List<String> informationPoints;

  const MidLevelCards({
    super.key,
    required this.informationPoints,
  });

  @override
  State<MidLevelCards> createState() => _MidLevelCardsState();
}

class _MidLevelCardsState extends State<MidLevelCards> {
  String _selectedTimeframe = 'Weekly';

  // Mock data for different timeframes
  final Map<String, Map<String, double>> _attendanceData = {
    'Weekly': {'present': 4.0, 'absent': 1.0, 'leave': 0.0},
    'Monthly': {'present': 18.0, 'absent': 2.0, 'leave': 2.0},
    'Yearly': {'present': 180.0, 'absent': 10.0, 'leave': 15.0},
  };

  @override
  Widget build(BuildContext context) {
    final data = _attendanceData[_selectedTimeframe]!;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
// Attendance Card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: DashboardUtils.futuristicDecoration(),
              child: Column(
                // Use spaceBetween to push the status/switch row to the bottom
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Attendance',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          // Removed _buildTimeframeSwitch() from here
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: TweenAnimationBuilder<double>(
                                key: ValueKey(_selectedTimeframe),
                                duration: const Duration(milliseconds: 500),
                                tween: Tween(begin: 0.0, end: 1.0),
                                builder: (context, value, _) {
                                  return AttendancePieChart(
                                    present: data['present']!,
                                    absent: data['absent']!,
                                    leave: data['leave']!,
                                    size: 60,
                                    animationValue: value,
                                    holeColor: Colors.white,
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DashboardUtils.buildLegendItem(
                                  'Present', Colors.green),
                              const SizedBox(height: 4),
                              DashboardUtils.buildLegendItem(
                                  'Absent', Colors.red),
                              const SizedBox(height: 4),
                              DashboardUtils.buildLegendItem(
                                  'Leave', Colors.orange),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // New Bottom Row containing Status and the Switch
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Status: Good',
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 14,),
                      _buildTimeframeSwitch(), // Moved here
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Information Card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: DashboardUtils.futuristicDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Information',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      ...widget.informationPoints.map((point) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _buildBulletPoint(point),
                          )),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 4),
                        ),
                        onPressed: () {},
                        child: Text('View',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeframeSwitch() {
    return PopupMenuButton<String>(
      initialValue: _selectedTimeframe,
      onSelected: (String value) {
        setState(() {
          _selectedTimeframe = value;
        });
      },
      child: SizedBox(
        width: double.infinity,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _selectedTimeframe,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down,
                  size: 16, color: AppColors.primary),
            ],
          ),
        ),
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(value: 'Weekly', child: Text('Weekly')),
        const PopupMenuItem<String>(value: 'Monthly', child: Text('Monthly')),
        const PopupMenuItem<String>(value: 'Yearly', child: Text('Yearly')),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
                fontSize: 11, color: AppColors.onSurface, height: 1.3),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
