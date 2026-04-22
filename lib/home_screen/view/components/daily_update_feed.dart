import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/home_screen/view/components/dashboard_utils.dart';
import 'package:school_app/utils/app_theme.dart';
import 'package:school_app/utils/utils.dart';

class DailyUpdateFeedWidget extends StatefulWidget {
  const DailyUpdateFeedWidget({super.key});

  @override
  State<DailyUpdateFeedWidget> createState() => _DailyUpdateFeedWidgetState();
}

class _DailyUpdateFeedWidgetState extends State<DailyUpdateFeedWidget> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildUpdateLine(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 4, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isActive ? 12 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.outlineVariant,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: DashboardUtils.futuristicDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Update',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120, // Fixed height to keep layout stable while swiping
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                // Page 1
                Column(
                  children: [
                    _buildUpdateLine(
                        'Sports day practice will commence at 3:00 PM today.'),
                    _buildUpdateLine(
                        'New study material uploaded for Mathematics Chapter 5.'),
                  ],
                ),
                // Page 2
                Column(
                  children: [
                    _buildUpdateLine(
                        'Reminder: Parent-Teacher meeting is scheduled for this Saturday.'),
                    _buildUpdateLine(
                        'Library will remain closed tomorrow for annual maintenance.'),
                  ],
                ),
                // Page 3
                Column(
                  children: [
                    _buildUpdateLine(
                        'The deadline to submit the Science project has been extended.'),
                    _buildUpdateLine(
                        'Bus Route 4 morning timings have been slightly updated.'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDot(_currentPage == 0),
              const SizedBox(width: 6),
              _buildDot(_currentPage == 1),
              const SizedBox(width: 6),
              _buildDot(_currentPage == 2),
            ],
          ),
        ],
      ),
    );
  }
}
