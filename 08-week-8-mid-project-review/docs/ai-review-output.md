# AI Review Output - Week 8 AI Challenge

**AI Reviewer:** Kiro (AI Senior Flutter Developer)  
**Date:** 2026-10-23  
**PR Reviewed:** Week 7 Clean Architecture - Notes Feature  
**Context:** feature-first Clean Architecture, Riverpod, SQLite

---

## Temuan #1: File Name Mismatch dengan Class Name

**File:** `lib/features/notes/domain/usecases/add_note.dart`  
**Line:** 6  
**Level:** 🔴 **BLOCKER**  
**Issue:** File bernama `add_note.dart` tapi berisi class `GetNotes` (seharusnya `AddNote`)

**Alasan:**
- Melanggar konvensi penamaan Dart (1 file = 1 class dengan nama sama)
- Menyebabkan confusion untuk developer lain
- IDE navigation akan misleading
- Berpotensi bug saat import (developer kira import AddNote, dapat GetNotes)

**Usulan Perbaikan:**
```dart
// File: lib/features/notes/domain/usecases/add_note.dart
import '../../../../core/failures.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

class AddNote {  // ✅ Sesuai nama file
  const AddNote(this._repository);
  final NoteRepository _repository;

  Future<({Note? note, Failure? failure})> call({
    required String title,
    String body = '',
  }) {
    return _repository.addNote(title: title, body: body);
  }
}
```

**Evidence:**
```bash
# Verifikasi: File add_note.dart berisi class GetNotes
grep "class GetNotes" 07-week-7-clean-architecture/lib/features/notes/domain/usecases/add_note.dart
# Output: class GetNotes (line 6) ✅ CONFIRMED BUG
```

---

## Temuan #2: Duplicate Class `GetNotes` di Dua File

**File:** `lib/features/notes/domain/usecases/get_notes.dart` & `add_note.dart`  
**Line:** get_notes.dart:5, add_note.dart:6  
**Level:** 🔴 **CRITICAL**  
**Issue:** Class `GetNotes` didefinisikan di dua file berbeda (duplicate)

**Alasan:**
- Menyebabkan compile error atau ambiguous import
- Copy-paste error yang tidak tertangkap
- Melanggar DRY principle
- Salah satu file tidak berfungsi sesuai tujuan

**Usulan Perbaikan:**
Pastikan setiap usecase memiliki class unique:
- `get_notes.dart` → class `GetNotes`
- `add_note.dart` → class `AddNote` (bukan `GetNotes`)

```dart
// File: lib/features/notes/domain/usecases/add_note.dart (PERBAIKAN)
import '../../../../core/failures.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

class AddNote {
  const AddNote(this._repository);
  final NoteRepository _repository;

  Future<({Note? note, Failure? failure})> call({
    required String title,
    String body = '',
  }) {
    return _repository.addNote(title: title, body: body);
  }
}
```

**Impact:** High - Fitur add note tidak berfungsi karena class salah

---

## Temuan #3: Missing Validation di Domain UseCase

**File:** `lib/features/notes/domain/usecases/add_note.dart` (setelah diperbaiki)  
**Line:** Belum ada  
**Level:** 🟠 **MEDIUM**  
**Issue:** UseCase `AddNote` tidak ada validasi input (title kosong, panjang maksimal, dll)

**Alasan:**
- Domain layer adalah tempat business rules
- Validasi di UI saja mudah dibypass
- Data kotor bisa masuk ke database
- Tidak ada garantee data integrity

**Usulan Perbaikan:**
```dart
// File: lib/features/notes/domain/usecases/add_note.dart
import '../../../../core/failures.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

class AddNote {
  const AddNote(this._repository);
  final NoteRepository _repository;

  Future<({Note? note, Failure? failure})> call({
    required String title,
    String body = '',
  }) async {
    // ✅ Business rule validation di domain
    if (title.trim().isEmpty) {
      return (
        note: null,
        failure: ValidationFailure('Judul tidak boleh kosong'),
      );
    }
    
    if (title.length > 200) {
      return (
        note: null,
        failure: ValidationFailure('Judul maksimal 200 karakter'),
      );
    }

    return _repository.addNote(title: title.trim(), body: body.trim());
  }
}
```

Tambahkan `ValidationFailure` di `core/failures.dart`:
```dart
sealed class Failure {
  const Failure(this.message);
  final String message;
}

class LocalFailure extends Failure {
  const LocalFailure(super.message);
}

class ValidationFailure extends Failure {  // ✅ Baru
  const ValidationFailure(super.message);
}
```

**Test Case yang Perlu Ditambahkan:**
```dart
test('AddNote should fail when title is empty', () async {
  final result = await addNote(title: '', body: 'test');
  expect(result.failure, isA<ValidationFailure>());
  expect(result.note, isNull);
});
```

---

## Temuan #4: Presentation Layer Langsung Import Data Layer

**File:** `lib/features/notes/presentation/providers/notes_providers.dart`  
**Line:** 7  
**Level:** 🟡 **MEDIUM**  
**Issue:** Provider import langsung `NoteRepositoryImpl` dari data layer

