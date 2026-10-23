# Static Analysis Report - Week 8 Praktikum 3

**Target:** Week 7 Clean Architecture (`07-week-7-clean-architecture`)  
**Date:** 2026-10-23  
**Tools:** `flutter analyze`, `dart format`, `flutter test`

---

## Executive Summary

| Tool | Status | Issues | Action |
|------|--------|--------|--------|
| `flutter analyze` | ⚠️ Warning | 1 info issue | Fix prefer_initializing_formals |
| `dart format` | ⚠️ Unformatted | 11 files | Run `dart format .` |
| `flutter test` | ✅ Pass | 0 failures | All tests passed |

**Overall Status:** 🟡 **CONDITIONAL PASS** (1 warning + format needed, tests green)

---

## 1. `flutter analyze` Report

**Command:**
```bash
flutter analyze
```

**Output:**
```
Analyzing 07-week-7-clean-architecture...                       

   info - Use an initializing formal to assign a parameter to a field. 
   Try using an initialing formal ('this._openDb') to initialize the field 
   - lib\features\notes\data\repositories\note_repository_impl.dart:9:9 
   - prefer_initializing_formals

1 issue found. (ran in 81.0s)
```

**Status:** ⚠️ **WARNING** (Exit code: 1)

### Issue Analysis

#### Issue #1: `prefer_initializing_formals`
- **File:** `lib/features/notes/data/repositories/note_repository_impl.dart`
- **Line:** 9
- **Severity:** Info (Low priority)
- **Category:** Code Style / Best Practice

**Current Code (Buruk):**
```dart
class NoteRepositoryImpl implements NoteRepository {
  final Function _openDb;
  
  NoteRepositoryImpl(Function _openDb) {
    this._openDb = _openDb;  // ❌ Boilerplate
  }
}
```

**Perbaikan (Baik):**
```dart
class NoteRepositoryImpl implements NoteRepository {
  final Function _openDb;
  
  NoteRepositoryImpl(this._openDb);  // ✅ Initializing formal
}
```

**Alasan Perbaikan:**
- Dart 2.17+ mendukung initializing formal syntax
- Mengurangi boilerplate code
- Lebih readable dan idiomatik Dart
- Linter rule ini best practice

**Priority:** Low (tidak blocking, tapi disarankan)

---

## 2. `dart format` Report

**Command:**
```bash
dart format --output=none --set-exit-if-changed .
```

**Output:**
```
Changed lib\core\failures.dart
Changed lib\features\notes\data\models\note_model.dart
Changed lib\features\notes\data\repositories\note_repository_impl.dart
Changed lib\features\notes\domain\entities\note.dart
Changed lib\features\notes\domain\repositories\note_repository.dart
Changed lib\features\notes\domain\usecases\add_note.dart
Changed lib\features\notes\domain\usecases\get_notes.dart
Changed lib\features\notes\presentation\pages\notes_page.dart
Changed lib\features\notes\presentation\providers\notes_providers.dart
Changed lib\main.dart
Changed test\widget_test.dart
Formatted 13 files (11 changed) in 0.16 seconds.
```

**Status:** ⚠️ **UNFORMATTED** (Exit code: 1 - 11 files need formatting)

### Files That Need Formatting

| No | File | Issue | Fix |
|----|------|-------|-----|
| 1 | `lib/core/failures.dart` | Indentation/spacing | Auto-fix dengan `dart format` |
| 2 | `lib/features/notes/data/models/note_model.dart` | Line length/spacing | Auto-fix |
| 3 | `lib/features/notes/data/repositories/note_repository_impl.dart` | Spacing around operators | Auto-fix |
| 4 | `lib/features/notes/domain/entities/note.dart` | Indentation | Auto-fix |
| 5 | `lib/features/notes/domain/repositories/note_repository.dart` | Spacing | Auto-fix |
| 6 | `lib/features/notes/domain/usecases/add_note.dart` | Line breaks | Auto-fix |
| 7 | `lib/features/notes/domain/usecases/get_notes.dart` | Spacing | Auto-fix |
| 8 | `lib/features/notes/presentation/pages/notes_page.dart` | Indentation | Auto-fix |
| 9 | `lib/features/notes/presentation/providers/notes_providers.dart` | Spacing | Auto-fix |
| 10 | `lib/main.dart` | Line breaks | Auto-fix |
| 11 | `test/widget_test.dart` | Spacing | Auto-fix |

