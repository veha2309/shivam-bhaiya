import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/home_screen/view/components/dashboard_utils.dart';
import 'package:school_app/utils/app_theme.dart';

class ViewSwitch extends StatelessWidget {
  final bool isDashboard;
  final ValueChanged<bool> onChanged;

  const ViewSwitch({super.key, required this.isDashboard, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: DashboardUtils.futuristicDecoration(),
      child: Row(
        children: [
          Expanded(
            child: SwitchItem(
              label: 'Home',
              isActive: !isDashboard,
              onTap: () => onChanged(false),
            ),
          ),
          Expanded(
            child: SwitchItem(
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

class SwitchItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const SwitchItem({super.key, required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
            topRight: Radius.circular(2),
            bottomLeft: Radius.circular(2),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: isActive ? Colors.white : AppColors.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
