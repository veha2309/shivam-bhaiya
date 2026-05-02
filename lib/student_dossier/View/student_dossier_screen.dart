import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/home_screen/view/components/dashboard_utils.dart';
import 'package:school_app/home_screen/view/components/hud_background.dart';
import 'package:school_app/student_dossier/Model/student_dossier.dart';
import 'package:school_app/utils/app_theme.dart';
import 'package:school_app/utils/components/app_scaffold.dart';

class StudentDossierScreen extends StatefulWidget {
  static const String routeName = '/student-dossier';
  final bool isInsideParent;
  final StudentDossier? studentDossier;
  
  const StudentDossierScreen({
    super.key, 
    this.isInsideParent = false,
    this.studentDossier,
  });

  @override
  State<StudentDossierScreen> createState() => _StudentDossierScreenState();
}

class _StudentDossierScreenState extends State<StudentDossierScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late StudentDossier student;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    student = widget.studentDossier ?? StudentDossier(
      studentId: '2024/08/023',
      studentName: 'Aarav Sharma',
      className: '8',
      sectionName: 'A',
      fatherName: 'Mr. Rajesh Sharma',
      motherName: 'Mrs. Sunita Sharma',
      mobileNo: '+91 98765 43210',
      transport: 'Bus',
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        _buildHeader(),
        _buildCustomTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(),
              _buildTimelineTab(),
              _buildProfileTab(),
            ],
          ),
        ),
      ],
    );

    if (widget.isInsideParent) return content;

    return AppScaffold(
      showAppBar: false,
      body: SophisticatedHUDBackground(
        child: content,
      ),
    );
  }

  Widget _buildTimelineTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTimelineItem('Today', 'Attendance Updated', 'Aarav was marked present at 09:15 AM.', Icons.check_circle_rounded, Colors.green),
        _buildTimelineItem('15 May', 'New Message', 'Regarding Science exhibition next week.', Icons.mail_rounded, Colors.indigo),
        _buildTimelineItem('12 May', 'Assignment Submitted', 'Mathematics Exercise 4.2 completed.', Icons.assignment_turned_in_rounded, Colors.blue),
        _buildTimelineItem('10 May', 'Library Fine Paid', 'Paid ₹50 fine for overdue book.', Icons.payments_rounded, Colors.orange),
        _buildTimelineItem('05 May', 'Medical Visit', 'Minor headache, rested for 1 hour.', Icons.medical_services_rounded, Colors.pink),
        _buildTimelineItem('01 May', 'Monthly Assessment', 'Scored 92% in Science Monthly Test.', Icons.analytics_rounded, Colors.purple),
      ],
    );
  }

  Widget _buildTimelineItem(String date, String title, String description, IconData icon, Color color) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 50,
            child: Column(
              children: [
                Text(date, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.outline)),
                const SizedBox(height: 4),
                Expanded(child: Container(width: 2, color: AppColors.outlineVariant.withOpacity(0.5))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 16),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: DashboardUtils.futuristicDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(description, style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildProfileSection('Personal Information', [
            _buildProfileRow('Full Name', student.studentName ?? '--'),
            _buildProfileRow('Father Name', student.fatherName ?? '--'),
            _buildProfileRow('Mother Name', student.motherName ?? '--'),
            _buildProfileRow('Mobile No.', student.mobileNo ?? '--'),
            _buildProfileRow('Address', 'Delhi, India'),
          ]),
          const SizedBox(height: 16),
          _buildProfileSection('Academic Information', [
            _buildProfileRow('Current Grade', student.className ?? '--'),
            _buildProfileRow('Section', student.sectionName ?? '--'),
            _buildProfileRow('Admission ID', student.studentId ?? '--'),
            _buildProfileRow('House', 'Newton House'),
            _buildProfileRow('Roll Number', '24'),
          ]),
          const SizedBox(height: 16),
          _buildProfileSection('Parent Information', [
            _buildProfileRow('Father Name', 'Mr. Rajesh Sharma'),
            _buildProfileRow('Mother Name', 'Mrs. Sunita Sharma'),
            _buildProfileRow('Emergency Contact', '+91 98765 43210'),
          ]),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildProfileSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: DashboardUtils.futuristicDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.primary)),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.outline)),
          Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!widget.isInsideParent)
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary.withOpacity(0.06),
                  foregroundColor: AppColors.darkTeal,
                ),
              )
            else
              Builder(
                builder: (innerContext) => IconButton(
                  onPressed: () => Scaffold.of(innerContext).openDrawer(),
                  icon: const Icon(Icons.menu_rounded, color: AppColors.darkTeal),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.06),
                    foregroundColor: AppColors.darkTeal,
                  ),
                ),
              ),
            Expanded(
              child: Text(
                'Student Dossier',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkTeal,
                ),
              ),
            ),
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=${student.studentId}'),
              backgroundColor: AppColors.primaryContainer,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.darkTeal, width: 3),
          ),
        ),
        labelColor: AppColors.darkTeal,
        unselectedLabelColor: AppColors.onSurfaceVariant,
        labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Timeline'),
          Tab(text: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildProfileCard(),
          const SizedBox(height: 16),
          _buildWelcomeBanner(),
          const SizedBox(height: 16),
          _buildMetricsGrid(),
          const SizedBox(height: 24),
          _buildRecentActivitiesSection(),
          const SizedBox(height: 16),
          _buildSafetyBanner(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.darkTeal, AppColors.darkTeal.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        image: const DecorationImage(
          image: NetworkImage('https://img.freepik.com/free-vector/modern-school-building-concept_23-2148222442.jpg'), // Placeholder for school illustration
          fit: BoxFit.cover,
          opacity: 0.1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=aarav'),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.studentName ?? 'Student Name',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Grade ${student.className ?? '--'}  •  ${student.sectionName ?? '--'}',
                  style: GoogleFonts.inter(color: Colors.white.withOpacity(0.8), fontSize: 12),
                ),
                Text(
                  'Admission No.: ${student.studentId ?? '--'}',
                  style: GoogleFonts.inter(color: Colors.white.withOpacity(0.6), fontSize: 11),
                ),
                Text(
                  'Transport: ${student.transport ?? '--'}',
                  style: GoogleFonts.inter(color: Colors.white.withOpacity(0.6), fontSize: 11),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Active',
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'B+',
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: DashboardUtils.futuristicDecoration(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primaryContainer.withOpacity(0.4), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.description_outlined, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your journey, all in one place!',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                Text(
                  'This section contains a comprehensive record of your activities, achievements, and important updates.',
                  style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                side: BorderSide(color: AppColors.outlineVariant),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 12),
                  const SizedBox(width: 4),
                  Text('Timeline', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 0.62,
      children: [
        _buildMetricCard(Icons.school_outlined, 'Academic Remarks', '12', Colors.green, onTap: () {
          Navigator.pushNamed(context, '/academic-journey');
        }),
        _buildMetricCard(Icons.calendar_today_outlined, 'Attendance Records', '184 Days', Colors.orange, onTap: () {
          Navigator.pushNamed(context, '/attendance-records');
        }),
        _buildMetricCard(Icons.mail_outline_rounded, 'My Inbox', '3 Unread', Colors.indigo, badge: '3', onTap: () {
          Navigator.pushNamed(context, '/inbox-records');
        }),
        _buildMetricCard(Icons.gavel_outlined, 'Disciplinary Actions', '1 Record', Colors.red, onTap: () {
          Navigator.pushNamed(context, '/disciplinary-actions');
        }),
        _buildMetricCard(Icons.assignment_outlined, 'Report Cards', '3 Reports', Colors.blue, onTap: () {
          Navigator.pushNamed(context, '/class-work'); // Using class work as placeholder for reports
        }),
        _buildMetricCard(Icons.medical_services_outlined, 'Medical Room Visits', '2 Visits', Colors.pink, onTap: () {
          Navigator.pushNamed(context, '/medical-visits');
        }),
        _buildMetricCard(Icons.emoji_events_outlined, 'Awards & Honors', '4 Awards', Colors.amber, onTap: () {
          Navigator.pushNamed(context, '/documents-awards');
        }),
        _buildMetricCard(Icons.account_balance_wallet_outlined, 'Tuition Fee Records', '₹28,000 Paid', Colors.teal, onTap: () {
          Navigator.pushNamed(context, '/tuition-fees');
        }),
        _buildMetricCard(Icons.update_outlined, 'Data Updates', '2 Updates', Colors.cyan),
        _buildMetricCard(Icons.folder_outlined, 'Documents', '8 Documents', Colors.brown, onTap: () {
          Navigator.pushNamed(context, '/documents-awards');
        }),
        _buildMetricCard(Icons.sports_basketball_outlined, 'Activities Participation', '6 Activities', Colors.deepPurple),
        _buildMetricCard(Icons.assignment_turned_in_outlined, 'Class Work & Assignments', 'View All', Colors.blueGrey, onTap: () {
          Navigator.pushNamed(context, '/class-work');
        }),
      ],
    );
  }

  Widget _buildMetricCard(IconData icon, String label, String value, Color color, {String? badge, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: DashboardUtils.futuristicDecoration(),
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, color: color, size: 18),
                ),
                if (badge != null)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 22, // Fixed height for label to prevent jumping
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('View', style: GoogleFonts.inter(fontSize: 8, color: AppColors.primary, fontWeight: FontWeight.bold)),
                const Icon(Icons.chevron_right_rounded, size: 10, color: AppColors.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Activities', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16)),
            TextButton(
              onPressed: () {},
              child: Row(
                children: [
                  Text('View All', style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
                  const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.onSurfaceVariant),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildActivityTile(Icons.mail_outline, Colors.indigo, 'New message from Class Teacher', 'Regarding upcoming Science exhibition.', '15 May 2024', '10:30 AM'),
        _buildActivityTile(Icons.calendar_today_outlined, Colors.green, 'Attendance Updated', 'Present on 15 May 2024', '15 May 2024', '09:15 AM'),
        _buildActivityTile(Icons.emoji_events_outlined, Colors.amber, 'Award Received', 'Second Prize in Inter-Class Quiz Competition', '14 May 2024', '04:20 PM'),
      ],
    );
  }

  Widget _buildActivityTile(IconData icon, Color color, String title, String subtitle, String date, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: DashboardUtils.futuristicDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(subtitle, style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(date, style: GoogleFonts.inter(fontSize: 9, color: AppColors.outline, fontWeight: FontWeight.bold)),
              Text(time, style: GoogleFonts.inter(fontSize: 8, color: AppColors.outline)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: DashboardUtils.futuristicDecoration(color: AppColors.primaryContainer.withOpacity(0.1)),
      child: Row(
        children: [
          const Icon(Icons.verified_user_outlined, color: Colors.teal, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your data is safe with us', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.teal.shade800)),
                Text(
                  'All your information is securely stored and managed by the school.',
                  style: GoogleFonts.inter(fontSize: 10, color: Colors.teal.shade600),
                ),
              ],
            ),
          ),
          const Icon(Icons.lock_outline_rounded, color: Colors.teal, size: 24),
        ],
      ),
    );
  }
}
