import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week5_offline/data/local/note.dart';
import 'package:week5_offline/data/repositories/note_repository.dart';
import 'package:week5_offline/data/providers.dart';
import 'package:week5_offline/domain/search_notes.dart';

class FakeNoteRepository extends NoteRepository {
  FakeNoteRepository({this.items = const [], this.fail = false});

  final List<Note> items;
  final bool fail;

  @override
  Future<List<Note>> fetchNotes() async {
    if (fail) {
      throw Exception('db locked (simulasi)');
    }
    return items;
  }

  @override
  Future<Note> addNote({
    required String title,
    String body = '',
  }) {
    throw UnimplementedError();
  }
}

class DelayedSearchNotes extends SearchNotes {
  DelayedSearchNotes(this.responses) : super(FakeNoteRepository());

  final Map<String, Future<List<Note>>> responses;

  @override
  Future<List<Note>> call([String query = '']) async {
    return await responses[query]!;
  }
}

void main() {
  test('SearchNotes meneruskan daftar dari repository', () async {
    final repo = FakeNoteRepository(
      items: [Note(title: 'A', updatedAt: DateTime(2026, 9, 27))],
    );
    final result = await SearchNotes(repo).call();
    expect(result.length, 1);
    expect(result.first.title, 'A');
  });

  test('SearchNotes empty state saat judul tidak cocok', () async {
    final repo = FakeNoteRepository(
      items: [Note(title: 'Rapat Dosen', updatedAt: DateTime(2026, 9, 27))],
    );
    final result = await SearchNotes(repo).call('ujian');
    expect(result, isEmpty);
  });

  final list = [
    Note(title: 'Belanja Mingguan', updatedAt: DateTime(2026, 9, 27)),
    Note(title: 'Daftar belanja', updatedAt: DateTime(2026, 9, 27)),
    Note(title: 'Rapat', updatedAt: DateTime(2026, 9, 27)),
  ];

  test('filter abaikan huruf besar/kecil', () {
    expect(SearchNotes.filter(list, 'belanja'), hasLength(2));
  });

  test('query tak cocok kembalikan kosong', () {
    expect(SearchNotes.filter(list, 'zzz-tak-ada'), isEmpty);
  });

  test('query kosong mengembalikan semua catatan', () {
    expect(SearchNotes.filter(list, '  '), hasLength(3));
  });

  // Test merah: judul ada, tetapi query "belanja  mingguan" (dua spasi)
  // saat ini tidak cocok jika contains() membandingkan string mentah.
  test('filter abaikan spasi berlebih pada query', () {
    expect(SearchNotes.filter(list, 'belanja  mingguan'), hasLength(1));
  });

  test('hasil search lama tidak menimpa query terbaru', () async {
    final initial = Future.value(<Note>[]);
    final oldSearch = Completer<List<Note>>();
    final newSearch = Completer<List<Note>>();
    final container = ProviderContainer(
      overrides: [
        searchNotesUseCaseProvider.overrideWithValue(
          DelayedSearchNotes({
            '': initial,
            'lama': oldSearch.future,
            'baru': newSearch.future,
          }),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(notesListNotifierProvider.future);
    final notifier = container.read(notesListNotifierProvider.notifier);
    final oldRequest = notifier.search('lama');
    final newRequest = notifier.search('baru');
    newSearch.complete([
      Note(title: 'Hasil Baru', updatedAt: DateTime(2026, 9, 27)),
    ]);
    await newRequest;
    oldSearch.complete([
      Note(title: 'Hasil Lama', updatedAt: DateTime(2026, 9, 27)),
    ]);
    await oldRequest;

    final result = container.read(notesListNotifierProvider).requireValue;
    expect(result.single.title, 'Hasil Baru');
  });
}
