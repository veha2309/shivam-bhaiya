import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/home_screen/view/components/dashboard_utils.dart';
import 'package:school_app/utils/app_theme.dart';

class FeeDetailsCard extends StatelessWidget {
  final String amountDue;
  final VoidCallback onPay;
  final VoidCallback onDetail;

  const FeeDetailsCard({
    super.key,
    required this.amountDue,
    required this.onPay,
    required this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: DashboardUtils.futuristicDecoration(glowColor: Colors.orange),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'FEES DATA',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: AppColors.onSurfaceVariant),
              ),
              const Spacer(),
              const Icon(Icons.memory_rounded, color: Colors.orange, size: 20),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12)),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Text('₹',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.orange)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('BALANCE DUE',
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: AppColors.onSurfaceVariant)),
                    Text(
                      amountDue,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.onSurface),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _buildFeeButton(
                      'DETAIL', Colors.transparent, AppColors.onSurface, true,
                      onDetail)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildFeeButton(
                      'PAY NOW', AppColors.primary, Colors.white, false, onPay)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeeButton(String label, Color bgColor, Color textColor,
      bool isOutlined, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
          border:
              isOutlined ? Border.all(color: AppColors.outlineVariant) : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              color: textColor),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
