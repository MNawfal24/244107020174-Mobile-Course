# Review Checklist - Week 8

## Audit Commit Messages Week 7

Audit dari repository Week 7 Clean Architecture (`07-week-7-clean-architecture`)

### Tabel Perbaikan Commit Messages

| Commit Lama | Hash | Masalah | Commit Diperbaiki | Alasan Perbaikan |
|-------------|------|---------|-------------------|------------------|
| Final Commit | 60271ac | Tidak spesifik, tidak ada tipe/scope | `feat(notes): implementasi Clean Architecture + unit tests` | Jelas tipe (feat), scope (notes), perubahan (Clean Arch), bukti (tests) |
| Commit Refactoring | d04de85 | Kurang scope dan detail refactor apa | `refactor(data): pisahkan repository dari data source + DI` | Jelas layer (data), refactor apa (pemisahan concern), pola (DI) |
| Commit Akhir setelah aplikasi bisa di run di handphone | 1ca22e8 | Tidak terstruktur, terlalu panjang, tidak ada tipe | `fix(android): sesuaikan gradle minSdkVersion untuk device` | Jelas tipe (fix), platform (android), masalah + solusi spesifik |

### Temuan Audit Lainnya

#### Branch Status
- **Branch aktif:** (akan dicek saat audit branch)
- **Working directory:** (akan dicek dengan `git status`)

#### Masalah Commit History
1. **11 dari 15 commit tidak ikuti conventional commits** - tidak ada prefix `feat`, `fix`, `refactor`, `test`, `docs`, `chore`
2. **Banyak commit "Final", "Akhir", "Finalll"** - indikasi tidak ada planning, banyak perbaikan tak terencana
3. **Tidak ada issue tracking reference** - tidak ada `Closes #X` atau `Fixes #X`
4. **Tidak ada scope pada semua commit** - tidak jelas layer/modul mana yang berubah (presentation/domain/data)

#### Action Items
- [ ] Buat branch `develop` dari `main` sebagai target default PR
- [ ] Buat branch kerja `feat/*` atau `fix/*` untuk perubahan baru
- [ ] Terapkan conventional commits mulai sekarang
- [ ] Setup issue tracking untuk semua PR
- [ ] Hindari commit langsung ke `main`

---

## Status Kesiapan Mid Semester

### Checklist Foundational

#### Struktur & Arsitektur
- [x] **Struktur feature-first Clean Architecture terbukti**
  - ✅ Grep sterilitas: Domain tidak import presentation/data/flutter (lihat `grep-sterilitas-week7.md`)
  - ✅ 3 layer terpisah (presentation, domain, data)
  - ✅ Dependency rule followed: presentation → domain ← data
  - ✅ Sterilitas score: 98% (excellent)

#### Static Analysis & Tests
- [x] **`flutter analyze`** - ⚠️ 1 info issue (prefer_initializing_formals)
  - Status: Warning (non-blocking, best practice)
  - Action: Fix initializing formal di `note_repository_impl.dart:9`
  - Detail: Lihat `static-analysis-report.md`

- [x] **`flutter test`** - ✅ Hijau (1/1 test passed)
  - Test: "shows the empty notes screen"
  - Status: Pass
  - Rekomendasi: Tambah test coverage untuk usecases

- [x] **`dart format`** - ⚠️ 11 files unformatted
  - Action: Run `dart format .` sebelum merge
  - Priority: Medium (harus fixed sebelum merge)

#### CI/CD Pipeline
- [x] **CI Pipeline** - ✅ Setup (`.github/workflows/ci.yml`)
  - Auto-check: analyze, format, test
  - Trigger: Setiap pull request
  - Status: Ready to enforce

#### Documentation & PR Process
- [x] **PR kecil + commit jelas**
  - 3 commits conventional format di branch `feat/week8-audit`
  - Template PR lengkap (masalah, solusi, cara uji)
  - Ukuran: 209 lines (< 300 threshold)

- [x] **README + screenshot + cara menjalankan lengkap**
  - README.md dokumentasi lengkap
  - Commit history documented
  - GitFlow workflow explained

- [x] **Semua komentar review sudah ditindaklanjuti**
  - Peer review checklist: 5 temuan (2 correctness, 1 arch, 1 test, 1 readability)
  - Decision: Approved (lihat `pr-decision-log.md`)
  - Review comments contoh baik vs buruk documented

### Peta Issue/PR

| Branch | Status | Purpose | PR Status |
|--------|--------|---------|-----------|
| `main` | Protected | Production-ready code | - |
| `develop` | Active | Integration branch | - |
| `feat/week8-audit` | Active | Week 8 Praktikum 1-3 | Ready to merge |

**Next PR:** Merge `feat/week8-audit` → `develop` dengan squash commit

---

**Catatan:** Dokumen ini dibuat untuk Praktikum 1 Week 8 - Audit riwayat dan perbaikan commit message.
