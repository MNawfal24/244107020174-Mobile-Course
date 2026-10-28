# AI Review Prompt - Week 8 AI Challenge

**Date:** 2026-10-23  
**PR Target:** `feat/week8-audit` → `develop`  
**Code Context:** Week 7 Clean Architecture (Flutter, Riverpod, SQLite)

---

## Prompt Dikirim ke AI Reviewer

```
Review PR Flutter ini sebagai senior Flutter dev.

Konteks:
- Architecture: feature-first Clean Architecture (presentation -> domain <- data)
- State Management: Riverpod
- Database: SQLite (sqflite)
- Navigation: GoRouter (jika ada)
- Target: Week 7 Clean Architecture project

Fokus Review:
1. Kebenaran (Correctness): Bug, null safety, error handling, edge cases
2. Arsitektur (Architecture): Dependency rule, layer violation, DI pattern
3. Testing: Test coverage, test cases, mockability
Abaikan: Style/formatting (akan ditangani CI)

Deliverables:
- 5 temuan teratas
- Setiap temuan: level (blocker/critical/medium/low) + alasan + usulan kode

Berikan output dalam format:
## Temuan #N
**File:** path/to/file.dart
**Line:** XX
**Level:** [blocker/critical/medium/low]
**Issue:** [Deskripsi masalah]
**Alasan:** [Mengapa ini masalah]
**Usulan Perbaikan:**
\`\`\`dart
[potongan kode perbaikan]
\`\`\`
```

---

## File yang Di-Review

AI reviewer menganalisis file-file Week 7:
1. `lib/features/notes/data/repositories/note_repository_impl.dart`
2. `lib/features/notes/domain/usecases/add_note.dart`
3. `lib/features/notes/domain/usecases/get_notes.dart`
4. `lib/features/notes/presentation/providers/notes_providers.dart`
5. `lib/features/notes/domain/entities/note.dart`
6. `lib/main.dart`

---

## Konteks Arsitektur untuk AI

```
Clean Architecture Layer Dependency:
presentation → domain ← data ← core

File Organization:
lib/
├── core/
│   ├── failures.dart (shared error types)
│   └── providers.dart (shared DI setup)
├── features/notes/
│   ├── domain/ (business logic, entities)
│   │   ├── entities/note.dart
│   │   ├── repositories/note_repository.dart (abstract)
│   │   └── usecases/ (add_note, get_notes)
│   ├── data/ (data sources, repositories implementation)
│   │   ├── models/note_model.dart
│   │   └── repositories/note_repository_impl.dart
│   └── presentation/ (UI, state management)
│       ├── pages/notes_page.dart
│       └── providers/notes_providers.dart
└── main.dart
```

State Management: Riverpod providers untuk DI + state

---

## Expected AI Review Output Format

Harapan: 5 temuan dengan prioritas kebenaran > arsitektur > testing

Contoh temuan yang diharapkan:
1. Bug/null safety issue → Blocker
2. Dependency rule violation → Critical
3. Missing error handling → Medium
4. Test coverage gap → Low
5. Performance optimization → Low

---

**Next Step:** Jalankan review, dokumentasikan di `ai-review-output.md`
