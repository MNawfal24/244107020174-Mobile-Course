import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Import Praktikum 1
import 'providers/auth_provider.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/announcement_page.dart';

// Import Praktikum 2
import 'messaging/push_service.dart';

// Container untuk menyimpan state
final container = ProviderContainer();

// Konfigurasi Navigasi
final router = GoRouter(
  redirect: (context, state) {
    final loggedIn = container.read(authStateProvider).value ?? false;
    final goingLogin = state.matchedLocation == '/login';
    
    if (!loggedIn && !goingLogin) return '/login';
    if (loggedIn && goingLogin) return '/';
    return null;
  },
  routes: [
   GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
  GoRoute(path: '/', builder: (_, _) => const HomePage()),
    GoRoute(
      path: '/pengumuman/:id',
      builder: (_, s) => AnnouncementPage(id: s.pathParameters['id'] ?? ''),
    ),
  ],
);

void main() async {
  // Wajib sebelum inisialisasi Firebase
  WidgetsFlutterBinding.ensureInitialized();

  //Daftarjan background handler (Praktikum 3)
  registerBackgroundHandler();
  
  // Inisialisasi Firebase (Praktikum 2)
  await Firebase.initializeApp();

  // Inisialisasi Notifikasi (Praktikum 2)
  await requestNotificationPermission();
  await initLocalNotifications();
  
  // Ambil Token FCM (Praktikum 2)
  await initFcmToken(onToken: (token) async {
    final displayToken = token.length > 12 ? '${token.substring(0, 12)}...' : token;
    debugPrint('FCM Token: $displayToken'); 
  });

  // Menangani klik notifikasi agar pindah halaman via GoRouter
  listenForeground((route) => router.go(route));
  await handleTerminated((route) => router.go(route));

  // Jalankan Aplikasi
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Week 6 Project',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}