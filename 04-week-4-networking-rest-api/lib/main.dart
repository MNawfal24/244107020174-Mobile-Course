import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pages/post_list_page.dart';
import 'package:go_router/go_router.dart';
import 'pages/post_detail_page.dart';
import 'data/models/post.dart';

void main() => runApp(const ProviderScope(child: MyApp()));

// Konfigurasi GoRouter
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const PostListPage(),
    ),
    GoRoute(
      path: '/post/:id',
      builder: (context, state) {
        // Menangkap data (extra) yang dikirim dari halaman list
        final post = state.extra as Post;
        return PostDetailPage(post: post);
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) => MaterialApp.router(
        debugShowCheckedModeBanner: false, // Menghilangkan banner debug
        title: 'Week 4 - REST API',
        theme: ThemeData(
          colorSchemeSeed: Colors.indigo, 
          useMaterial3: true,
        ),
        routerConfig: _router, // Menyambungkan router ke aplikasi
      );
}