import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/landing/view/landing_screen.dart';
import 'package:school_app/services/notification_service.dart';
import 'package:school_app/services/download_service.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/device_utils.dart';
import 'package:school_app/utils/local_storage/local_storage.dart';
import 'firebase_options.dart';

// Must be top-level and registered before Firebase.initializeApp().
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('[FCM] Background message: ${message.messageId}');
}

bool isUserDeletedInThisSession = false;

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> intialiseFirebase() async {
  // Register background handler BEFORE initializeApp (FCM requirement).
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService().initialize();

  try {
    final token = await NotificationService().getToken();
    DeviceInfoService.firebaseToken = token;
    if (token != null) {
      // Copy this token into Firebase Console → Messaging → Send test message.
      print('[FCM] Device token: $token');
    } else {
      print(
          '[FCM] WARNING: getToken() returned null. Check internet connection and google-services.json.');
    }
  } catch (e) {
    print('[FCM] Failed to retrieve token: $e');
  }

  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    DeviceInfoService.firebaseToken = newToken;
    print('[FCM] Token refreshed: $newToken');
  });

  await DeviceInfoService.getDeviceId();
}

void main() async {
  isUserDeletedInThisSession = false;
  WidgetsFlutterBinding.ensureInitialized();
  await intialiseFirebase();

  // Initialize download service very early, with error handling
  try {
    await DownloadService.initialize();
    print('DownloadService initialized successfully');
  } catch (e) {
    print('Failed to initialize DownloadService: $e');
    // Continue app startup even if download service fails
  }

  // await intialiseFirebase();
  await LocalStorage.init();

  if (!isUserDeletedInThisSession) {
    await LocalStorage.deleteUserWithExpiredToken();
    await LocalStorage.checkIfMultipleUserLoggedIn();
    isUserDeletedInThisSession = true;
  }

  await AuthViewModel.instance.refreshToken();

  runApp(Phoenix(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vivekanand School UI',
      builder: (context, child) {
        final MediaQueryData data = MediaQuery.of(context);
        return MediaQuery(
          data: data.copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child ?? const SizedBox(),
        );
      },
      theme: ThemeData(
        primaryColor: ColorConstant.primaryColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: ColorConstant.primaryColor,
        ),
      ),
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,
      home: const LandingScreen(),
    );
  }
}
