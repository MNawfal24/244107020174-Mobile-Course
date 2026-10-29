import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/providers.dart';
import '../widgets/notes_body.dart';
import '../widgets/notes_search_field.dart';
import 'notes_detail_page.dart';
import 'setting_page.dart';
import 'settings_page.dart';

// Provider untuk waktu terakhir dibuka dari SharedPreferences
final lastOpenedProvider = FutureProvider.autoDispose<String?>((ref) async {
  final prefs = ref.watch(prefsRepositoryProvider);
  final lastOpened = await prefs.getLastOpened();
  await prefs.markOpenedNow(); // Update waktu saat ini setelah dibaca
  return lastOpened;
});

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastOpenedAsync = ref.watch(lastOpenedProvider);
    final isDarkMode = ref.watch(darkModeProvider).value ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Notes'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: NotesSearchField(),
        ),
        actions: [
          // Tombol Dark Mode
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              ref.read(darkModeProvider.notifier).toggle();
            },
          ),
          // Tombol Sync
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () async {
              final repo = ref.read(noteRepositoryProvider);
              await syncNotes(repo);
              if (!context.mounted) return;
              ref.read(notesListNotifierProvider.notifier).loadNotes();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sinkronisasi selesai!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Pengaturan',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner Terakhir Dibuka
          Container(
            width: double.infinity,
            color: Colors.blue.withValues(alpha: 0.1),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              lastOpenedAsync.when(
                data: (date) => date != null
                    ? 'Terakhir dibuka: $date'
                    : 'Terakhir dibuka: Belum pernah',
                loading: () => 'Memuat...',
                error: (_, _) => '',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ),

          // Daftar Catatan
          const Expanded(child: NotesBody()),
        ],
      ),
      // Tombol Tambah Catatan (FAB)
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NoteDetailPage()),
          );
          ref.read(notesListNotifierProvider.notifier).loadNotes();
        },
      ),
    );
  }
}
