import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/search_notes.dart';
import 'local/note.dart';
import 'repositories/note_repository.dart';
// Import file terkait lainnya yang sudah Anda miliki

// ---------------------------------------------------------
// [BARU] 1. Toggle Simulasi Offline (Deterministik)
// ---------------------------------------------------------
// Provider ini bisa Anda hubungkan ke widget Switch di halaman Settings.
// Jika bernilai true, aplikasi pura-pura tidak punya internet.
class ForceOfflineNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle(bool value) {
    state = value;
  }
}

final forceOfflineProvider = NotifierProvider<ForceOfflineNotifier, bool>(ForceOfflineNotifier.new);

// ---------------------------------------------------------
// [BARU] 2. Logika Sinkronisasi Catatan Kotor (Praktikum 3)
// ---------------------------------------------------------
Future<int> syncNotes(NoteRepository repo) async {
  // Hitung jumlah catatan yang belum terkirim ke server (dirty = 1)
  final dirtyCount = await repo.countDirty();
  if (dirtyCount == 0) return 0; // Jika tidak ada, hentikan

  // Simulasi upload: pada project nyata, kirim tiap catatan dirty
  // ke REST API di sini, lalu tandai bersih bila server menjawab 2xx.
  
  await Future.delayed(const Duration(seconds: 1)); // Simulasi jeda internet 1 detik
  await repo.markAllSynced(); // Ubah semua status dirty menjadi 0
  
  return dirtyCount;
}

// ---------------------------------------------------------
// [BARU] 3. Provider NoteRepository
// ---------------------------------------------------------
final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepository();
});

// ---------------------------------------------------------
// [MINGGU 9] Provider Search & Notes List Notifier
// ---------------------------------------------------------
final searchNotesUseCaseProvider = Provider<SearchNotes>((ref) {
  return SearchNotes(ref.watch(noteRepositoryProvider));
});

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String value) => state = value;
}

final notesListNotifierProvider =
    AsyncNotifierProvider<NotesListNotifier, List<Note>>(
  NotesListNotifier.new,
);

class NotesListNotifier extends AsyncNotifier<List<Note>> {
  int _searchVersion = 0;

  @override
  Future<List<Note>> build() => _search('');

  Future<List<Note>> _search(String query) async {
    final searchNotes = ref.read(searchNotesUseCaseProvider);
    return searchNotes.call(query);
  }

  Future<void> loadNotes() async {
    final version = ++_searchVersion;
    state = const AsyncLoading();
    final nextState = await AsyncValue.guard(
      () => _search(ref.read(searchQueryProvider)),
    );
    if (version == _searchVersion) state = nextState;
  }

  Future<void> search(String query) async {
    final version = ++_searchVersion;
    ref.read(searchQueryProvider.notifier).setQuery(query);
    final nextState = await AsyncValue.guard(() => _search(query));
    if (version == _searchVersion) state = nextState;
  }

  Future<void> deleteNote(int id) async {
    final repo = ref.read(noteRepositoryProvider);
    await repo.deleteNote(id);
    await loadNotes();
  }
}