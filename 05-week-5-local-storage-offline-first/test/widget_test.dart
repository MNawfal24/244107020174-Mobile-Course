import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week5_offline/data/local/note.dart';
import 'package:week5_offline/data/providers.dart';
import 'package:week5_offline/data/repositories/note_repository.dart';
import 'package:week5_offline/main.dart';

class FakeNoteRepository extends NoteRepository {
  @override
  Future<List<Note>> fetchNotes() async => const <Note>[];
}

void main() {
  testWidgets('App smoke test loads without crashing', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          noteRepositoryProvider.overrideWithValue(FakeNoteRepository()),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Offline Notes'), findsOneWidget);
  });
}
