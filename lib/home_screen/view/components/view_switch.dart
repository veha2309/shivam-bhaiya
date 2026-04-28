import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/utils/app_theme.dart';

class ViewSwitch extends StatelessWidget {
  final bool isDashboard;
  final ValueChanged<bool> onChanged;

  const ViewSwitch({
    super.key,
    required this.isDashboard,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: AppRadius.fullRadius,
      ),
      child: Row(
        children: [
          Expanded(
            child: _SwitchItem(
              label: 'Home',
              isActive: !isDashboard,
              onTap: () => onChanged(false),
            ),
          ),
          Expanded(
            child: _SwitchItem(
              label: 'Dashboard',
              isActive: isDashboard,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SwitchItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: AppRadius.fullRadius,
          boxShadow: isActive ? AppShadows.soft : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isActive ? Colors.white : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
