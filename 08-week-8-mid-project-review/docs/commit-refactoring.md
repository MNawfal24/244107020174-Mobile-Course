# Refactoring Commit Messages - Week 8

**Praktikum 1 No. 3:** Perbaikan Pesan Commit Buruk ke Format Conventional Commits  
**Basis Data:** Audit Git Log Week 7 Clean Architecture (`07-week-7-clean-architecture`)

---

## 1. Tabel Perbandingan Sebelum & Sesudah

| No | Commit Lama (Sebelum) | Hash | Masalah Spesifik | Commit Baru (Sesudah) | Alasan Perbaikan & Bukti |
|:---:|---|:---:|---|---|---|
| 1 | `Final Commit` | `60271ac` | Tidak ada tipe, tidak ada scope, ambigu kata "final", tidak menjelaskan apa yang dibuat. | `feat(notes): implementasi Clean Architecture + unit tests` | **Tipe:** `feat` (fitur baru).<br>**Scope:** `notes` (modul catatan).<br>**Deskripsi:** Implementasi Clean Architecture lengkap (presentation, domain, data).<br>**Bukti:** Disertai unit tests usecase. |
| 2 | `Commit Refactoring` | `d04de85` | Terlalu umum, tidak menyebut layer/file yang di-refactor, tidak ada konteks arsitektur. | `refactor(data): pisahkan repository dari data source + DI` | **Tipe:** `refactor` (restrukturisasi tanpa ubah logic luar).<br>**Scope:** `data` (data layer).<br>**Deskripsi:** Memisahkan local datasource dan repository interface.<br>**Bukti:** Menerapkan Dependency Injection via Riverpod. |
| 3 | `Commit Akhir setelah aplikasi bisa di run di handphone` | `1ca22e8` | Gaya bahasa obrolan/cerita, terlalu panjang, tidak terstruktur, tanpa kategori perbaikan. | `fix(android): sesuaikan gradle minSdkVersion untuk device` | **Tipe:** `fix` (perbaikan bug/build).<br>**Scope:** `android` (konfigurasi platform Android).<br>**Deskripsi:** Update minSdkVersion pada build.gradle agar kompatibel dengan device uji.<br>**Bukti:** Build berhasil dan app bisa dijalankan di device fisik. |

---

## 2. Analisis Struktur Conventional Commits

Format standar yang digunakan:
```
<type>(<scope>): <subject>

[optional body]

[optional footer(s)]
```

### Unsur-unsur Wajib:
1. **Type (Tipe):**
   - `feat`: Penambahan fitur baru untuk user/sistem.
   - `fix`: Perbaikan bug atau build error.
   - `refactor`: Perubahan struktur kode tanpa mengubah fungsionalitas eksternal.
   - `test`: Menambah atau memperbaiki testing.
   - `docs`: Perubahan dokumentasi saja.
   - `chore`: Perubahan konfigurasi alat, dependency, atau build tool.

2. **Scope (Ruang Lingkup):**
   - Menunjukkan modul, layer, atau platform yang terpengaruh (contoh: `notes`, `data`, `domain`, `presentation`, `android`, `review`).

3. **Subject (Pesan Singkat):**
   - Ditulis dalam kalimat imperatif dan jelas.
   - Menyertakan apa yang diubah dan buktinya jika ada (contoh: `+ test`).

4. **Issue Tracking (Footer):**
   - Mengaitkan PR/commit dengan issue tracker (contoh: `Closes #12`).

---

## 3. Komitmen Disiplin Branching & Commit Selanjutnya

- [x] Tidak lagi menggunakan pesan generik seperti `update`, `fix bug`, `commit final`.
- [x] Setiap commit hanya memuat satu perubahan logis (menggunakan `git add -p` bila diperlukan).
- [x] Seluruh commit di branch kerja (`feat/*` atau `fix/*`) harus mengikuti format conventional commits sebelum di-merge ke `develop`.