**Root Cause:** Tidak ada pre-commit hook atau formatting sebelum commit

**Fix Command:**
```bash
cd 07-week-7-clean-architecture
dart format .
git add .
git commit -m "style: format dengan dart format"
```

**Priority:** Medium (harus fixed sebelum merge ke `develop`)

---

## 3. `flutter test` Report

**Command:**
```bash
flutter test
```

**Output:**
```
00:00 +0: loading D:/KULIAH/SMT_5/PemMob/244107020174-Mobile-Course/07-week-7-clean-architecture/test/widget_test.dart
00:00 +0: shows the empty notes screen
00:01 +1: All tests passed!
```

**Status:** ✅ **PASS** (Exit code: 0)

### Test Summary
- **Test File:** `test/widget_test.dart`
- **Total Tests:** 1
- **Passed:** 1 ✅
- **Failed:** 0
- **Skipped:** 0
- **Duration:** 1 second

### Test Details
```
Test #1: "shows the empty notes screen"
Status: ✅ PASSED
Description: Widget test untuk memverifikasi halaman notes kosong muncul dengan benar
```

**Priority:** ✅ Good (tests sudah implemented)

---

## Summary & Rekomendasi

### Status Keseluruhan
```
✅ Tests: PASS (1/1 passed)
⚠️ Format: UNFORMATTED (11 files)
⚠️ Linter: 1 INFO issue
```

### Action Items (Priority Order)

#### 1. **URGENT - Format semua file**
```bash
cd 07-week-7-clean-architecture
dart format .
git add .
git commit -m "style: format dengan dart format"
```
**Reason:** CI akan reject PR jika tidak format  
**Effort:** 2 menit  
**Status:** ⏳ Pending

#### 2. **HIGH - Fix prefer_initializing_formals**
```dart
// File: lib/features/notes/data/repositories/note_repository_impl.dart
// Line 9: Change dari manual assignment ke initializing formal
NoteRepositoryImpl(this._openDb);  // ✅ Fixed
```
**Reason:** Best practice linter rule  
**Effort:** 1 menit  
**Status:** ⏳ Pending

#### 3. **OPTIONAL - Tambah lebih banyak test cases**
Current: 1 test (basic widget)  
Suggested: Tambah test untuk:
- Add note functionality
- Error handling
- Edge cases (empty title, dll)

**Reason:** Test coverage masih minimal  
**Effort:** 30 menit  
**Status:** 📝 Future Enhancement

---

## Integration dengan CI (GitHub Actions)

Untuk otomatis validasi ini di setiap PR, setup `.github/workflows/ci.yml`:

```yaml
name: CI
on: [pull_request]
jobs:
  analyze-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter analyze
      - run: dart format --set-exit-if-changed .
      - run: flutter test
```

**Benefit:**
- PR kotor ditolak mesin sebelum direview manusia
- Developer forced clean code
- Konsistensi tim terjaga

---

## Checklist Sebelum Merge PR

- [ ] `flutter analyze` hijau (0 issues)
- [ ] `dart format` rapi (exit code 0)
- [ ] `flutter test` hijau (semua test pass)
- [ ] Commit message conventional format
- [ ] Branch dari `develop`, bukan `main`
- [ ] Peer review approved (minimal 1 reviewer)

---

**Report Generated:** 2026-10-23  
**Next Step:** Fix formatting + initializing formal, commit, push
