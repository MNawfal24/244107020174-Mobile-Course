# Week 8 - Mid Project Review & Code Review

**Praktikum:** Audit Riwayat, GitFlow Branching, Commit Convention, dan Peer Code Review

**Repository:** [244107020174-Mobile-Course](https://github.com/MNawfal24/244107020174-Mobile-Course)

**Target Project:** Week 7 Clean Architecture (`07-week-7-clean-architecture`)

---

## Praktikum 1: Audit Riwayat & Simulasi Branching

### 1.1 Audit Git History Week 7

**Perintah yang dijalankan:**
```bash
git log --oneline -15
git branch -a
git status
```

**Hasil Audit:**

#### Git Log (15 commit terakhir)
```
60271ac Final Commit
2d63f8e Commit praktikum 1-3
e8a9e89 Commit Akhir
d04de85 Commit Refactoring
89df1ee Commit AI Challenge
744e6d3 Commit Prakikum 3
fea7c00 Commit Praktikum 2
3ab42af Praktikum 1
1cff4ca commit awal
1ca22e8 Commit Akhir setelah aplikasi bisa di run di handphone
1af7668 commit Pembenaran Sehingga bisa Run di handPhone
7337856 Commit Finalll
6717b3c Commit Final
7914c5e Commit Praktikum 2
e35f9a4 Commit Praktikum 1
```

#### Branch Status
```
* main
  remotes/244107020174-Mobile-Course/main
```

**Masalah yang ditemukan:**
- ❌ Hanya ada branch `main`, belum ada `develop`
- ❌ 11 dari 15 commit tidak ikuti conventional commits (tidak ada prefix `feat`, `fix`, `refactor`, dll)
- ❌ Semua commit tidak memiliki scope (modul/layer mana yang berubah)
- ❌ Pesan commit generik: "Final Commit", "Akhir", "Finalll" → tidak jelas perubahan apa
- ❌ Tidak ada issue tracking reference (`Closes #X`)
- ❌ Banyak commit berulang dengan nama sama ("Commit Final", "Commit Akhir")

---

### 1.2 Perbaikan Commit Messages (Simulasi)

Tabel perbaikan commit messages lama ke format conventional commits:

| Commit Lama | Hash | Masalah | Commit Diperbaiki | Alasan |
|-------------|------|---------|-------------------|--------|
| `Final Commit` | 60271ac | Tidak spesifik, tanpa tipe/scope | `feat(notes): implementasi Clean Architecture + unit tests` | Jelas: tipe (feat), scope (notes), perubahan (Clean Arch), bukti (tests) |
| `Commit Refactoring` | d04de85 | Vague, tidak jelas refactor apa | `refactor(data): pisahkan repository dari data source + DI` | Jelas: layer (data), detail refactor (pemisahan concern), pola (DI) |
| `Commit Akhir setelah aplikasi bisa di run di handphone` | 1ca22e8 | Terlalu panjang, tidak terstruktur, tanpa tipe | `fix(android): sesuaikan gradle minSdkVersion untuk device` | Jelas: tipe (fix), platform (android), masalah + solusi spesifik |

**Format Conventional Commits yang digunakan:**
```
<tipe>(<scope>): <deskripsi singkat> + <bukti>

Tipe: feat, fix, refactor, test, docs, chore
Scope: layer/modul yang berubah (notes, auth, data, presentation, dll)
Deskripsi: singkat, jelas, imperatif
Bukti: mention test, PR, atau perubahan terukur
```

---

### 1.3 GitFlow Branching Model (Simulasi Lokal)

**Alur kerja yang benar:**

```
main (protected)
  ↓
develop (integrasi mingguan)
  ├─→ feature/week8-audit (branch kerja sementara)
  │   ├─ docs/review-checklist.md
  │   └─ commit: "docs(review): audit commit Week 7 + perbaikan"
  │
  ├─→ feature/notes-validation
  └─→ fix/auth-crash
```

**Step yang sudah dilakukan (lokal):**

1. ✅ Buat file `docs/review-checklist.md` di `08-week-8-mid-project-review/`
2. ✅ Dokumentasikan audit commit Week 7
3. **Siap:** Branch `develop` akan dibuat dari `main`
4. **Siap:** Branch `feat/week8-audit` akan dibuat dari `develop`
5. **Siap:** File akan di-commit dengan pesan conventional: `docs(review): audit commit Week 7 + perbaikan`
6. **Siap:** Push ke remote (menunggu approval sebelum push)

---

## File yang Dibuat

### `docs/review-checklist.md`
- Tabel audit commit messages (3 contoh perbaikan)
- 4 temuan masalah commit history
- Action items (setup branch, CI, issue tracking)
- Checklist kesiapan mid semester

---

## Status Kesiapan Mid Semester Week 7

| Aspek | Status | Catatan |
|-------|--------|---------|
| **Commit Convention** | ❌ Belum | Perlu perbaikan format (`feat`, `fix`, `refactor`) |
| **Branch Model** | ❌ Belum | Hanya `main`, perlu buat `develop` |
| **Peer Review** | ⏳ Pending | Akan dilakukan di Praktikum 2 |
| **Static Analysis** | ? | Perlu cek `flutter analyze` dan `flutter test` |
| **CI Pipeline** | ❌ Belum | Perlu setup GitHub Actions |
| **Issue Tracking** | ❌ Belum | Tidak ada issue tracking reference di commit |

---

## Next Steps (Praktikum 1 Lanjutan)

### Praktikum 1 No. 2: Buat Branch Kerja yang Benar
- [ ] Buat branch `develop` dari `main`
- [ ] Buat branch `feat/week8-audit` dari `develop`
- [ ] Commit file `review-checklist.md` dengan pesan: `docs(review): audit commit Week 7 + perbaikan`
- [ ] Push ke remote (branch `feat/week8-audit`)

### Praktikum 1 No. 3: Perbaiki Satu Commit Buruk
- [ ] Buat file `docs/commit-refactoring.md` yang menunjukkan:
  - Tabel sebelum/sesudah 3 commit lama
  - Alasan perbaikan
  - Bukti perbaikan

---

## Referensi

- [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
- [Atlassian: GitFlow Workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow)
- [GitHub: Pull Request Reviews](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/reviewing-changes-in-pull-requests/about-pull-request-reviews)
- [Dart: Linter Rules](https://dart.dev/tools/linter-rules)
- [Flutter: Static Analysis](https://docs.flutter.dev/tools/using-ide)

---

**Dibuat:** 2026-10-23  
**Status:** Praktikum 1 No. 1 selesai, siap Praktikum 1 No. 2
