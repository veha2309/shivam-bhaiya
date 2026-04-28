import 'package:flutter/material.dart';
import 'package:school_app/utils/app_theme.dart';
import 'package:school_app/home_screen/view/components/dashboard_utils.dart';

class RevenueSummaryCard extends StatelessWidget {
  final String todayCollection;
  final VoidCallback onViewLedger;
  final VoidCallback onGenerateReport;

  const RevenueSummaryCard({
    super.key,
    required this.todayCollection,
    required this.onViewLedger,
    required this.onGenerateReport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.darkTeal, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: DashboardUtils.futuristicRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.darkTeal.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Collection",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(Icons.account_balance_wallet_rounded, color: Colors.white.withOpacity(0.8), size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            todayCollection,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onViewLedger,
                  icon: const Icon(Icons.receipt_long_rounded, size: 18),
                  label: const Text("View Ledger"),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: const Color(0xFF1E3C72), 
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onGenerateReport,
                  icon: const Icon(Icons.insert_chart_rounded, size: 18),
                  label: const Text("Report"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}