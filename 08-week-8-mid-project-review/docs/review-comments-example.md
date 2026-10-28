# Review Comments Examples - Week 8 Praktikum 2

## Pola Komentar Review yang Baik

Format: **Observasi → Dampak → Usulan Konkret**

---

## ✅ Contoh Komentar BAIK

### Contoh 1: Temuan Kebenaran (Correctness)
```markdown
**Observasi:** Di `review-checklist.md` baris 42, disebutkan "11 dari 15 commit tidak ikuti conventional commits". 
**Dampak:** Claim ini perlu bukti verifikasi agar dokumentasi kredibel.
**Usulan:** Tambahkan output `git log` atau screenshot di section "Bukti Audit" untuk memvalidasi angka 11/15.
**Alasan:** Review berbasis data, bukan asumsi.
```

### Contoh 2: Temuan Arsitektur
```markdown
**Observasi:** File `commit-refactoring.md` menempatkan dokumentasi di Week 8 tapi mengaudit Week 7.
**Dampak:** Separation of concern sudah benar - Week 8 = dokumentasi review, Week 7 = aplikasi.
**Usulan:** (none, sudah proper)
**Keputusan:** Approve arsitektur ini.
```

### Contoh 3: Temuan Keterbacaan
```markdown
**Observasi:** Tabel perbaikan commit di `commit-refactoring.md` memiliki 5 kolom yang padat (No, Commit Lama, Hash, Masalah, Commit Baru, Alasan).
**Dampak:** Sangat informatif, tapi bisa overwhelming untuk pembaca cepat.
**Usulan:** Pertimbangkan tambahkan visual diff di atas tabel sebagai "quick summary":
\`\`\`diff
- Final Commit
+ feat(notes): implementasi Clean Architecture + unit tests
\`\`\`
**Alasan:** Visual diff lebih cepat dipahami sebelum membaca tabel detail.
```

### Contoh 4: Temuan Testing
```markdown
**Observasi:** Dokumentasi Week 8 tidak ada unit test atau script validasi untuk format commit.
**Dampak:** Manual verification masih diperlukan setiap review PR baru.
**Usulan:** (Optional untuk PR ini) Pertimbangkan tambahkan `.github/workflows/commit-lint.yml` di PR berikutnya untuk automasi validasi.
**Alasan:** Mesin lebih konsisten dari manusia untuk cek format.
```

### Contoh 5: Temuan Edge Case
```markdown
**Observasi:** Audit commit mengasumsikan repository memiliki minimal 15 commit (`git log --oneline -15`).
**Dampak:** Jika repo baru (< 15 commit), dokumentasi bisa misleading.
**Usulan:** Tambahkan disclaimer di `review-checklist.md`: "Audit dilakukan pada repository dengan 15+ commit. Untuk repo baru, sesuaikan jumlah log."
**Alasan:** Dokumentasi harus handle edge case.
```

---

## ❌ Contoh Komentar BURUK

### Buruk 1: Terlalu Vague
```markdown
❌ "Kode ini jelek, perbaiki"
```
**Masalah:**
- Tidak ada observasi spesifik (baris berapa? file apa?)
- Tidak jelas apa yang "jelek" (format? logika? naming?)
- Tidak ada usulan konkret

**Perbaikan:**
✅ "File X baris Y: fungsi `validateCommit` memiliki 60 baris + 3 tanggung jawab (parsing, validation, formatting). Usul: pecah ke 3 fungsi kecil agar bisa ditest isolated."

---

### Buruk 2: Nitpick tanpa Konteks
```markdown
❌ "Spasi kurang di baris 42"
```
**Masalah:**
- Harusnya ditangani formatter/linter otomatis, bukan manual review
- Waste reviewer time untuk hal trivial

**Perbaikan:**
✅ "Jalankan `dart format .` sebelum commit untuk konsistensi style. Saran: tambahkan pre-commit hook atau CI check."

---

### Buruk 3: Tidak Actionable
```markdown
❌ "Mungkin perlu dipikir ulang"
```
**Masalah:**
- Tidak jelas apa yang perlu dipikirkan ulang
- Author tidak tahu langkah berikutnya

**Perbaikan:**
✅ "Arsitektur `data` layer import `presentation` (melanggar dependency rule Clean Arch). Usul: pindahkan `UserModel` ke `domain/entities/` agar `data` tidak depend ke `presentation`."

---

### Buruk 4: Emosional / Personal Attack
```markdown
❌ "Siapa yang nulis kode ini? Berantakan banget!"
```
**Masalah:**
- Menyerang personal, bukan kode
- Tidak profesional

**Perbaikan:**
✅ "File `user_repository.dart` memiliki 8 method dengan tanggung jawab berbeda (CRUD + validation + caching). Usul: split ke `UserRepository`, `UserValidator`, dan `UserCache` sesuai Single Responsibility Principle."

---

### Buruk 5: Approve tanpa Verifikasi
```markdown
❌ "LGTM" (Looks Good To Me)
```
**Masalah:**
- Tidak ada bukti reviewer benar-benar mereview
- Bisa jadi blind approve tanpa pull + test

**Perbaikan:**
✅ "Sudah pull ke lokal, jalankan `flutter test`, semua hijau. Cek manual fitur notes di emulator, validasi input bekerja. Approve."

---

## Prinsip Review yang Baik

### 1. Bersikap Keras pada Kode, Baik pada Manusia
- ✅ "Fungsi ini kompleksitas O(n²), bisa dioptimasi ke O(n) dengan HashMap"
- ❌ "Kamu tidak paham algoritma ya?"

### 2. Setiap Komentar Harus Actionable
- ✅ "Tambahkan null check di line 42 sebelum `user.name.toUpperCase()`"
- ❌ "Hati-hati null"

### 3. Prioritaskan Temuan
- **Blocker:** Bug critical, security issue, melanggar dependency rule → Request Changes
- **Medium:** Performance issue, edge case tidak ditangani → Request Changes atau Suggestion
- **Low:** Readability, optional enhancement → Suggestion saja

### 4. Verifikasi Sebelum Approve
- Pull ke lokal, build, dan test manual minimal 5 menit per fitur
- Jangan approve tanpa menjalankan kode

---

## Template Komentar Review

```markdown
**File:** `path/to/file.dart`  
**Line:** 42-50  

**Observasi:**  
[Apa yang Anda lihat - spesifik, objektif]

**Dampak:**  
[Konsekuensi jika tidak diperbaiki - bug? tech debt? readability?]

**Usulan:**  
[Solusi konkret dengan potongan kode jika perlu]

**Severity:** [Blocker / Medium / Low]  
**Decision:** [Request Changes / Approve dengan catatan]
```

---

## Checklist Reviewer Sebelum Submit Review

- [ ] Sudah pull PR ke lokal dan build berhasil?
- [ ] Sudah jalankan test (`flutter test`) dan semua hijau?
- [ ] Sudah test manual fitur yang berubah minimal 5 menit?
- [ ] Minimal 2 temuan kebenaran (bug, edge case, null safety)?
- [ ] Minimal 1 temuan arsitektur (dependency rule, layer violation)?
- [ ] Minimal 1 temuan test (missing test case)?
- [ ] Minimal 1 temuan keterbacaan (naming, structure)?
- [ ] Semua komentar punya pola observasi → dampak → usulan?
- [ ] Keputusan final jelas: Approve atau Request Changes?

---

**Catatan:** Review yang baik adalah investasi untuk kualitas codebase jangka panjang.
