import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:school_app/admin_dashboard/view_model/admin_dashboard_view_model.dart';
import 'package:school_app/auth/view/login_screen.dart';
import 'package:school_app/attendance_screen/view/student_attendance_screen.dart';
import 'package:school_app/firebase_options.dart';
import 'package:school_app/home_screen/view/home_screen.dart';
import 'package:school_app/landing/view/landing_screen.dart';
import 'package:school_app/services/notification_service.dart';
import 'package:school_app/tabbar/tabbar_screen.dart';
import 'package:school_app/main_navigation_screen.dart';
import 'package:school_app/utils/app_theme.dart';
import 'package:school_app/utils/language_provider.dart';
import 'package:school_app/utils/local_storage/local_storage.dart';
import 'package:provider/provider.dart';

import 'package:school_app/academic_records/view/academic_journey_screen.dart';
import 'package:school_app/disciplinary_records/view/disciplinary_actions_screen.dart';
import 'package:school_app/attendance_screen/view/records_main_screen.dart';
import 'package:school_app/student_dossier/view/student_dossier_screen.dart';
import 'package:school_app/admin_dashboard/view/admin_dashboard_view.dart';
import 'package:school_app/admin_dashboard/view/admin_navigation_screen.dart';
import 'package:school_app/attendance_screen/view/attendance_records_screen.dart';
import 'package:school_app/attendance_screen/view/teacher_attendance_statistics_screen.dart';

import 'package:school_app/student_dossier/view/sub_records/inbox_screen.dart';
import 'package:school_app/student_dossier/view/sub_records/fees_records_screen.dart';
import 'package:school_app/student_dossier/view/sub_records/medical_visits_screen.dart';
import 'package:school_app/student_dossier/view/sub_records/documents_awards_screen.dart';
import 'package:school_app/student_dossier/view/sub_records/class_work_screen.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize LocalStorage (Hive)
  await LocalStorage.init();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Notifications
  await NotificationService().initialize();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AdminDashboardViewModel()),
      ],
      child: Phoenix(child: const MyApp()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>();
    return MaterialApp(
      title: 'Vivekanand School',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: buildAppTheme(),
      // LandingScreen handles the redirection to Login or Home based on auth state
      home: const LandingScreen(),
      routes: {
        LandingScreen.routeName: (context) => const LandingScreen(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        HomeScreen.routeName: (context) => const HomeScreen(),
        TabbarScreen.routeName: (context) => const TabbarScreen(),
        StudentAttendanceScreen.routeName: (context) =>
            const StudentAttendanceScreen(),
        MainNavigationScreen.routeName: (context) =>
            const MainNavigationScreen(),
        AdminNavigationScreen.routeName: (context) =>
            const AdminNavigationScreen(),
        AcademicJourneyScreen.routeName: (context) =>
            const AcademicJourneyScreen(),
        DisciplinaryActionsScreen.routeName: (context) =>
            const DisciplinaryActionsScreen(),
        RecordsMainScreen.routeName: (context) =>
            const RecordsMainScreen(),
        StudentDossierScreen.routeName: (context) => const StudentDossierScreen(),
        InboxScreen.routeName: (context) => const InboxScreen(),
        TuitionFeesScreen.routeName: (context) => const TuitionFeesScreen(),
        MedicalVisitsScreen.routeName: (context) => const MedicalVisitsScreen(),
        DocumentsAwardsScreen.routeName: (context) => const DocumentsAwardsScreen(),
        ClassWorkScreen.routeName: (context) => const ClassWorkScreen(),
        AttendanceRecordsScreen.routeName: (context) =>
            const AttendanceRecordsScreen(),
        TeacherAttendanceStatisticsScreen.routeName: (context) =>
            const TeacherAttendanceStatisticsScreen(),
            
        // 2. ADDED: The new Admin Dashboard route
        '/adminDashboard': (context) => const AdminDashboardView(),
      },
    );
  }
}