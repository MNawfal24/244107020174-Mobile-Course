# Laporan Temuan Profiling Performa (Performance Findings) - NoteMind AI

**Mata Kuliah:** Pemrograman Mobile  
**Minggu:** 11 - Performance Optimization  
**Nama Mahasiswa:** Muhammad Nawfal Mawla Azhar  
**NIM:** 244107020174  
**Kelas:** TI-3G  
**Aplikasi Baseline:** NoteMind AI (`10-week-10-ai-feature-integration`)

---

## 1. Ringkasan Eksekutif Baseline Profiling

Sebelum optimasi dilakukan, aplikasi **NoteMind AI** diuji pada mode `--profile` menggunakan Flutter DevTools. Skenario pengujian mensimulasikan penggunaan nyata mahasiswa:
1. Membuka aplikasi tutor belajar dan memeriksa inisialisasi API key.
2. Mengirimkan serangkaian materi kuliah untuk dirangkum (Persona: Ringkas Cepat).
3. Mengganti persona belajar (Pembuat Kuis dan Tutor Sokratik) secara dinamis.
4. Melakukan scrolling cepat (*flinging/fast scrolling*) pada riwayat pesan yang panjang.
5. Mengirimkan prompt pertanyaan yang sama berulang kali untuk menguji ada/tidaknya redundansi request jaringan.

### Metrik Kinerja Awal (Baseline Metrics)
- **Rata-rata Frame Time:** 24.8 ms (jauh melebihi batas render 16.67 ms untuk 60 FPS).
- **Dropped Frames (Jank):** 16 frame merah/kuning dari total 60 frame terekam (~26.7% jank rate).
- **Beban UI Thread CPU:** 68.5% saat request dan rendering pesan obrolan aktif.
- **Waktu Raster Thread GPU:** 10.4 ms akibat re-rasterization seluruh list pesan tanpa boundary.
- **Konsumsi Memori Heap Dart:** 75.2 MB tanpa mekanisme pembatasan cache in-memory.

Bukti profiling visual awal dicatat pada: [`screenshots/before-profile.png`](../screenshots/before-profile.png).

---

## 2. Analisis Bottleneck dan Akar Masalah

Berdasarkan inspeksi DevTools Flame Chart dan Timeline Events, ditemukan 4 kendala utama:

### Temuan 1: Rebuild Menyeluruh pada Tingkat Root Halaman (`StudyAiPage`)
* **Gejala:**  
  Frame Chart menunjukkan durasi build berulang pada `StudyAiPage.build` hingga 18.2 ms saat pengiriman pesan.
* **Akar Masalah:**  
  Pada implementasi awal, `StudyAiPage` memanggil `ref.watch(chatNotifierProvider)` di method `build()` utama. Ketika status pesan berubah dari `sending` menjadi `success` atau `error`, seluruh elemen antarmuka (termasuk AppBar, popup menu persona, container info, dan input bar) ikut di-rebuild secara sia-sia.

### Temuan 2: Absensi Isolasi Layer Paint (`RepaintBoundary`) pada Gelembung Obrolan
* **Gejala:**  
  Raster Thread memakan waktu 10.4 ms per frame karena proses `Rasterize LayerTree` yang berat saat pesan baru masuk.
* **Akar Masalah:**  
  Setiap gelembung pesan (`ChatMessage`) berada pada render tree layer yang sama. Saat indikator animasi loading berputar atau teks AI selesai dimuat, GPU terpaksa menggambar ulang (repaint) semua gelembung pesan lama di atasnya.

### Temuan 3: Ketiadaan In-Memory Caching untuk Pertanyaan Identik
* **Gejala:**  
  Lonjakan latensi jaringan dan konsumsi kuota API yang tidak efisien saat user meminta ringkasan topik yang sama pada persona yang sama.
* **Akar Masalah:**  
  `GeminiRepositoryImpl` langsung mengirimkan HTTP POST request ke server Gemini tanpa mengecek apakah materi/pertanyaan tersebut sudah pernah dijawab sebelumnya pada sesi aktif.

### Temuan 4: Alokasi Objek Berulang pada Tiap Frame Render
* **Gejala:**  
  Terjadi lonjakan alokasi memori sementara (heap thrashing) yang memicu Garbage Collection (GC) pauses frekuen.
* **Akar Masalah:**  
  Instance `BoxDecoration` untuk bubble user dan bot dibuat ulang (*re-instantiated*) setiap kali build dieksekusi, serta tidak adanya proteksi memory guard untuk membatasi panjang teks prompt yang ekstrem.

---

## 3. Rencana Tindakan Optimasi

| Masalah | Strategi Perbaikan | Target Kinerja |
| :--- | :--- | :--- |
| Root Rebuild Berlebih | Terapkan Riverpod fine-grained selector (`select`) dan pecah ke subwidget `Consumer` terisolasi (`_PersonaInfoBar`, `_ChatMessageList`, `_ChatInputBar`). | Frame time turun di bawah 10 ms; rebuild hanya pada komponen terkait. |
| Re-paint Seluruh Tree Pesan | Bungkus `_ChatMessageBubble`, `_PersonaInfoBar`, dan `_ChatInputBar` dengan `RepaintBoundary`. | Waktu raster paint GPU turun di bawah 3 ms. |
| Redundansi Request Jaringan | Implementasi **Bounded LRU Cache** (kapasitas 30 entri) dengan kebijakan penggusuran otomatis entri tertua. | 0 HTTP request pada query identik (Cache hit langsung). |
| Heap Thrashing & Lonjakan Alokasi | Deklarasikan dekorasi sebagai `static final` dan tambahkan Memory Guard batas query maksimal 3000 karakter. | Alokasi heap terkontrol stabil ~40 MB. |
