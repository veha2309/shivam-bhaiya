import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/home_screen/view/components/dashboard_utils.dart';
import 'package:school_app/home_screen/view/components/hud_background.dart';
import 'package:school_app/utils/app_theme.dart';
import 'package:school_app/utils/components/app_scaffold.dart';

class DocumentsAwardsScreen extends StatefulWidget {
  static const String routeName = '/documents-awards';
  const DocumentsAwardsScreen({super.key});

  @override
  State<DocumentsAwardsScreen> createState() => _DocumentsAwardsScreenState();
}

class _DocumentsAwardsScreenState extends State<DocumentsAwardsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showAppBar: true,
      appBarTitle: Text("Vault And Gallery", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16)),
      body: SophisticatedHUDBackground(
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.outline,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(text: 'Documents', icon: Icon(Icons.folder_shared_outlined)),
                Tab(text: 'Awards', icon: Icon(Icons.emoji_events_outlined)),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDocumentsList(),
                  _buildAwardsGrid(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildDocTile('Aadhar Card (Self)', 'PDF • 1.2 MB', 'Verified'),
        _buildDocTile('Birth Certificate', 'PDF • 2.4 MB', 'Verified'),
        _buildDocTile('Previous School TC', 'PDF • 3.1 MB', 'Verified'),
        _buildDocTile('Address Proof', 'JPG • 0.8 MB', 'Pending'),
        _buildDocTile('Medical Fitness Certificate', 'PDF • 1.5 MB', 'Verified'),
      ],
    );
  }

  Widget _buildDocTile(String name, String info, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: DashboardUtils.futuristicDecoration(),
      child: Row(
        children: [
          const Icon(Icons.description_rounded, color: AppColors.primary, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13)),
                Text(info, style: GoogleFonts.inter(fontSize: 10, color: AppColors.outline)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: (status == 'Verified' ? Colors.green : Colors.orange).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
            child: Text(status, style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.bold, color: status == 'Verified' ? Colors.green : Colors.orange)),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.download_for_offline_outlined, color: AppColors.primary, size: 20),
        ],
      ),
    );
  }

  Widget _buildAwardsGrid() {
    return GridView.count(
      padding: const EdgeInsets.all(16),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.9,
      children: [
        _buildAwardCard('First Prize', 'Inter-School Debate', '2024', Colors.amber),
        _buildAwardCard('Gold Medal', 'Annual Sports Meet', '2023', Colors.amber),
        _buildAwardCard('Best Performer', 'Cultural Fest', '2023', Colors.purple),
        _buildAwardCard('Star Student', 'Academic Excellence', '2022', Colors.blue),
      ],
    );
  }

  Widget _buildAwardCard(String title, String event, String year, Color color) {
    return Container(
      decoration: DashboardUtils.futuristicDecoration(),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.emoji_events_rounded, color: color, size: 30),
          ),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13), textAlign: TextAlign.center),
          Text(event, style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurfaceVariant), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(year, style: GoogleFonts.inter(fontSize: 9, color: AppColors.outline, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
