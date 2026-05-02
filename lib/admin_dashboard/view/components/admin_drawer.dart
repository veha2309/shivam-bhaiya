import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/common_student_search/common_student_search_screen.dart';
import 'package:school_app/utils/app_theme.dart';
import 'package:school_app/utils/utils.dart';

class AdminDrawer extends StatelessWidget {
  final String? activeItem;
  final Function(int)? onSelectItem;
  const AdminDrawer({super.key, this.activeItem, this.onSelectItem});

  @override
  Widget build(BuildContext context) {
    final adminUser = AuthViewModel.instance.getLoggedInUser();

    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          _buildDrawerHeader(adminUser),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.dashboard_rounded,
                  title: 'Dashboard',
                  onTap: () {
                    Navigator.pop(context);
                    if (onSelectItem != null) {
                      onSelectItem!(0);
                    }
                  },
                  isHighlighted: activeItem == 'Dashboard',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.person_rounded,
                  title: 'User Profile',
                  onTap: () {
                    Navigator.pop(context);
                    if (onSelectItem != null) {
                      onSelectItem!(1);
                    } else {
                      navigateToScreen(
                        context,
                        const CommonStudentSearchScreen(
                          mode: StudentSearchMode.userProfile,
                        ),
                      );
                    }
                  },
                  isHighlighted: activeItem == 'User Profile',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.gavel_rounded,
                  title: 'Rule Violation',
                  onTap: () {
                    Navigator.pop(context);
                    navigateToScreen(
                      context,
                      const CommonStudentSearchScreen(
                        mode: StudentSearchMode.ruleViolation,
                      ),
                    );
                  },
                  isHighlighted: activeItem == 'Rule Violation',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.school_rounded,
                  title: 'Academic Violation',
                  onTap: () {
                    Navigator.pop(context);
                    navigateToScreen(
                      context,
                      const CommonStudentSearchScreen(
                        mode: StudentSearchMode.academicViolation,
                      ),
                    );
                  },
                  isHighlighted: activeItem == 'Academic Violation',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.person_add_rounded,
                  title: 'Add User',
                  onTap: () {
                    Navigator.pop(context);
                    navigateToScreen(
                      context,
                      const CommonStudentSearchScreen(
                        mode: StudentSearchMode.addUser,
                      ),
                    );
                  },
                  isHighlighted: activeItem == 'Add User',
                ),
                const Divider(height: 40),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings_rounded,
                  title: 'Settings',
                  onTap: () {},
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.help_outline_rounded,
                  title: 'Help & Support',
                  onTap: () {},
                ),
              ],
            ),
          ),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(dynamic user) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(30)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=admin'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'Admin User',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppColors.darkTeal,
                  ),
                ),
                Text(
                  user?.userType == 'Admin' ? 'Administrator' : 'Teacher',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isHighlighted ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: isHighlighted ? AppColors.primary : AppColors.outline,
          size: 22,
        ),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w600,
            fontSize: 14,
            color: isHighlighted ? AppColors.primary : AppColors.onSurface,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: InkWell(
        onTap: () => AuthViewModel.instance.logout(context),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.error.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
              const SizedBox(width: 8),
              Text(
                'Logout',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
