import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/utils/app_theme.dart';

class SquareGridComponent extends StatelessWidget {
  final String title;
  final String icon;
  final VoidCallback onTap;
  final int colorIndex;
  final String? backgroundImage; // Kept for API compatibility

  const SquareGridComponent({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.colorIndex = 0,
    this.backgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.lgRadius,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.lgRadius,
          boxShadow: AppShadows.soft,
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: AppRadius.mdRadius,
              ),
              child: icon.startsWith('material:')
                  ? Icon(
                      _getMaterialIcon(icon),
                      size: 28,
                      color: const Color(0xFF001A1D),
                    )
                  : Image.asset(
                      icon,
                      width: 28,
                      height: 28,
                      errorBuilder: (_, __, ___) => const Icon(Icons.star_rounded, color: AppColors.darkTeal),
                    ),
            ),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getMaterialIcon(String name) {
    switch (name) {
      case 'material:payments':
        return Icons.payments_rounded;
      case 'material:account_balance_wallet':
        return Icons.account_balance_wallet_rounded;
      case 'material:receipt_long':
        return Icons.receipt_long_rounded;
      case 'material:history':
        return Icons.history_rounded;
      default:
        return Icons.star_rounded;
    }
  }
}