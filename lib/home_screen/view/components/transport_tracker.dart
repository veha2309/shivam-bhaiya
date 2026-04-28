import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/utils/app_theme.dart';

class TransportTrackerWidget extends StatelessWidget {
  final bool hasPermission;
  final bool checkingPermission;
  final VoidCallback onRequestPermission;

  const TransportTrackerWidget({
    super.key,
    required this.hasPermission,
    required this.checkingPermission,
    required this.onRequestPermission,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),

        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_bus_rounded, color: Colors.orange, size: 24),
              const SizedBox(width: 12),
              Text(
                'Live Bus Tracking',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (checkingPermission)
            const Center(child: CircularProgressIndicator())
          else if (!hasPermission)
            Column(
              children: [
                const Text('Enable location to track your bus in real-time.'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: onRequestPermission,
                  child: const Text('Allow Tracking'),
                ),
              ],
            )
          else
            const Text('Tracking is enabled. Viewing map...'),
        ],
      ),
    );
  }
}