**Alasan:**
- Melanggar dependency rule Clean Architecture (presentation → domain, bukan → data)
- Coupling tinggi antara presentation dan data
- Sulit untuk swap repository implementation (mock untuk test)
- Idealnya presentation hanya tahu abstraksi (NoteRepository interface)

**Current Code:**
```dart
// ❌ Direct import dari data layer
import '../../data/repositories/note_repository_impl.dart';

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepositoryImpl(openDb: openNotesDb);
});
```

**Usulan Perbaikan:**
Pindahkan setup DI ke `lib/core/providers.dart` atau `main.dart`:

```dart
// File: lib/core/providers.dart (atau di main.dart)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/notes/data/repositories/note_repository_impl.dart';
import '../features/notes/domain/repositories/note_repository.dart';
import '../features/notes/presentation/providers/notes_providers.dart' 
    show openNotesDb;

// ✅ DI setup di core layer
final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepositoryImpl(openDb: openNotesDb);
});
```

```dart
// File: lib/features/notes/presentation/providers/notes_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ✅ Hanya import domain (abstraksi), tidak import data
import '../../domain/repositories/note_repository.dart';
import '../../domain/usecases/get_notes.dart';
import '../../../../core/providers.dart'; // Import DI dari core

// Presentation hanya konsumsi abstraksi
final getNotesProvider = Provider<GetNotes>((ref) {
  return GetNotes(ref.watch(noteRepositoryProvider));
});
```

**Catatan:** Untuk project kecil ini acceptable, tapi untuk scaling lebih baik pindahkan DI setup ke core.

**Priority:** Medium (current structure masih bekerja, tapi less clean)

---

## Temuan #5: Missing Unit Test untuk Domain UseCases

**File:** `test/` directory  
**Line:** N/A  
**Level:** 🟡 **LOW**  
**Issue:** Hanya ada 1 widget test, tidak ada unit test untuk domain layer (usecases, entities)

**Alasan:**
- Domain layer paling mudah ditest (pure Dart, no Flutter dependency)
- Clean Architecture benefit utama: testability
- Tidak ada test untuk business logic (add note, validation)
- Test coverage rendah

**Usulan Perbaikan:**
```dart
// File: test/features/notes/domain/usecases/add_note_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notes_app/core/failures.dart';
import 'package:notes_app/features/notes/domain/entities/note.dart';
import 'package:notes_app/features/notes/domain/repositories/note_repository.dart';
import 'package:notes_app/features/notes/domain/usecases/add_note.dart';

class MockNoteRepository extends Mock implements NoteRepository {}

void main() {
  late AddNote addNote;
  late MockNoteRepository mockRepository;

  setUp(() {
    mockRepository = MockNoteRepository();
    addNote = AddNote(mockRepository);
  });

  group('AddNote UseCase', () {
    test('should return note when repository succeeds', () async {
      // Arrange
      const title = 'Test Note';
      const body = 'Test Body';
      final expectedNote = Note(
        id: 1,
        title: title,
        body: body,
        updatedAt: DateTime.now(),
        dirty: true,
      );
      
      when(() => mockRepository.addNote(title: title, body: body))
          .thenAnswer((_) async => (note: expectedNote, failure: null));

      // Act
      final result = await addNote(title: title, body: body);

      // Assert
      expect(result.note, expectedNote);
      expect(result.failure, isNull);
      verify(() => mockRepository.addNote(title: title, body: body)).called(1);
    });

    test('should return ValidationFailure when title is empty', () async {
      // Act
      final result = await addNote(title: '', body: 'test');

      // Assert
      expect(result.note, isNull);
      expect(result.failure, isA<ValidationFailure>());
      expect(result.failure?.message, contains('kosong'));
      verifyNever(() => mockRepository.addNote(title: any(named: 'title'), body: any(named: 'body')));
    });
  });
}
```

Tambahkan dependency di `pubspec.yaml`:
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.0  # ✅ Untuk mocking
```

**Priority:** Low (good to have, tapi tidak blocking untuk merge dokumentasi Week 8)

---

## Summary AI Review

| Temuan | Level | Status | Actionable |
|--------|-------|--------|------------|
| #1: File/class name mismatch | 🔴 Blocker | Must Fix | ✅ Yes |
| #2: Duplicate GetNotes class | 🔴 Critical | Must Fix | ✅ Yes |
| #3: Missing domain validation | 🟠 Medium | Recommended | ✅ Yes |
| #4: Presentation imports data | 🟡 Medium | Optional | 📝 Future |
| #5: Missing unit tests | 🟡 Low | Good to have | 📝 Future |

**Overall Assessment:**
- **Blocker:** 2 (file naming, duplicate class) → **MUST FIX BEFORE MERGE**
- **Medium:** 2 (validation, DI placement) → Recommended
- **Low:** 1 (test coverage) → Future improvement

**Recommendation:** Request Changes untuk fix Temuan #1 dan #2 (blocker), lalu re-review.

---

**AI Reviewer:** Kiro  
**Review Completed:** 2026-10-23  
**Next Step:** Verifikasi temuan AI dengan manual check + grep/test
