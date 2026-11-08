# Laporan Lengkap Optimasi Performa (Performance Report) - NoteMind AI

**Mata Kuliah:** Pemrograman Mobile  
**Minggu:** 11 - Performance Optimization  
**Nama Mahasiswa:** Muhammad Nawfal Mawla Azhar  
**NIM:** 244107020174  
**Kelas:** TI-3G  
**Proyek:** NoteMind AI (`11-week-11-performance-optimization`)

---

## 1. Ringkasan Eksekutif & Komparasi Kinerja

Aplikasi **NoteMind AI** telah dioptimalkan secara arsitektural untuk mencapai target kelancaran visual 60 FPS, efisiensi memori heap, dan penghematan kuota API. 

Optimasi difokuskan pada:
1. Pemotongan siklus build yang tidak perlu melalui **Riverpod Fine-Grained Selectors** dan pemisahan subwidget `Consumer`.
2. Isolasi render raster GPU menggunakan **`RepaintBoundary`**.
3. Penghematan request jaringan dan latensi melalui **Bounded LRU Cache** in-memory (kapasitas 30 entri).
4. Proteksi stabilitas memori via **Memory Guard** payload query dan caching objek dekorasi statis.

### Tabel Komparasi Hasil Pengujian (Before vs After)

| Parameter Pengujian | Kondisi Awal (Baseline) | Setelah Optimasi (Optimized) | Persentase Efisiensi |
| :--- | :---: | :---: | :---: |
| **Rata-rata Frame Time** | **24.8 ms** | **6.5 ms** | **-73.8% (Lebih Cepat)** |
| **Stabilitas 60 FPS (<16.6 ms)** | Gagal (Banyak frame kuning/merah) | Lolos 100% (Semua frame hijau) | Target 60 FPS tercapai |
| **Jank / Dropped Frames** | **16 frames (26.7%)** | **0 frames (0.0%)** | **100% Bebas Jank** |
| **Beban UI Thread CPU** | 68.5% | 18.2% | Penurunan beban 50.3% |
| **Beban Raster Thread GPU** | 10.4 ms | 2.1 ms | Pengurangan waktu paint 79.8% |
| **Konsumsi Memori Heap** | 75.2 MB | 41.8 MB | Penghematan memori 44.4% |
| **Hasil Analisis (`flutter analyze`)** | Bersih (0 issues) | **Bersih (0 issues)** | Sesuai kaidah linter |
| **Automated Tests (`flutter test`)** | 10 tests | **14 tests passed (+4 tes performa)** | 100% Lulus Uji |

---

## 2. Bukti Profiling DevTools (Flame Chart)

### A. Sebelum Optimasi (Baseline Profiling)
![Flame Chart Baseline](../screenshots/before-profile.png)
*Gambar 1: Profiling awal menunjukkan frame time rata-rata 24.8 ms dengan frame drop nyata saat streaming respons pesan. Raster thread menghabiskan 10.4 ms karena menggambar ulang seluruh list obrolan.*

### B. Sesudah Optimasi (Verified Profiling)
![Flame Chart Setelah Optimasi](../screenshots/after-profile.png)
*Gambar 2: Profiling akhir menunjukkan frame time rata-rata turun drastis ke 6.5 ms (stabil di bawah budget 16.6 ms). `RepaintBoundary` mengisolasi rendering paint menjadi hanya 2.1 ms.*

---

## 3. Rincian Implementasi Optimasi

### 1. Riverpod Fine-Grained Selectors (`select`) & Isolated Consumers
* **Implementasi:**
  - Menghapus pembacaan `ref.watch(chatNotifierProvider)` dari root widget `StudyAiPage`.
  - Mengisolasi rebuild baris input dengan `isGeneratingProvider` yang hanya mengevaluasi status loading:
    ```dart
    final isGenerating = ref.watch(isGeneratingProvider);
    ```
  - Mengisolasi listview obrolan ke dalam subwidget `_ChatMessageList` yang hanya me-rebuild bila daftar pesan bertambah/berubah.
  - Memisahkan banner persona ke `_PersonaInfoBar` yang hanya mendengarkan `selectedPersonaProvider` dan metrik cache.
* **Dampak:**  
  Saat proses request Gemini berlangsung, tombol AppBar dan input field tidak ikut di-rebuild berulang kali.

### 2. Isolasi Paint Layer dengan `RepaintBoundary`
* **Implementasi:**
  - Setiap gelembung chat dibungkus dengan `RepaintBoundary`:
    ```dart
    ListView.builder(
      controller: scrollController,
      addRepaintBoundaries: true,
      itemCount: messages.length,
      itemBuilder: (ctx, idx) => RepaintBoundary(
        child: _ChatMessageBubble(message: messages[idx]),
      ),
    );
    ```
  - Membungkus `_PersonaDropdownButton`, `_PersonaInfoBar`, dan `_ChatInputBar` dengan `RepaintBoundary`.
* **Dampak:**  
  GPU mengalokasikan layer independen pada compositor. Animasi loading pada bubble pesan terakhir tidak memicu re-painting pada bubble-bubble pesan terdahulu.

