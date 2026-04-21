// File: lib/utils/components/user_header_widget.dart
// REDESIGNED: Modern header with "Welcome back!" greeting and large name
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/auth/model/user.dart';
import 'package:school_app/home_screen/model/home.dart';
import 'package:school_app/utils/app_theme.dart';
import 'package:school_app/utils/language_provider.dart';
import 'package:school_app/utils/utils.dart';
import 'package:provider/provider.dart';

final class UserHeaderWidget extends StatelessWidget {
  final User? user;
  final HomeModel? homeModel;

  const UserHeaderWidget({
    super.key,
    required this.user,
    required this.homeModel,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Profile Greeting Row ───────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back!',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    user?.name ?? lang.translate('student'),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const UserAvatar(imageUrl: ''), // Empty for now, uses initials
            ],
          ),
          const SizedBox(height: 12),
          // Subtitle or date can go here
        ],
      ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  final String imageUrl;
  const UserAvatar({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48, width: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryContainer,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: AppShadows.soft,
      ),
      child: ClipOval(
        child: imageUrl.isNotEmpty
            ? Image.network(imageUrl, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _InitialsAvatar())
            : const _InitialsAvatar(),
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryContainer,
      child: Icon(Icons.person_rounded, color: const Color(0xFF001A1D), size: 28),
    );
  }
}