import 'package:flutter/material.dart';
import 'package:school_app/utils/app_theme.dart';

class DashboardUtils {
  static const double borderRadiusValue = 24.0;
  static final BorderRadius futuristicRadius = BorderRadius.only(
    topLeft: const Radius.circular(borderRadiusValue),
    bottomRight: const Radius.circular(borderRadiusValue),
    topRight: Radius.zero,
    bottomLeft: Radius.zero,
  );

  static BoxDecoration futuristicDecoration({Color? color}) {
    return BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: futuristicRadius,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
      border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
    );
  }

  static Widget buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }
}
