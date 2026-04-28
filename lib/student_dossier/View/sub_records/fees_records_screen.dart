import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/home_screen/view/components/dashboard_utils.dart';
import 'package:school_app/home_screen/view/components/hud_background.dart';
import 'package:school_app/utils/app_theme.dart';
import 'package:school_app/utils/components/app_scaffold.dart';

class TuitionFeesScreen extends StatelessWidget {
  static const String routeName = '/tuition-fees';
  const TuitionFeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showAppBar: true,
      appBarTitle: Text("Tuition Fee Records", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16)),
      body: SophisticatedHUDBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCard(),
              const SizedBox(height: 24),
              Text(
                'Recent Transactions',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 16),
              _buildTransactionList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.teal, Color(0xFF00796B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Paid', style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
                  Text('₹28,000', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildMiniStat('Due Amount', '₹4,500')),
              Container(width: 1, height: 30, color: Colors.white24),
              Expanded(child: _buildMiniStat('Next Due Date', '15 Jun 24')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.inter(color: Colors.white70, fontSize: 10)),
        Text(value, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildTransactionList() {
    return Column(
      children: [
        _buildTransactionTile('Monthly Tuition Fee', 'Apr 2024', '₹7,000', 'Paid', Colors.green),
        _buildTransactionTile('Annual Activity Fee', 'Mar 2024', '₹14,000', 'Paid', Colors.green),
        _buildTransactionTile('Transport Fee', 'Feb 2024', '₹3,500', 'Paid', Colors.green),
        _buildTransactionTile('Library Fine', 'Jan 2024', '₹500', 'Paid', Colors.green),
        _buildTransactionTile('T-Shirt Fee', 'Jan 2024', '₹3,000', 'Paid', Colors.green),
      ],
    );
  }

  Widget _buildTransactionTile(String title, String date, String amount, String status, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: DashboardUtils.futuristicDecoration(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.receipt_long_rounded, color: statusColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13)),
                Text(date, style: GoogleFonts.inter(fontSize: 11, color: AppColors.outline)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 14)),
              Text(status, style: GoogleFonts.inter(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
