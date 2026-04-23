import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/auth/model/user.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/document/model/view_document.dart';
import 'package:school_app/document/model/view_document.dart';
import 'package:school_app/document/viewmodel/document_view_model.dart';
import 'package:school_app/utils/app_theme.dart';
import 'package:school_app/utils/utils.dart';
import 'package:provider/provider.dart';

class ViewDocumentScreen extends StatefulWidget {
  static const String routeName = '/view-document';
  final String? title;

  const ViewDocumentScreen({super.key, this.title});

  @override
  State<ViewDocumentScreen> createState() => _ViewDocumentScreenState();
}

class _ViewDocumentScreenState extends State<ViewDocumentScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DocumentViewModel(),
      child: Consumer<DocumentViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: AppColors.surface,
            body: SafeArea(
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        _buildAppBar(context),
                        _buildSearchBar(vm),
                        _buildCategories(vm),
                        _buildRecentHeader(),
                        _buildDocumentList(vm),
                        _buildBottomCta(),
                        const SliverToBoxAdapter(child: SizedBox(height: 100)),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 12),
        child: Row(
          children: [
            _IconButton(
              icon: Icons.chevron_left_rounded,
              onTap: () => Navigator.pop(context),
            ),
            Expanded(
              child: Text(
                'Documents',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
                image: const DecorationImage(
                  image: NetworkImage('https://i.pravatar.cc/150?u=doc_user'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(DocumentViewModel vm) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: AppRadius.fullRadius,
                  border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
                  boxShadow: AppShadows.soft,
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, color: AppColors.outline, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        onChanged: (val) => vm.setSearchQuery(val),
                        decoration: InputDecoration(
                          hintText: 'Search documents...',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.outline,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            _IconButton(icon: Icons.tune_rounded, onTap: () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories(DocumentViewModel vm) {
    final categories = [
      _CategoryData('Circulars', Icons.campaign_rounded, const Color(0xFF0EA5E9), vm.documents['Circulars']?.length ?? 0),
      _CategoryData('Notices', Icons.notifications_rounded, const Color(0xFFF59E0B), vm.documents['Notices']?.length ?? 0),
      _CategoryData('Holiday Homework', Icons.menu_book_rounded, const Color(0xFF10B981), vm.documents['Holiday Homework']?.length ?? 0),
      _CategoryData('Worksheets', Icons.assignment_rounded, const Color(0xFF8B5CF6), vm.documents['Worksheets']?.length ?? 0),
      _CategoryData('Syllabus', Icons.description_rounded, const Color(0xFFEF4444), vm.documents['Syllabus']?.length ?? 0),
    ];

    return SliverToBoxAdapter(
      child: Container(
        height: 140,
        margin: const EdgeInsets.only(top: 16),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, i) => _CategoryCard(data: categories[i]),
        ),
      ),
    );
  }

  Widget _buildRecentHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 24, AppSpacing.lg, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Documents',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Row(
                children: [
                  Text(
                    'View All',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.primary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentList(DocumentViewModel vm) {
    final filtered = vm.filteredDocuments;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) => _DocumentCard(doc: filtered[i]),
          childCount: filtered.length,
        ),
      ),
    );
  }

  Widget _buildBottomCta() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.lg),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFECFEFF),
          borderRadius: AppRadius.xlRadius,
          border: Border.all(color: const Color(0xFFCFFAFE)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.lgRadius,
              ),
              child: const Icon(Icons.archive_outlined, color: Color(0xFF0891B2)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'All important documents in one place',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF164E63),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Stay updated with the latest circulars, notices, assignments and more.',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF0891B2),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF164E63),
                borderRadius: AppRadius.fullRadius,
              ),
              child: Row(
                children: [
                  const Icon(Icons.history_rounded, color: Colors.white, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'View Archived',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryData {
  final String label;
  final IconData icon;
  final Color color;
  final int count;
  _CategoryData(this.label, this.icon, this.color, this.count);
}

class _CategoryCard extends StatelessWidget {
  final _CategoryData data;
  const _CategoryCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: data.color.withOpacity(0.08),
        borderRadius: AppRadius.xlRadius,
        border: Border.all(color: data.color.withOpacity(0.12)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadius.lgRadius,
              boxShadow: [
                BoxShadow(
                  color: data.color.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(data.icon, color: data.color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            data.label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: data.color,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '${data.count}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: data.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final Document doc;
  const _DocumentCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    final type = doc.documentType ?? "Circular";
    final color = _getColorForType(type);
    final icon = _getIconForType(type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.xlRadius,
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.25)),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: AppRadius.lgRadius,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: AppRadius.fullRadius,
                  ),
                  child: Text(
                    type,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  doc.remarks ?? 'Untitled Document',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Please find the details for ${type.toLowerCase()}...',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatAnyDateToDDMMYY(doc.uploadDate ?? ""),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'PDF • 512 KB',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: AppColors.outline,
                ),
              ),
              const SizedBox(height: 8),
              _IconButton(
                icon: Icons.download_rounded,
                size: 32,
                iconSize: 18,
                onTap: () => launchURLString(doc.attachment ?? ""),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getColorForType(String type) {
    if (type.contains('Circular')) return const Color(0xFF0EA5E9);
    if (type.contains('Notice')) return const Color(0xFFF59E0B);
    if (type.contains('Homework')) return const Color(0xFF10B981);
    if (type.contains('Worksheet')) return const Color(0xFF8B5CF6);
    if (type.contains('Syllabus')) return const Color(0xFFEF4444);
    return AppColors.primary;
  }

  IconData _getIconForType(String type) {
    if (type.contains('Circular')) return Icons.campaign_rounded;
    if (type.contains('Notice')) return Icons.notifications_rounded;
    if (type.contains('Homework')) return Icons.menu_book_rounded;
    if (type.contains('Worksheet')) return Icons.assignment_rounded;
    if (type.contains('Syllabus')) return Icons.description_rounded;
    return Icons.file_copy_rounded;
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double iconSize;

  const _IconButton({
    required this.icon,
    required this.onTap,
    this.size = 44,
    this.iconSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.fullRadius,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
          boxShadow: AppShadows.soft,
        ),
        child: Icon(icon, color: AppColors.onSurface, size: iconSize),
      ),
    );
  }
}