### 3. Bounded LRU Cache In-Memory pada `GeminiRepository`
* **Implementasi:**
  - Menambahkan struktur data cache terikat (maksimal 30 entri):
    ```dart
    static const int _maxCacheSize = 30;
    final Map<String, String> _lruCache = {};

    String _buildCacheKey(String query, StudyPersona persona) =>
        '${persona.name}::${query.trim().toLowerCase()}';
    ```
  - Jika kunci cache ditemukan, entri diperbarui urutannya ke posisi teranyar dan mengembalikan data seketika tanpa network call.
  - Jika ukuran melebihi batas, entri paling awal di-evict (`_lruCache.remove(_lruCache.keys.first)`).
* **Dampak:**  
  Pertanyaan materi kuliah yang sering diulang (misal saat berganti persona atau review materi kuis) langsung direspon dalam waktu 0 ms tanpa memakan kuota token API.

### 4. Memory Guard & Eliminasi Alokasi Objek Berulang
* **Implementasi:**
  - Menambahkan pembatasan input teks maksimal 3000 karakter guna mencegah lonjakan alokasi string heap:
    ```dart
    if (userQuery.length > _maxQueryLength) {
      throw const GeminiException('Panjang teks pertanyaan melebihi batas aman (maks 3000 karakter).');
    }
    ```
  - Menyimpan `BoxDecoration` untuk bubble pesan pengguna dan model AI sebagai `static final` agar tidak dibuat ulang pada setiap frame build.
* **Dampak:**  
  Frekuensi Garbage Collection berkurang signifikan dan penggunaan memori terkendali di ~41.8 MB.

---

## 4. Verifikasi dan Pengujian Otomatis

Verifikasi sistem dilakukan menggunakan rangkaian tes terotomatisasi:

```powershell
flutter analyze
flutter test
```

### Hasil Verifikasi:
- **`flutter analyze`:** Clean, 0 warnings / errors.
- **`flutter test` (14/14 lulus):**
  1. `StudyPersona Tests`: Non-empty label and system instructions (Passed)
  2. `StudyPersona Tests`: Instructions are distinct (Passed)
  3. `StudyPersona Tests`: All three personas exist (Passed)
  4. `ChatMessage Tests`: copyWith works correctly (Passed)
  5. `ChatMessage Tests`: Correct default status (Passed)
  6. `ChatMessage Tests`: Error status with message (Passed)
  7. `AiExceptions Tests`: GeminiException formatting (Passed)
  8. `AiExceptions Tests`: ApiKeyMissingException message (Passed)
  9. `AiExceptions Tests`: NetworkAiException formatting (Passed)
  10. `Performance & Caching Tests`: LRU cache avoids redundant network requests (Passed - *Verifikasi Cache Hit*)
  11. `Performance & Caching Tests`: LRU cache evicts oldest entry at capacity 30 (Passed - *Verifikasi Eviction*)
  12. `Performance & Caching Tests`: Memory guard rejects queries > 3000 chars (Passed - *Verifikasi Memory Guard*)
  13. `Performance & Caching Tests`: clearCache flushes memory (Passed)
  14. `Widget Tests`: StudyAiPage renders with ProviderScope and RepaintBoundary (Passed - *Verifikasi Render Layer*)

---

## 5. Refleksi dan Keputusan Kritis

### 1. Optimasi mana yang memberikan dampak paling signifikan?
Pemisahan build scope menggunakan **Riverpod Fine-Grained Selectors** yang dipadukan dengan **`RepaintBoundary`**. Karena aplikasi AI chat melakukan perubahan state dinamis saat memproses jawaban, pemisahan ini menghentikan pemborosan CPU untuk me-render ulang seluruh halaman dan menurunkan frame time dari 24.8 ms ke 6.5 ms.

### 2. Bagaimana verifikasi dilakukan agar terhindar dari efek placebo?
Verifikasi dibuktikan secara empiris dan kuantitatif melalui:
1. **DevTools Timeline Profiling:** Pengukuran frame time nyata dalam mode `--profile` yang menunjukkan eliminasi 100% frame drop (jank).
2. **Automated Cache Testing:** Pengujian unit dengan `MockHttpClient` yang memvalidasi bahwa `requestCount` tidak bertambah saat cache hit terjadi.
3. **Widget Layer Verification:** Pengecekan keberadaan node `RepaintBoundary` pada pohon widget melalui automated test.

### 3. Apa trade-off antara kompleksitas kode vs performa?
Peningkatan modularitas kode menuntut lebih banyak deklarasi class subwidget (`_PersonaInfoBar`, `_ChatMessageList`, dll.) dibandingkan struktur monolitik awal. Namun, arsitektur ini membuat kode lebih mudah dirawat (*maintainable*), mudah diuji (*testable*), dan menghasilkan performa 60 FPS yang solid.

### 4. Kapan optimasi prematur harus dihindari?
Optimasi prematur harus dihindari ketika aplikasi belum diukur dengan profiling nyata (*measure first, optimize later*). Menaruh `RepaintBoundary` secara membabi-buta di semua widget dapat memboroskan memori VRAM kartu grafis karena setiap boundary memerlukan alokasi layer bitmap tersendiri.
