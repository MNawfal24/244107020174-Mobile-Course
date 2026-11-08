# Week 11 - Performance Optimization (NoteMind AI)

**Nama:** Muhammad Nawfal Mawla Azhar  
**NIM:** 244107020174  
**Kelas:** TI-3G  
**Proyek:** NoteMind AI (`11-week-11-performance-optimization`)

---

## Tujuan Pembelajaran

Setelah menyelesaikan praktikum ini, mahasiswa mampu:
- Menggunakan Flutter DevTools pada mode `--profile` untuk profiling CPU, UI thread, raster thread, dan memori.
- Mengidentifikasi serta mengeliminasi widget rebuild berlebih menggunakan Riverpod fine-grained selectors.
- Mengisolasi layer penggambaran raster GPU menggunakan widget `RepaintBoundary`.
- Menerapkan in-memory caching terikat (**Bounded LRU Cache**) untuk menekan latensi dan kuota request jaringan.
- Memperbaiki bottleneck performa pada aplikasi nyata dan memverifikasi hasilnya secara kuantitatif.

---

## Konsep Singkat

Aplikasi mobile harus responsif, hemat daya, dan mempertahankan frame rate mulus pada 60 FPS (budget 16.67 ms per frame) atau 120 FPS (budget 8.33 ms). Kinerja yang buruk memicu frame drop (*jank*), lonjakan memori, dan boros baterai.

Pipeline rendering Flutter terbagi atas:
1. **UI Thread (Dart VM):** Menangani logika aplikasi, build widget tree, dan layouting.
2. **Raster Thread (GPU Engine):** Mengomposisikan layer grafis dan me-rasterize piksel ke layar.

Pada praktikum ini, proyek yang dioptimasi adalah **NoteMind AI** (proyek hasil integrasi AI Week 10). Optimasi difokuskan pada:
1. **Riverpod Fine-Grained Selectors:** Mengeliminasi rebuild root screen pada `StudyAiPage`.
2. **Paint Layer Isolation (`RepaintBoundary`):** Mencegah repainting seluruh list obrolan saat status pesan diperbarui.
3. **Bounded LRU Cache:** Menyimpan hingga 30 jawaban AI di memori dengan penggusuran otomatis entri terlama.
4. **Memory Guard & Static Styles:** Membatasi input prompt maksimal 3000 karakter dan membekukan dekorasi bubble pesan.

---

## Hasil Pengujian & Komparasi Kinerja

Aplikasi diuji dalam mode `--profile` menggunakan Flutter DevTools dengan skenario simulasi aktivitas belajar nyata (mengirim prompt materi, mengganti persona belajar, dan fast-scrolling).

### Tabel Perbandingan Metrik (Before vs After Optimization)

| Metrik Evaluasi | Sebelum Optimasi (Baseline) | Sesudah Optimasi (Optimized) | Perubahan Kinerja |
| :--- | :---: | :---: | :---: |
| **Rata-rata Frame Time** | **24.8 ms** | **6.5 ms** | **-73.8% (Lebih Cepat)** |
| **Kepatuhan 60 FPS (16.6 ms)** | Tidak patuh (Banyak jank frame) | Patuh 100% (Semua frame hijau) | Target 60 FPS tercapai |
| **Jank / Dropped Frames** | **16 frames (26.7%)** | **0 frames (0.0%)** | **100% Bebas Jank** |
| **Beban UI Thread CPU** | 68.5% | 18.2% | Beban CPU terpangkas 50.3% |
| **Beban Raster Thread GPU** | 10.4 ms | 2.1 ms | Waktu compositing turun 79.8% |
| **Konsumsi Memori Heap** | 75.2 MB | 41.8 MB | Penghematan memori 44.4% |
| **Hasil `flutter analyze`** | Clean (0 issues) | **Clean (0 issues)** | Sesuai kaidah linter |
| **Hasil `flutter test`** | 10 passed | **14 passed (+4 tes performa)** | 100% lulus uji |

---

## Bukti Screenshot Profiling DevTools

### 1. Profiling Sebelum Optimasi (Baseline)
> Flame Chart sebelum optimasi menunjukkan rata-rata frame time 24.8 ms dengan 16 frame drop (jank). UI thread terbebani oleh build berulang seluruh halaman `StudyAiPage`, dan Raster thread memakan waktu 10.4 ms akibat re-paint seluruh listview.

![Flame Chart Sebelum Optimasi](screenshots/before-profile.png)

### 2. Profiling Sesudah Optimasi (Verified)
> Flame Chart setelah optimasi menunjukkan frame time rata-rata turun ke 6.5 ms (stabil di bawah batas 16.6 ms). `RepaintBoundary` mengisolasi raster paint menjadi hanya 2.1 ms tanpa jank frame (0.0%).

![Flame Chart Sesudah Optimasi](screenshots/after-profile.png)

### 3. Tampilan Aplikasi NoteMind AI
| Sebelum Pengaturan API | Berinteraksi dengan Tutor AI |
| :---: | :---: |
| ![Sebelum API](screenshots/SebelumAPI.png) | ![Setelah API](screenshots/SetelahAPI.png) |

---

## 4 Teknik Optimasi yang Diterapkan

### 1. Riverpod Fine-Grained Selectors & Subwidget Consumer
- Menghapus `ref.watch(chatNotifierProvider)` dari root `StudyAiPage`.
- Mengekstrak `_PersonaInfoBar`, `_ChatMessageList`, dan `_ChatInputBar` sebagai widget `Consumer` lokal independen.
- `_ChatInputBar` hanya memantau perubahan status pengiriman via `isGeneratingProvider`.

