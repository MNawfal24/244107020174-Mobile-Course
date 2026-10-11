import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notes_providers.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notesProvider);
    
    return Scaffold(
      // 1. Judul AppBar sesuai instruksi
      appBar: AppBar(title: const Text('Catatan Clean Architecture')),
      
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        
        // Mengganti ErrorView yang error dengan UI bawaan Flutter
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $e'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(notesProvider),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
        
        // Mengganti NotesList yang error dengan ListView.builder bawaan Flutter
        data: (notes) => notes.isEmpty
            ? const Center(child: Text('Belum ada catatan.'))
            : ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return ListTile(
                    title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(note.body),
                  );
                },
              ),
      ),
    );
  }
}