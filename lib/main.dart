import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
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
      },
    );
  }
}