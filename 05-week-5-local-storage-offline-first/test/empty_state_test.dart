import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week5_offline/data/local/note.dart';
import 'package:week5_offline/data/providers.dart';
import 'package:week5_offline/data/repositories/note_repository.dart';
import 'package:week5_offline/widgets/notes_body.dart';

class EmptyNoteRepository extends NoteRepository {
  @override
  Future<List<Note>> fetchNotes() async => const <Note>[];

  @override
  Future<Note> addNote({required String title, String body = ''}) {
    throw UnimplementedError();
  }
}

void main() {
  testWidgets('empty state tampil saat hasil search kosong', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          noteRepositoryProvider.overrideWithValue(EmptyNoteRepository()),
        ],
        child: const MaterialApp(home: Scaffold(body: NotesBody())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Belum ada catatan.'), findsOneWidget);
  });
}
