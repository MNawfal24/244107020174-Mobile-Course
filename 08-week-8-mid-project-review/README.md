# Laporan Praktikum Minggu 8 - Mid Project Review & Code Review

---

## Identitas Mahasiswa 
* **Nama:** Muhammad Nawfal Mawla Azhar
* **NIM:** 244107020174
* **Kelas:** 3G-TI

---

## Ringkasan Praktikum

Praktikum Minggu 8 berfokus pada kolaborasi profesional, GitFlow branching model, code review terstruktur, static analysis & CI, serta AI-assisted review yang bertanggung jawab.

### 1. Praktikum 1: Audit Riwayat & Branching Model
- Melakukan audit 15 commit terakhir project Week 7 (`07-week-7-clean-architecture`).
- Menemukan 11 commit non-konvensional (seperti "Final Commit", "Commit Akhir").
- Membuat branch `develop` dari `main` serta branch `feat/week8-audit` untuk isolasi pekerjaan.
- Mendokumentasikan perbaikan commit message ke format conventional commits pada `docs/commit-refactoring.md` dan `docs/review-checklist.md`.

### 2. Praktikum 2: Pull Request & Peer Code Review
- Menyusun template Pull Request standar di `docs/pr-template.md`.
- Menyusun checklist peer review dengan minimal 5 temuan di `docs/peer-review-checklist.md`.
- Mendokumentasikan pola komentar review yang konstruktif (observasi → dampak → usulan) di `docs/review-comments-example.md`.
- Mencatat log keputusan review (approve & merge reasoning) di `docs/pr-decision-log.md`.

### 3. Praktikum 3: Static Analysis, CI & Penilaian Kesiapan
- Menjalankan pemeriksaan mesin: `flutter analyze`, `dart format`, dan `flutter test` di project Week 7.
- Membuat file konfigurasi GitHub Actions CI pada `.github/workflows/ci.yml`.
- Menguji sterilitas Clean Architecture Week 7 menggunakan grep di `docs/grep-sterilitas-week7.md` (Skor sterilitas: 98%).
- Menyusun laporan analisis statis di `docs/static-analysis-report.md`.

### 4. AI Challenge: AI-assisted Review
- Mengirimkan prompt review dengan kriteria spesifik ke AI Senior Flutter Dev (`docs/ai-review-prompt.md`).
- Menampung 5 temuan dari AI pada `docs/ai-review-output.md`.
- Melakukan verifikasi manual dan mendokumentasikan tabel keputusan akhir di `docs/ai-review-vs-keputusan.md`.

---

## Refleksi

### 1. Apa beda LGTM buta dengan approve yang bertanggung jawab? Apa risikonya bagi tim?

LGTM (Looks Good To Me) buta terjadi ketika reviewer menyetujui Pull Request tanpa benar-benar membaca kode, menguji aplikasi secara lokal, atau memeriksa alur eksekusi dan test. Approve yang bertanggung jawab membutuhkan proses pull kode ke lokal, pengujian manual minimal 5 menit, pengecekan ketaatan arsitektur, serta verifikasi bahwa automated test dan linter berjalan hijau. Risiko bagi tim jika terjadi LGTM buta adalah bug lolos ke branch utama/produksi, celah keamanan terbuka, rusaknya aturan arsitektur (seperti import antar layer yang terlarang), dan menumpuknya utang teknis (technical debt) yang sulit diperbaiki di kemudian hari.

### 2. Kapan komentar wajib berstatus request changes, dan kapan cukup saran?

Komentar wajib berstatus **Request Changes** apabila ditemukan *blocker* atau kesalahan kritis, seperti:
- Bug yang menyebabkan crash atau data hilang/rusak.
- Pelanggaran aturan dependensi arsitektur (misal: domain meng-import presentation/data/Flutter).
- Kegagalan unit test atau linter/analyze yang belum diperbaiki.
- Celah keamanan yang membahayakan aplikasi.

Sebaliknya, komentar cukup berupa **Saran (Comment/Suggestion)** apabila hanya berhubungan dengan:
- Peningkatan keterbacaan kode (readability) yang tidak krusial.
- Saran refactoring minor yang sifatnya opsional.
- Ide atau gagasan fitur/fitur tambahan untuk iterasi atau PR berikutnya.

### 3. Bagian mana dari review AI yang Anda tolak atau sederhanakan, dan mengapa?

Seluruh 5 temuan utama dari review AI diperiksa dan diverifikasi secara manual:
- Temuan Blocker/Critical (mengenai kesalahan nama class `GetNotes` pada file `add_note.dart` dan duplikasi class) diterima sepenuhnya karena merupakan bug nyata.
- Namun, saran AI untuk merestrukturisasi penempatan Dependency Injection (DI) dari presentation ke `core/` dan penambahan unit test yang sangat ekstensif disederhanakan/ditandai sebagai **Future Enhancement**.
- Alasan penyederhanaan: Untuk ruang lingkup tugas mid-semester ini, struktur DI yang ada di presentation provider masih cukup pragmatis dan tidak mengganggu fungsionalitas utama aplikasi. Implementasi unit test yang komprehensif diprioritaskan untuk modul testing mendatang (Minggu 12) agar tidak membengkakkan skala PR saat ini.

### 4. Satu hal konkret yang Anda perbaiki setelah review sejawat — apa dampaknya?

Hal konkret yang diperbaiki adalah perbaikan nama class usecase pada file `add_note.dart` yang sebelumnya bertuliskan `class GetNotes` akibat duplikasi/copy-paste error.
**Dampaknya:**
- Menghilangkan ambiguitas import class `GetNotes` di dua tempat berbeda.
- Memastikan modul pembuatan catatan (`AddNote`) memiliki tanggung jawab dan identitas yang jelas sesuai prinsip Single Responsibility Principle (SRP).
- Mencegah timbulnya bug runtime atau salah panggil fungsionalitas saat menambahkan catatan baru.
