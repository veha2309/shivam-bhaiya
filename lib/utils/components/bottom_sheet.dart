import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/document/model/document_type.dart';
import 'package:school_app/result_analysis/model/result_analysis_drop_down_model.dart';
import 'package:school_app/result_analysis/model/result_analysis_template_model.dart';
import 'package:school_app/school_details/model/class.dart';
import 'package:school_app/school_details/model/section.dart';
import 'package:school_app/utils/app_theme.dart';
import 'package:school_app/utils/language_provider.dart';
import 'package:school_app/utils/utils.dart';
import 'package:provider/provider.dart';

/// Consistent styled header for all bottom sheets
Widget _bottomSheetTitle(String text) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
    child: Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.primary,
        letterSpacing: -0.4,
      ),
    ),
  );
}

/// Consistent list tile for bottom sheets
Widget _bottomSheetTile(String title, VoidCallback onTap, {IconData? icon}) {
  return ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
    leading: icon != null
        ? Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: AppRadius.mdRadius,
            ),
            child: Icon(icon, size: 18, color: AppColors.primaryContainer),
          )
        : null,
    title: Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.onSurface,
      ),
    ),
    trailing: Icon(Icons.chevron_right_rounded,
        size: 16, color: AppColors.outlineVariant),
    onTap: onTap,
    shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
  );
}

/// Generic bottom sheet opener for list of items
void _openSelectionBottomSheet<T>({
  required BuildContext context,
  required String title,
  required List<T> items,
  required String Function(T) labelExtractor,
  required void Function(T) onSelected,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 0.8,
      expand: false,
      builder: (context, scrollController) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          _bottomSheetTitle(title),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _bottomSheetTile(
                  labelExtractor(item),
                  () {
                    Navigator.pop(context);
                    onSelected(item);
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

void openClassBottomSheet(
    BuildContext context, List<ClassModel> classes, void Function(ClassModel) onSelected) {
  _openSelectionBottomSheet<ClassModel>(
    context: context,
    title: context.read<LanguageProvider>().translate('Select Class'),
    items: classes,
    labelExtractor: (c) => c.className,
    onSelected: onSelected,
  );
}

void openSectionBottomSheet(
    BuildContext context, List<Section> sections, void Function(Section) onSelected) {
  _openSelectionBottomSheet<Section>(
    context: context,
    title: context.read<LanguageProvider>().translate('Select Section'),
    items: sections,
    labelExtractor: (s) => s.sectionName,
    onSelected: onSelected,
  );
}

void openDocumentTypeBottomSheet(
    BuildContext context, List<DocumentType> types, void Function(DocumentType) onSelected) {
  _openSelectionBottomSheet<DocumentType>(
    context: context,
    title: context.read<LanguageProvider>().translate('Select Document Type'),
    items: types,
    labelExtractor: (t) => t.docTypeName ?? '',
    onSelected: onSelected,
  );
}

void openResultAnalysisDropDownBottomSheet(
    BuildContext context,
    List<ResultAnalysisDropDownModel> items,
    void Function(ResultAnalysisDropDownModel) onSelected) {
  _openSelectionBottomSheet<ResultAnalysisDropDownModel>(
    context: context,
    title: context.read<LanguageProvider>().translate('Select Option'),
    items: items,
    labelExtractor: (i) => i.label ?? '',
    onSelected: onSelected,
  );
}

void openResultAnalysisTemplateBottomSheet(
    BuildContext context,
    List<ResultAnalysisTemplateModel> templates,
    void Function(ResultAnalysisTemplateModel) onSelected) {
  _openSelectionBottomSheet<ResultAnalysisTemplateModel>(
    context: context,
    title: context.read<LanguageProvider>().translate('Select Report Template'),
    items: templates,
    labelExtractor: (t) => t.reportName ?? '',
    onSelected: onSelected,
  );
}

void showMonthsBottomSheet(BuildContext context, void Function(String) onSelected) {
  final months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  _openSelectionBottomSheet<String>(
    context: context,
    title: context.read<LanguageProvider>().translate('Select Month'),
    items: months,
    labelExtractor: (m) => m,
    onSelected: onSelected,
  );
}

void openMonthBottomSheet(
    BuildContext context, List<String> months, void Function(String) onSelected) {
  _openSelectionBottomSheet<String>(
    context: context,
    title: context.read<LanguageProvider>().translate('Select Month'),
    items: months,
    labelExtractor: (m) => m,
    onSelected: onSelected,
  );
}

void openSubjectModelBottomSheet(
    BuildContext context, List<dynamic>? subjects, void Function(dynamic) onSelected) {
  _openSelectionBottomSheet<dynamic>(
    context: context,
    title: context.read<LanguageProvider>().translate('Select Subject'),
    items: subjects ?? [],
    labelExtractor: (s) => s.toString(),
    onSelected: onSelected,
  );
}

/// Shows contact options for help/support
void showContactBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _bottomSheetTitle(context.read<LanguageProvider>().translate('Contact Support')),
          const SizedBox(height: 8),
          _bottomSheetTile(
            context.read<LanguageProvider>().translate('Call Office'),
            () {
              Navigator.pop(context);
              makePhoneCall('011-22141527');
            },
            icon: Icons.phone_rounded,
          ),
          _bottomSheetTile(
            context.read<LanguageProvider>().translate('Email Support'),
            () {
              Navigator.pop(context);
              sendEmail(context, 'helpdesk@vivekanandschool.in', 'App Support', '');
            },
            icon: Icons.email_rounded,
          ),
          _bottomSheetTile(
            context.read<LanguageProvider>().translate('Visit Website'),
            () {
              Navigator.pop(context);
              launchURLString('https://vivekanandschool.in');
            },
            icon: Icons.language_rounded,
          ),
          const SizedBox(height: 24),
        ],
      ),
    ),
  );
}

/// Shows language selection options
void showLanguageBottomSheet(BuildContext context) {
  final langProvider = context.read<LanguageProvider>();
  
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _bottomSheetTitle(langProvider.translate('select_language')),
          const SizedBox(height: 8),
          ...langProvider.supportedLanguages.map((lang) {
            final isSelected = langProvider.currentLanguage == lang['value'];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
              leading: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryContainer.withOpacity(0.1) : AppColors.surfaceContainerLow,
                  borderRadius: AppRadius.mdRadius,
                ),
                child: Icon(
                  Icons.language_rounded, 
                  size: 18, 
                  color: isSelected ? AppColors.primaryContainer : AppColors.onSurfaceVariant.withOpacity(0.5)
                ),
              ),
              title: Text(
                lang['name'],
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.onSurface,
                ),
              ),
              trailing: isSelected 
                ? const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20)
                : null,
              onTap: () {
                langProvider.setLanguage(lang['value'] as Language);
                Navigator.pop(context);
              },
              shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
            );
          }),
          const SizedBox(height: 24),
        ],
      ),
    ),
  );
}