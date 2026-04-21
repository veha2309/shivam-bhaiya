import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/utils/app_theme.dart';

class RectangleTileComponent extends StatelessWidget {
  final String title;
  final String? icon;
  final VoidCallback onTap;
  final bool isTitleCentered;
  final Color? textColor;

  const RectangleTileComponent({
    super.key,
    required this.title,
    this.icon,
    required this.onTap,
    this.isTitleCentered = false,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.lgRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.lgRadius,
          boxShadow: AppShadows.soft,
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: AppRadius.mdRadius,
              ),
              child: icon != null
                  ? (icon!.startsWith('material:')
                      ? Icon(
                          _getMaterialIcon(icon!),
                          size: 24,
                          color: const Color(0xFF001A1D),
                        )
                      : Image.asset(
                          icon!,
                          width: 24,
                          height: 24,
                          errorBuilder: (_, __, ___) => const Icon(Icons.apps_rounded, color: AppColors.darkTeal),
                        ))
                  : const Icon(Icons.apps_rounded, color: AppColors.darkTeal),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                textAlign: isTitleCentered ? TextAlign.center : TextAlign.start,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor ?? AppColors.onSurface,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.onSurfaceVariant,
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
      default:
        return Icons.apps_rounded;
    }
  }
}