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
- [ ] Struktur feature-first Clean Architecture terbukti (hasil grep sterilitas)
- [ ] `flutter analyze` bersih
- [ ] `flutter test` hijau
- [ ] PR kecil + commit jelas
- [ ] README + screenshot + cara menjalankan lengkap
- [ ] Semua komentar review sudah ditindaklanjuti

### Peta Issue/PR
(Akan diisi setelah praktikum PR selesai)

---

**Catatan:** Dokumen ini dibuat untuk Praktikum 1 Week 8 - Audit riwayat dan perbaikan commit message.
