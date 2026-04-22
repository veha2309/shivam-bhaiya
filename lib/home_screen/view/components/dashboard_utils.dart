import 'package:flutter/material.dart';
import 'package:school_app/utils/app_theme.dart';

class DashboardUtils {
  static const BorderRadius futuristicRadius = BorderRadius.only(
    topLeft: Radius.circular(24),
    bottomRight: Radius.circular(24),
    topRight: Radius.circular(6),
    bottomLeft: Radius.circular(6),
  );

  static BoxDecoration futuristicDecoration({Color? glowColor}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: futuristicRadius,
      border: Border.all(
        color: glowColor?.withOpacity(0.4) ?? AppColors.primary.withOpacity(0.2),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: (glowColor ?? AppColors.primary).withOpacity(0.12),
          blurRadius: 20,
          spreadRadius: -2,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  static Widget buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }
}
