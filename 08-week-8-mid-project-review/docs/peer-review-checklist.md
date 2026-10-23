# Peer Review Checklist - Week 8 Praktikum 2

## Template Review untuk Reviewer

**PR yang direview:** `feat/week8-audit` → `develop`  
**Author:** M Nawfal  
**Reviewer:** [Nama Reviewer]  
**Tanggal:** 2026-10-23

---

## Mandatory Review Checklist (Minimal 5 Temuan)

### 1. Kebenaran (Correctness) - Minimal 2 Temuan

| No | Observasi | Severity | Status |
|----|-----------|----------|--------|
| 1.1 | File `docs/review-checklist.md` baris 42: Claim "11 dari 15 commit tidak ikuti conventional commits" - perlu verifikasi manual dengan `git log --oneline -15` | ⚠️ Medium | ✅ Verified |
| 1.2 | Tidak ada edge case handling jika repository tidak memiliki 15 commit (repo baru) | 💡 Low | 📝 Suggestion |

**Cara verifikasi:**
```bash
cd 07-week-7-clean-architecture
git log --oneline -15 | grep -v -E "^[a-f0-9]+ (feat|fix|refactor|test|docs|chore)" | wc -l
# Expected: 11
```

---

### 2. Arsitektur (Architecture) - Minimal 1 Temuan

| No | Observasi | Severity | Status |
|----|-----------|----------|--------|
| 2.1 | Dokumentasi praktikum berada di `08-week-8-mid-project-review/` tapi referensi audit mengacu ke `07-week-7-clean-architecture/` - tidak ada coupling masalah, sudah proper separation of concern | ✅ Good | 👍 Approved |

**Catatan arsitektur:**
- Week 8 adalah dokumentasi review → tidak ada dependency code dengan Week 7
- File markdown murni dokumentasi, tidak ada import/export lintas modul

---

### 3. Testing - Minimal 1 Temuan

| No | Observasi | Severity | Status |
|----|-----------|----------|--------|
| 3.1 | Dokumentasi audit tidak disertai automated test untuk validasi format commit messages | 💡 Low | 📝 Future Enhancement |

**Usulan:**
Buat script validasi commit format (opsional untuk PR ini, bisa jadi enhancement):
```bash
# .github/workflows/commit-lint.yml
# Validasi commit messages di CI
```

---

### 4. Keterbacaan (Readability) - Minimal 1 Temuan

| No | Observasi | Severity | Status |
|----|-----------|----------|--------|
| 4.1 | File `commit-refactoring.md` tabel sangat baik (3 kolom jelas: sebelum, masalah, sesudah, alasan). Namun bisa ditambahkan visual contoh diff untuk lebih jelas | 💡 Low | 📝 Optional |

**Contoh usulan:**
```diff
- Final Commit
+ feat(notes): implementasi Clean Architecture + unit tests
```

---

### 5. Bonus: Konsistensi & Best Practices

| No | Observasi | Severity | Status |
|----|-----------|----------|--------|
| 5.1 | Format markdown konsisten (heading, tabel, code block) | ✅ Good | 👍 |
| 5.2 | README.md menggunakan emoji status (✅ ❌ ⏳) yang memudahkan scanning visual | ✅ Good | 👍 |
| 5.3 | Commit messages PR author sudah ikuti conventional commits sendiri (meta!) | ✅ Good | 👍 |

---

## Summary Review

### Findings Breakdown
- **Blocker:** 0
- **Critical:** 0
- **Medium:** 1 (verifikasi claim 11 commit)
- **Low/Suggestion:** 3

### Decision
**✅ APPROVE dengan catatan kecil (non-blocking)**

### Reasoning
1. Dokumentasi lengkap dan terstruktur
2. Tabel perbaikan commit jelas dan konkret
3. Tidak ada bug/error path karena murni dokumentasi
4. Commit messages author sudah mengikuti standar yang diaudit (konsisten)
5. Temuan minor bersifat enhancement, tidak menghambat merge

### Action Items untuk Author
- [ ] (Optional) Tambah visual diff contoh di `commit-refactoring.md`
- [ ] (Optional) Pertimbangkan commit-lint automation di future PR

---

## Review Comments Pattern (Observasi → Dampak → Usulan)

### ✅ Contoh Komentar Baik
```
Observasi: Tabel commit refactoring sangat detail (type, scope, alasan).
Dampak: Memudahkan developer lain memahami format conventional commits.
Usulan: (none, already excellent)
Keputusan: Approve
```

### ❌ Contoh Komentar Buruk
```
"Bagus nih" → tidak ada observasi spesifik
"Perbaiki tabelnya" → tidak jelas apa yang harus diperbaiki
```

---

**Reviewer Signature:** [Nama Reviewer]  
**Review Date:** 2026-10-23  
**Re-review Required:** No (Approve langsung)
