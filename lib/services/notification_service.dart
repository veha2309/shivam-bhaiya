import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Android notification channel – must match the channel ID in AndroidManifest.xml.
  static const _androidChannel = AndroidNotificationChannel(
    'default_channel',
    'Default Channel',
    description: 'Default notification channel',
    importance: Importance.max,
  );

  Future<void> initialize() async {
    // Request OS-level permission (Android 13+ and iOS).
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print(
        '[FCM] Notification permission status: ${settings.authorizationStatus}');
    if (settings.authorizationStatus == AuthorizationStatus.denied ||
        settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      print(
          '[FCM] WARNING: Notification permission DENIED/not determined. Notifications will not appear.');
      return;
    }

    // On iOS, instruct FCM to show alerts/badges/sounds even when the app is
    // in the foreground (without this, iOS silently drops foreground FCM messages).
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // ic_notification is a monochrome white-on-transparent drawable (required
    // on Android 5.0+ — using a full-colour mipmap icon renders as a white square).
    const androidInit = AndroidInitializationSettings('ic_notification');
    // Disable duplicate permission prompts on iOS – FCM already asked above.
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    bool? initialized;
    try {
      initialized = await _localNotifications.initialize(
        const InitializationSettings(android: androidInit, iOS: iosInit),
        onDidReceiveNotificationResponse: _onLocalNotificationTapped,
      );
    } catch (e, st) {
      print('[FCM] ERROR initializing flutter_local_notifications: $e\n$st');
    }
    print('[FCM] flutter_local_notifications initialized: $initialized');

    // Create the Android channel so notifications are delivered correctly on
    // Android 8+ (Oreo and above require explicit channel registration).
    try {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_androidChannel);
    } catch (e, st) {
      print('[FCM] ERROR creating notification channel: $e\n$st');
    }

    // Foreground FCM messages – show as a local notification.
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // App opened by tapping a notification while in the background.
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // App launched from a terminated state by tapping a notification.
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('[FCM] Foreground message received. id=${message.messageId} '
        'title=${message.notification?.title} body=${message.notification?.body}');

    // If there's no notification payload (data-only message), nothing to show.
    if (message.notification == null) {
      print('[FCM] Data-only message — no notification payload to display.');
      return;
    }

    try {
      final androidDetails = AndroidNotificationDetails(
        _androidChannel.id,
        _androidChannel.name,
        channelDescription: _androidChannel.description,
        importance: Importance.max,
        priority: Priority.high,
        icon: 'ic_notification',
      );

      await _localNotifications.show(
        message.hashCode,
        message.notification?.title,
        message.notification?.body,
        NotificationDetails(
          android: androidDetails,
          iOS: const DarwinNotificationDetails(),
        ),
        payload: message.data['route'] as String?,
      );
      print('[FCM] Foreground notification displayed successfully.');
    } catch (e, st) {
      print('[FCM] ERROR displaying foreground notification: $e\n$st');
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    print(
        '[FCM] App opened from notification. id=${message.messageId} data=${message.data}');
  }

  void _onLocalNotificationTapped(NotificationResponse response) {
    print('[FCM] Local notification tapped. payload=${response.payload}');
  }

  /// Returns the FCM registration token for the current device.
  /// Works on both Android and iOS (after APNs is configured on iOS).
  Future<String?> getToken() async {
    return await _fcm.getToken();
  }

  /// Sends an immediate local notification — use this to verify
  /// flutter_local_notifications is working independently of FCM.
  Future<void> showTestNotification() async {
    await _localNotifications.show(
      999,
      'Test Notification',
      'If you see this, local notifications are working.',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.max,
          priority: Priority.high,
          icon: 'ic_notification',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }
}
