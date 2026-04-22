import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:school_app/home_screen/view/components/dashboard_utils.dart';
import 'package:school_app/utils/app_theme.dart';
import 'package:school_app/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart'; // Just in case, though not used in original snippet

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
      decoration: DashboardUtils.futuristicDecoration(glowColor: Colors.blue),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transport Tracker',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          color: Colors.blue, size: 12),
                      const SizedBox(width: 4),
                      Text('Route 4',
                          style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 160,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(24),
                bottomLeft: Radius.circular(6),
              ),
              child: checkingPermission
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary))
                  : !hasPermission
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.location_off_rounded,
                                  color: Colors.grey, size: 32),
                              const SizedBox(height: 8),
                              Text(
                                'Location permission required',
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.onSurfaceVariant),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: onRequestPermission,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  minimumSize: Size.zero,
                                ),
                                child: Text('Enable',
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        )
                      : FlutterMap(
                          options: const MapOptions(
                            initialCenter: LatLng(28.6139, 77.2090),
                            initialZoom: 14.0,
                            interactionOptions:
                                InteractionOptions(flags: InteractiveFlag.none),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                              userAgentPackageName:
                                  'com.vivekanand.mobileapp55566',
                            ),
                            PolylineLayer(
                              polylines: [
                                Polyline(
                                  points: const [
                                    LatLng(28.6139, 77.2090), // Current
                                    LatLng(28.6145, 77.2105),
                                    LatLng(28.6160, 77.2115),
                                    LatLng(28.6180, 77.2135),
                                    LatLng(28.6200, 77.2150), // Destination
                                  ],
                                  color: AppColors.primary,
                                  strokeWidth: 4.0,
                                ),
                              ],
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: const LatLng(28.6200, 77.2150),
                                  width: 40,
                                  height: 40,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: AppShadows.soft,
                                    ),
                                    child: const Icon(Icons.school_rounded,
                                        color: AppColors.primary, size: 24),
                                  ),
                                ),
                                Marker(
                                  point: const LatLng(28.6139, 77.2090),
                                  width: 60,
                                  height: 60,
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: AppShadows.medium,
                                          border: Border.all(
                                              color: Colors.orange, width: 2),
                                        ),
                                        child: const Icon(
                                            Icons.directions_bus_rounded,
                                            color: Colors.orange,
                                            size: 24),
                                      ),
                                      const SizedBox(height: 2),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: Colors.orange,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text('Live',
                                            style: GoogleFonts.inter(
                                                color: Colors.white,
                                                fontSize: 8,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
