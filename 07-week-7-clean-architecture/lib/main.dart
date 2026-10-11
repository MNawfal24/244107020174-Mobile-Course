import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Wajib di-import
import 'features/notes/presentation/providers/notes_providers.dart';
import 'features/notes/presentation/pages/notes_page.dart'; 

void main() {
  initializeNotesDatabase();
  runApp(
    // Wajib ada ProviderScope yang membungkus MyApp
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clean Architecture Notes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Halaman awal langsung mengarah ke NotesPage
      home: const NotesPage(),
    );
  }
}