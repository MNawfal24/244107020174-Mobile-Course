import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final _local = FlutterLocalNotificationsPlugin();
String? pendingDeepLink;

// 1. Background handler wajib top-level (berjalan di isolate terpisah)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Jangan akses BuildContext / Riverpod di sini.
  // Tugasnya: catat / simpan ringan saja. Navigasi dilakukan saat klik.
}

void registerBackgroundHandler() {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

// Fungsi dari Praktikum 2
Future<bool> requestNotificationPermission() async {
  final settings = await FirebaseMessaging.instance.requestPermission(
    alert: true, badge: true, sound: true,
    announcement: false, carPlay: false, criticalAlert: false,
  );
  return settings.authorizationStatus == AuthorizationStatus.authorized ||
         settings.authorizationStatus == AuthorizationStatus.provisional;
}

// Fungsi dari Praktikum 2
Future<void> initLocalNotifications() async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings();
  
  await _local.initialize(
    settings: const InitializationSettings(android: android, iOS: ios),
    onDidReceiveNotificationResponse: (response) {
      pendingDeepLink = response.payload;
    },
  );
}

// Fungsi dari Praktikum 2 (Sudah mencakup Topic Messaging Praktikum 3)
Future<void> initFcmToken({required Future<void> Function(String token) onToken}) async {
  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) await onToken(token);
  FirebaseMessaging.instance.onTokenRefresh.listen(onToken);
  
  // Berlangganan topik pengumuman-kampus
  await FirebaseMessaging.instance.subscribeToTopic('pengumuman-kampus');
}

// 2. Handler Foreground
void listenForeground(void Function(String route) go) {
  // Foreground: sistem TIDAK menampilkan banner otomatis, jadi tampilkan manual
  FirebaseMessaging.onMessage.listen((message) async {
    final route = message.data['route'] ?? '/';
    const androidDetails = AndroidNotificationDetails(
      'pengumuman', 'Pengumuman Kampus',
      importance: Importance.high, priority: Priority.high,
    );
    
    await _local.show(
      id: message.hashCode,
      title: message.notification?.title ?? 'Pengumuman',
      body: message.notification?.body ?? '',
      notificationDetails: const NotificationDetails(android: androidDetails),
      payload: route,
    );
  });

  // Background -> diklik
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    go(message.data['route'] ?? '/');
  });
}

// 3. Handler Terminated
Future<void> handleTerminated(void Function(String route) go) async {
  // Terminated -> dibuka dari notifikasi
  final initial = await FirebaseMessaging.instance.getInitialMessage();
  if (initial != null) go(initial.data['route'] ?? '/');
  if (pendingDeepLink != null) go(pendingDeepLink!);
}