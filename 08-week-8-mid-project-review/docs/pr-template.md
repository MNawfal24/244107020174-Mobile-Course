# PR Template - Week 8 Praktikum 2

## Judul
`docs(review): audit commit Week 7 + perbaikan convention`

---

## Deskripsi PR

### Masalah (Problem)
Project Week 7 (Clean Architecture) memiliki riwayat commit yang tidak konsisten:
- 11 dari 15 commit tidak mengikuti conventional commits
- Tidak ada scope (layer/modul) pada pesan commit
- Pesan commit generik dan ambigu ("Final Commit", "Akhir", "Finalll")
- Tidak ada issue tracking reference pada commit
- Menyulitkan reviewer, maintainer, dan automation tools untuk memahami history

### Solusi (Solution)
1. Membuat dokumentasi audit lengkap commit history Week 7
2. Menyediakan panduan perbaikan commit messages ke format conventional commits
3. Membuat tabel perbandingan sebelum/sesudah dengan alasan detail
4. Mengimplementasikan GitFlow branching model (`main` → `develop` → `feature/*`)
5. Menyediakan checklist dan template untuk PR berkualitas ke depan

### Cara Uji (How to Test)
1. Buka file `docs/review-checklist.md` → lihat tabel audit 3 commit diperbaiki
2. Buka file `docs/commit-refactoring.md` → lihat analisis format conventional commits
3. Buka `README.md` → lihat dokumentasi lengkap GitFlow workflow
4. Cek branch lokal: `git branch -a` → harus ada `develop` dan `feat/week8-audit`
5. Cek commit history: `git log --oneline feat/week8-audit` → 2 commit dengan format konvensional

### Screenshot / Bukti
```
Branch status:
  develop
* feat/week8-audit

Commit messages:
8544105 docs(review): tambah analisis commit refactoring + update README
9890f5c docs(review): audit commit Week 7 + perbaikan convention

Files created:
✓ docs/review-checklist.md
✓ docs/commit-refactoring.md
✓ README.md
```

### Closes
Closes #0 (Issue tracking akan ditambahkan di Praktikum 2 kelanjutan)

---

## Checklist PR Author
- [x] Commit messages mengikuti conventional commits format
- [x] Branch dibuat dari `develop`, bukan `main`
- [x] File sudah di-review lokal sebelum push
- [x] Ukuran PR kecil (< 300 baris perubahan)
- [x] PR mengkomunikasikan masalah → solusi → cara uji

---

## Related Links
- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitFlow Workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow)
- Modul: https://jti-polinema.github.io/flutter-codelab/08-minggu-8-mid-project-review-code-review/
