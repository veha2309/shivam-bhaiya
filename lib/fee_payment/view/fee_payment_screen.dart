import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:school_app/fee_payment/view/razorpay_gateway_screen.dart';
import 'package:school_app/fee_payment/view_model/fees_view_model.dart';
import 'package:school_app/utils/app_theme.dart';
import 'package:school_app/utils/utils.dart';

class FeePaymentScreen extends StatelessWidget {
  final String? title;
  final String? paymentUrl;
  const FeePaymentScreen({super.key, this.title, this.paymentUrl});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FeesViewModel()..loadFees(),
      child: Consumer<FeesViewModel>(
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
                        _buildSummaryCard(vm),
                        _buildMonthSelector(vm),
                        _buildSelectionInfo(vm),
                        _buildFeeDetails(vm),
                        _buildTotalAndProceed(vm , context),
                        _buildPreviousPayments(vm),
                        _buildPreviousYearReceipts(vm),
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
                'School Fees',
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
                  image: NetworkImage('https://i.pravatar.cc/150?u=fees_user'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(FeesViewModel vm) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.lg),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.xlRadius,
          boxShadow: AppShadows.soft,
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0EA5E9).withOpacity(0.1),
                    borderRadius: AppRadius.lgRadius,
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF0EA5E9), size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      _buildSummaryStatVertical('Total Fees', '₹${vm.totalFees.toInt()}', const Color(0xFF64748B), Icons.history_rounded),
                      const SizedBox(height: 12),
                      _buildSummaryStatVertical('Paid Till Date', '₹${vm.paidAmount.toInt()}', const Color(0xFF10B981), Icons.check_circle_outline_rounded),
                      const SizedBox(height: 12),
                      _buildSummaryStatVertical('Pending', '₹${vm.pendingAmount.toInt()}', const Color(0xFFF59E0B), Icons.pending_actions_rounded),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 8),
                    Text(
                      'Academic Year: 2024-25',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: Row(
                    children: [
                      Text('Fee Details', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.primary),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStatVertical(String label, String value, Color color, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 3,
          child: Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B), fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          flex: 2,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w900, color: color),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthSelector(FeesViewModel vm) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 8, AppSpacing.lg, 12),
            child: Text(
              'Select Months to Pay',
              style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.onSurface),
            ),
          ),
          SizedBox(
            height: 80,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              scrollDirection: Axis.horizontal,
              itemCount: vm.months.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final m = vm.months[i];
                return SizedBox(
                  width: 80,
                  child: _MonthTile(
                    month: m,
                    onTap: () => vm.toggleMonthSelection(i),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionInfo(FeesViewModel vm) {
    if (vm.selectedMonths.isEmpty) return const SliverToBoxAdapter(child: SizedBox());
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F9FF),
            borderRadius: AppRadius.mdRadius,
            border: Border.all(color: const Color(0xFFE0F2FE)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF0369A1)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'You can select multiple months to pay fees',
                  style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF0369A1), fontWeight: FontWeight.w500),
                ),
              ),
              TextButton(
                onPressed: vm.clearSelection,
                style: TextButton.styleFrom(visualDensity: VisualDensity.compact, padding: EdgeInsets.zero),
                child: Text('Clear Selection', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF0369A1))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeeDetails(FeesViewModel vm) {
    if (vm.selectedMonths.isEmpty) return const SliverToBoxAdapter(child: SizedBox());
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fees Details (${vm.selectedMonths.length} Month Selected)',
              style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.onSurface),
            ),
            const SizedBox(height: 12),
            ...vm.selectedMonths.map((m) => _SelectedMonthCard(month: m)),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalAndProceed(FeesViewModel vm , BuildContext context) {
    if (vm.selectedMonths.isEmpty) return const SliverToBoxAdapter(child: SizedBox());
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: AppRadius.lgRadius,
                border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Payable (${vm.selectedMonths.length} Month)',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                  ),
                  Text(
                    '₹${vm.totalPayable.toInt()}',
                    style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RazorpayGatewayScreen(
                        amount: vm.totalPayable,
                        url: paymentUrl ?? "https://vivekanandschool.in/pay",
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.xlRadius),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Proceed to Pay ₹${vm.totalPayable.toInt()}',
                      style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviousPayments(FeesViewModel vm) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Previous Payments',
                  style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.onSurface),
                ),
                TextButton(
                  onPressed: () {},
                  child: Row(
                    children: [
                      Text('View All', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.primary),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ...vm.previousPayments.map((m) => _PreviousPaymentTile(month: m)),
            const SizedBox(height: 12),
            Center(
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download_rounded, size: 16),
                label: Text('Download All Receipts (This Year)', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviousYearReceipts(FeesViewModel vm) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 24, AppSpacing.lg, 12),
            child: Text(
              'Previous Year Receipts',
              style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.onSurface),
            ),
          ),
          SizedBox(
            height: 100,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              scrollDirection: Axis.horizontal,
              itemCount: vm.previousYearReceipts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final r = vm.previousYearReceipts[i];
                return Container(
                  width: 160,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.lgRadius,
                    border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(r.year, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.onSurface)),
                          const Icon(Icons.download_rounded, size: 16, color: AppColors.primary),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Total Paid', style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurfaceVariant)),
                      Text('₹${r.totalPaid.toInt()}', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthTile extends StatelessWidget {
  final FeeMonth month;
  final VoidCallback onTap;
  const _MonthTile({required this.month, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = month.isSelected;
    final isPaid = month.isPaid;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mdRadius,
      child: Container(
        decoration: BoxDecoration(
          color: isPaid ? Colors.transparent : (isSelected ? AppColors.darkTeal : Colors.white),
          borderRadius: AppRadius.mdRadius,
          border: Border.all(
            color: isPaid 
              ? AppColors.outlineVariant.withOpacity(0.3) 
              : (isSelected ? AppColors.darkTeal : AppColors.outlineVariant.withOpacity(0.5)),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              month.month,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isPaid 
                  ? AppColors.onSurfaceVariant.withOpacity(0.5) 
                  : (isSelected ? Colors.white : AppColors.onSurface),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isPaid) ...[
                  Text('Paid', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: const Color(0xFF10B981))),
                  const SizedBox(width: 4),
                  const Icon(Icons.check_circle_rounded, size: 10, color: Color(0xFF10B981)),
                ] else if (isSelected) ...[
                  Text('Selected', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
                ] else ...[
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedMonthCard extends StatelessWidget {
  final FeeMonth month;
  const _SelectedMonthCard({required this.month});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.lgRadius,
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: AppRadius.mdRadius,
            ),
            child: const Icon(Icons.calendar_month_rounded, color: Color(0xFF0EA5E9)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${month.month} 2024',
                    style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.onSurface),
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Due Date: 10 ${month.month} 2024',
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFFF59E0B)),
                  ),
                ),
                const SizedBox(height: 2),
                Text('Regular Fee', style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${month.amount.toInt()}',
                style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.onSurface),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('View Breakdown', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant)),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppColors.onSurfaceVariant),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviousPaymentTile extends StatelessWidget {
  final FeeMonth month;
  const _PreviousPaymentTile({required this.month});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.lgRadius,
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long_rounded, color: Color(0xFF64748B), size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text('${month.month} 2024', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text('Paid on: ${month.paidDate}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
                ),
              ],
            ),
          ),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('₹${month.amount.toInt()}', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.onSurface)),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: AppRadius.xsRadius),
            child: Text('Paid', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF15803D))),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.download_rounded, size: 18, color: Color(0xFF64748B)),
        ],
      ),
    );
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