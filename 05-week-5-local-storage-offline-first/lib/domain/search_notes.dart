import '../data/local/note.dart';
import '../data/repositories/note_repository.dart';

class SearchNotes {
  const SearchNotes(this._repository);
  final NoteRepository _repository;

  static final _spaces = RegExp(r'\s+');

  static String normalize(String value) {
    return value.trim().toLowerCase().replaceAll(_spaces, ' ');
  }

  static List<Note> filter(List<Note> notes, String query) {
    final q = normalize(query);
    if (q.isEmpty) return notes;
    return notes.where((n) => normalize(n.title).contains(q)).toList();
  }

  static String emptyMessage(String query) {
    return normalize(query).isEmpty
        ? 'Belum ada catatan.'
        : 'Tidak ada catatan dengan judul tersebut.';
  }

  Future<List<Note>> call([String query = '']) async {
    final notes = await _repository.fetchNotes();
    return filter(notes, query);
  }
}
