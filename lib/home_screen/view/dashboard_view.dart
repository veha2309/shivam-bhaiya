import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_app/home_screen/view_model/dashboard_viewmodel.dart';
import 'package:school_app/home_screen/view/components/transport_tracker.dart';
import 'package:school_app/home_screen/view/components/student_overview_card.dart';
import 'package:school_app/home_screen/view/components/mid_level_cards.dart';
import 'package:school_app/home_screen/view/components/fee_details_card.dart';
import 'package:school_app/home_screen/view/components/daily_update_feed.dart';
import 'package:school_app/home_screen/view/components/quick_info_tile.dart';
import 'package:school_app/utils/app_theme.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();

    return Column(
      children: [
        // 1. Student Overview Card
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: StudentOverviewCard(
            name: 'Krish',
            className: 'XII-A',
            status: 'Present',
            avatarUrl: 'https://i.pravatar.cc/150?u=krish',
          ),
        ),
        const SizedBox(height: 20),

        // 2. Transport Tracker
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: RepaintBoundary(
            child: TransportTrackerWidget(
              hasPermission: vm.hasLocationPermission,
              checkingPermission: vm.checkingLocationPermission,
              onRequestPermission: vm.requestLocationPermission,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // 3. Attendance & Information
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: MidLevelCards(
            informationPoints: const [
              'Science Fair registration open.',
              'Holiday on 25th April.',
              'Uniform check tomorrow.'
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 4. Fee Details Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: FeeDetailsCard(
            amountDue: '₹ 2,500',
            onPay: () {},
            onDetail: () {},
          ),
        ),
        const SizedBox(height: 20),

        // 5. Daily Update Section
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: DailyUpdateFeedWidget(),
        ),
        const SizedBox(height: 20),

        // 6. Quick Access Tiles
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: _buildQuickInfoTiles(),
        ),
      ],
    );
  }

  Widget _buildQuickInfoTiles() {
    return Row(
      children: [
        Expanded(
          child: QuickInfoTile(
            title: 'YouTube Video',
            subtitle: 'Latest School Event',
            icon: Icons.play_circle_fill_rounded,
            color: const Color(0xFFFF0000),
            onTap: () {},
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: QuickInfoTile(
            title: 'Today History',
            subtitle: 'Academic logs',
            icon: Icons.history_rounded,
            color: const Color(0xFF2196F3),
            onTap: () {},
          ),
        ),
      ],
    );
  }
}
