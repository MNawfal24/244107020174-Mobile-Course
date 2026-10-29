import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/note.dart';
import '../data/providers.dart';
import '../domain/search_notes.dart';
import 'note_title.dart';

class NotesBody extends ConsumerWidget {
  const NotesBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesState = ref.watch(notesListNotifierProvider);
    final query = ref.watch(searchQueryProvider);

    return notesState.when(
      data: (notes) => _NotesDataView(notes: notes, query: query),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _NotesErrorView(message: '$error'),
    );
  }
}

class _NotesDataView extends ConsumerWidget {
  const _NotesDataView({required this.notes, required this.query});

  final List<Note> notes;
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (notes.isEmpty) {
      return Center(child: Text(SearchNotes.emptyMessage(query)));
    }
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return NoteTile(
          note: note,
          onDelete: () async {
            if (note.id != null) {
              await ref
                  .read(notesListNotifierProvider.notifier)
                  .deleteNote(note.id!);
            }
          },
        );
      },
    );
  }
}

class _NotesErrorView extends ConsumerWidget {
  const _NotesErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Terjadi kesalahan: $message'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () =>
                ref.read(notesListNotifierProvider.notifier).loadNotes(),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}