### 2. Isolasi Render Layer dengan `RepaintBoundary`
- Membungkus setiap `_ChatMessageBubble` dengan `RepaintBoundary`.
- Mengaktifkan `addRepaintBoundaries: true` pada `ListView.builder`.
- Membungkus banner persona dan input bar dengan `RepaintBoundary`.

### 3. In-Memory Bounded LRU Cache pada `GeminiRepository`
- Menampung hingga 30 respons tanya-jawab terakhir berdasarkan kombinasi `persona::query`.
- Menghindari panggilan API dan latensi jaringan saat mahasiswa menanyakan materi yang sama berulang kali.
- Menerapkan penggusuran otomatis (*oldest entry eviction*) untuk mencegah kebocoran memori.

### 4. Memory Guard & Eliminasi Alokasi Objek Berulang
- Validasi kapasitas prompt (< 3000 karakter) sebelum dialokasikan ke JSON payload.
- Menyimpan instance `BoxDecoration` bubble chat sebagai `static final`.
- Memastikan `TextEditingController` dan `ScrollController` ter-dispose dengan benar.

---

## Verifikasi dan Pengujian

Pengujian dilakukan menggunakan perintah resmi Flutter:

```bash
flutter analyze
flutter test
```

### Hasil Analisis dan Pengujian:
- **`flutter analyze`:** `No issues found!` (0 error, 0 warning).
- **`flutter test`:** Seluruh 14 pengujian lulus (`+14`):
  - 3 unit test untuk persona belajar (`StudyPersona`).
  - 3 unit test untuk domain pesan chat (`ChatMessage`).
  - 3 unit test untuk exception handling (`AiExceptions`).
  - 4 pengujian performa & caching: LRU cache hit, LRU eviction pada kapasitas 30, memory guard query panjang, dan pembersihan cache.
  - 1 widget test untuk verifikasi rendering tree dan keberadaan node `RepaintBoundary`.

---

## Struktur Folder Proyek

```
11-week-11-performance-optimization/
├── docs/
│   ├── performance-findings.md   # Laporan temuan bottleneck baseline
│   └── performance-report.md     # Laporan komprehensif before vs after
├── screenshots/
│   ├── before-profile.png        # DevTools Flame Chart sebelum optimasi
│   ├── after-profile.png         # DevTools Flame Chart sesudah optimasi
│   ├── SebelumAPI.png            # UI app status API belum diatur
│   └── SetelahAPI.png            # UI app chat responsif
├── lib/
│   ├── core/
│   │   ├── errors/
│   │   │   └── ai_exceptions.dart
│   │   └── security/
│   │       └── secure_storage_service.dart
│   ├── features/
│   │   └── study_ai/
│   │       ├── data/
│   │       │   └── repositories/
│   │       │       └── gemini_repository.dart  # Bounded LRU Cache & Memory Guard
│   │       ├── domain/
│   │       │   └── entities/
│   │       │       ├── chat_message.dart
│   │       │       └── study_persona.dart
│   │       └── presentation/
│   │           ├── pages/
│   │           │   └── study_ai_page.dart      # RepaintBoundary & Isolated Consumers
│   │           └── providers/
│   │               └── chat_provider.dart      # Fine-grained Riverpod selectors
│   └── main.dart
├── test/
│   ├── study_ai_test.dart        # Unit & Performance tests (LRU & Memory Guard)
│   └── widget_test.dart          # Widget tree & RepaintBoundary test
└── pubspec.yaml
```

---

## Refleksi

1. **Optimasi mana yang memberikan dampak terbesar dan mengapa?**  
   Penggunaan fine-grained Riverpod selector yang dipadukan dengan `RepaintBoundary` pada gelembung pesan. Pada aplikasi chat AI, pembaruan status pesan terjadi secara frekuen. Dengan selector dan boundary, komponen AppBar, info banner, dan input bar tidak ikut di-rebuild saat pesan baru masuk, dan GPU tidak perlu me-rasterize ulang deretan pesan obrolan lama. Frame time terpangkas dari 24.8 ms menjadi 6.5 ms.

2. **Bagaimana Anda memverifikasi bahwa optimasi benar-benar bekerja (bukan placebo)?**  
   Verifikasi dibuktikan secara empiris melalui:
   - DevTools Performance Flame Chart pada mode `--profile` yang menunjukkan eliminasi 100% jank frame.
   - Pengujian otomatis unit test dengan `MockHttpClient` yang memastikan network request tidak dieksekusi saat cache hit terjadi.
   - Pengecekan node `RepaintBoundary` dalam widget test.

3. **Trade-off apa yang Anda hadapi (misalnya kompleksitas kode vs performa)?**  
   Kode menjadi lebih modular dengan beberapa class widget terpisah (`_PersonaInfoBar`, `_ChatMessageList`, `_ChatInputBar`) daripada satu file monolitik. Namun, modularitas ini meningkatkan keterbacaan kode (*maintainability*), kemudahan pengujian (*testability*), dan menjamin kestabilan 60 FPS bagi pengguna.

4. **Kapan sebaiknya optimasi premature dihindari?**  
   Optimasi premature harus dihindari ketika aplikasi belum memiliki bukti profiling (*measure before optimizing*). Memasang `RepaintBoundary` pada sembarang widget statis yang jarang berubah justru dapat memboroskan memori VRAM GPU karena setiap boundary membuat layer bitmap terpisah di memori.
