// File: lib/utils/components/appbar.dart
// REDESIGNED: Frosted-glass sticky AppBar with Plus Jakarta Sans branding and dark contrast actions
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/auth/model/user.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/notifications/view/notifications_screen.dart';
import 'package:school_app/utils/app_theme.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/utils.dart';

PreferredSizeWidget getAppBar(
  BuildContext context,
  GlobalKey<ScaffoldState> scaffoldKey, {
  bool showBackButton = true,
  String? studentName,
  Widget? title,
}) {
  final User? loggedInUser = AuthViewModel.instance.getLoggedInUser();

  return PreferredSize(
    preferredSize: Size.fromHeight(
      (loggedInUser?.userType == 'Student' || studentName != null) && showBackButton
          ? 96
          : 64,
    ),
    child: ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.92),
            boxShadow: [
              BoxShadow(
                color: AppColors.onSurface.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 64,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        // Hamburger or Back button
                        _AppBarLeading(
                          showBackButton: showBackButton,
                          scaffoldKey: scaffoldKey,
                        ),

                        // Logo centered & acts as Home Button, or Custom Title
                        Expanded(
                          child: Center(
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
                              child: title ?? Image.asset(
                                ImageConstants.logoImagePath,
                                height: 38,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),

                        // Consistent Notification & Profile Actions
                        const _AppBarActions(),
                      ],
                    ),
                  ),
                ),

                // Student name subtitle restored (only on back-button screens)
                if (showBackButton &&
                    (loggedInUser?.userType == 'Student' || studentName != null))
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    height: 32,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      studentName ?? loggedInUser?.name ?? '',
                      textScaler: const TextScaler.linear(1.0),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _AppBarLeading extends StatelessWidget {
  final bool showBackButton;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const _AppBarLeading({
    required this.showBackButton,
    required this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (showBackButton) {
            popScreen(context);
          } else {
            scaffoldKey.currentState?.openDrawer();
          }
        },
        borderRadius: AppRadius.fullRadius,
        child: Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
            boxShadow: AppShadows.soft,
          ),
          child: Icon(
            showBackButton ? CupertinoIcons.chevron_back : Icons.menu_rounded,
            size: 22,
            color: const Color(0xFF001A1D),
          ),
        ),
      ),
    );
  }
}

class _AppBarActions extends StatelessWidget {
  const _AppBarActions();

  @override
  Widget build(BuildContext context) {
    // Actions are now consistent across all screens (No more context switching)
    return Row(
      children: [
<<<<<<< Updated upstream
        if (showBackButton)
          _ActionButton(
            icon: Icons.home_rounded,
            onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
          ),
        if (!showBackButton)
          _ActionButton(
            icon: Icons.notifications_none_rounded, // Use outline for modern feel
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const NotificationsScreen(),
              ),
            ),
          ),
=======
        _ActionButton(
          icon: Icons.notifications_none_rounded, 
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const NotificationsScreen(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _ActionButton(
          icon: Icons.person_outline_rounded,
          onTap: () {
            // Navigate to profile or show quick profile
          },
        ),
>>>>>>> Stashed changes
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.fullRadius,
        child: Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
            boxShadow: AppShadows.soft,
          ),
          child: Icon(icon, size: 22, color: const Color(0xFF001A1D)),
        ),
      ),
    );
  }
}