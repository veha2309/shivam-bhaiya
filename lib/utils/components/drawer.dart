// File: lib/utils/components/drawer.dart
// REDESIGNED: Clean glass-panel drawer with profile header
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/auth/model/user.dart';
import 'package:school_app/auth/view/change_password_screen.dart';
import 'package:school_app/auth/view/login_screen.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/home_screen/model/home.dart';
import 'package:school_app/home_screen/view/home_screen.dart';
import 'package:school_app/main_navigation_screen.dart';
import 'package:school_app/settings/view/settings_screen.dart';
import 'package:school_app/student_profile/View/student_profile_screen.dart';
import 'package:school_app/user/view/user_list_screen.dart';
import 'package:school_app/utils/app_theme.dart';
import 'package:school_app/utils/components/bottom_sheet.dart';
import 'package:school_app/utils/components/profile_widget.dart';
import 'package:school_app/utils/language_provider.dart';
import 'package:school_app/utils/local_storage/local_storage.dart';
import 'package:school_app/utils/utils.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});
  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  User? user;
  HomeModel? homeModel;
  late List<_DrawerItem> _items;

  void _buildItems() {
    final lang = context.read<LanguageProvider>();
    user = AuthViewModel.instance.getLoggedInUser();
    homeModel = AuthViewModel.instance.homeModel;
    _items = [
      _DrawerItem(lang.translate('home'), Icons.grid_view_rounded, () {
        navigateToScreen(context, const MainNavigationScreen(), replace: true);
      }),
      if (LocalStorage.hasMultipleUsers())
        _DrawerItem(lang.translate('user_list'), Icons.people_rounded,
            () => navigateToScreen(context, const UserListScreen())),
      _DrawerItem(lang.translate('add_user'), Icons.person_add_rounded,
          () => navigateToScreen(context, const LoginScreen(shouldAllowPop: true))),
      _DrawerItem(lang.translate('settings'), Icons.lock_rounded,
          () => navigateToScreen(context, const SettingsScreen())),
      if (user?.userType != 'Teacher')
        _DrawerItem(lang.translate('profile'), Icons.account_circle_rounded, () {
          final u = AuthViewModel.instance.getLoggedInUser();
          navigateToScreen(context, StudentProfileScreen(studentId: u?.username ?? ''));
        }),
      _DrawerItem(
        lang.translate('language'),
        Icons.translate_rounded,
        () => showLanguageBottomSheet(context),
      ),
      _DrawerItem(lang.translate('school_website'), Icons.language_rounded,
          () => launchURLString('https://google.com')), // Should be a dynamic or constant value
      _DrawerItem(lang.translate('refresh'), Icons.refresh_rounded,
          () => Phoenix.rebirth(context)),
      _DrawerItem(lang.translate('help'), Icons.support_agent_rounded,
          () => showContactBottomSheet(context)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>(); // Ensure rebuild on change
    _buildItems();
    return Drawer(
      backgroundColor: AppColors.surfaceContainerLowest,
      elevation: 0,
      child: SafeArea(
        child: Column(
          children: [
            _buildProfileHeader(),
            Expanded(child: _buildMenuList()),
            _buildSocialRow(),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
      decoration: const BoxDecoration(
        gradient: AppGradients.tealHero,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.xl),
          bottomRight: Radius.circular(AppRadius.xl),
        ),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
              boxShadow: AppShadows.soft,
            ),
            child: ClipOval(
              child: Container(
                color: AppColors.primaryContainer.withOpacity(0.5),
                child: homeModel?.profilePhoto != null
                    ? Image.network(homeModel!.profilePhoto!, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const _DefaultAvatar())
                    : const _DefaultAvatar(),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Name
          Text(
            user?.name ?? '',
            textAlign: TextAlign.center,
            textScaler: const TextScaler.linear(1.0),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),

          // Class pill
          if ((homeModel?.className ?? '').isNotEmpty || user?.userType == 'Admin')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: AppRadius.fullRadius,
              ),
              child: Text(
                user?.userType == 'Admin' ? 'ADMINISTRATOR' : (homeModel?.className ?? ''),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryContainer,
                  letterSpacing: 0.8,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      itemCount: _items.length,
      itemBuilder: (context, i) {
        final item = _items[i];
        return _DrawerTile(item: item);
      },
    );
  }

  Widget _buildSocialRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.read<LanguageProvider>().translate('connect_with_us'),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _SocialBtn(FontAwesomeIcons.facebook,
                  () => launchURLString('https://www.facebook.com/VivekanandSchoolDBlock/')),
              _SocialBtn(FontAwesomeIcons.instagram,
                  () => launchURLString('https://www.instagram.com/vivekanandschool/')),
              _SocialBtn(FontAwesomeIcons.youtube,
                  () => launchURLString('https://www.youtube.com/channel/UCSHkcyHkZIM_oWT1afjSzXw')),
            ],
          ),
        ],
      ),
    );
  }
}

class _DrawerItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  const _DrawerItem(this.title, this.icon, this.onTap);
}

class _DrawerTile extends StatelessWidget {
  final _DrawerItem item;
  const _DrawerTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: item.onTap,
          borderRadius: AppRadius.lgRadius,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: AppRadius.mdRadius,
                  ),
                  child: Icon(item.icon, size: 18, color: AppColors.darkTeal),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item.title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    size: 18, color: AppColors.onSurfaceVariant.withOpacity(0.4)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DefaultAvatar extends StatelessWidget {
  const _DefaultAvatar();
  @override
  Widget build(BuildContext context) {
    return Icon(Icons.person_rounded, color: Colors.white.withOpacity(0.7), size: 36);
  }
}

class _SocialBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SocialBtn(this.icon, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.fullRadius,
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: AppRadius.fullRadius,
          ),
          child: Icon(icon, size: 16, color: AppColors.darkTeal),
        ),
      ),
    );
  }
}