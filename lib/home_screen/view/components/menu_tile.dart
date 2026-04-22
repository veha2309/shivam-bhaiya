import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/home_screen/view/components/dashboard_utils.dart';
import 'package:school_app/utils/app_theme.dart';
import 'package:school_app/utils/utils.dart';

class MenuTile extends StatelessWidget {
  final String title;
  final Widget subtitleWidget;
  final dynamic icon;
  final Color accentColor;
  final VoidCallback onTap;

  const MenuTile({
    super.key,
    required this.title,
    required this.subtitleWidget,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget iconWidget;
    if (icon is IconData) {
      iconWidget = Icon(icon, color: accentColor, size: 24);
    } else if (icon is String && icon.isNotEmpty) {
      iconWidget = Image.asset(
        icon,
        width: 24,
        height: 24,
        errorBuilder: (_, __, ___) =>
            Icon(Icons.category_rounded, color: accentColor, size: 24),
      );
    } else {
      iconWidget = Icon(Icons.category_rounded, color: accentColor, size: 24);
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: DashboardUtils.futuristicDecoration(glowColor: accentColor),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                border: Border.all(color: accentColor.withOpacity(0.3)),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12)),
              ),
              child: iconWidget,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 4),
                  subtitleWidget,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
