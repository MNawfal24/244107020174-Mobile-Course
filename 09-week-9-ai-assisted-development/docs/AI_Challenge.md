# AI Challenge Review

Dokumen ini berisi hasil review dan keputusan teknis yang dibuat untuk fitur pencarian catatan (`SearchNotes`) pada project `05-week-5-local-storage-offline-first`.

## Prompt Review

```text
Review kode search Flutter ini sebagai senior dev.
Konteks: feature-first (presentation->domain<-data), Riverpod, SQLite + Dio.
Fokus: kebenaran, arsitektur, test. Abaikan style.
Beri 3 temuan + level blocker/saran + alasan.
```

## Output Review AI

1. **Saran - race condition pada `NotesListNotifier.search`.** Request lama dapat selesai setelah request baru dan menimpa state query terbaru jika koneksi/proses async bervariasi durasinya.
2. **Saran - test belum menguji request yang selesai tidak berurutan.** Test filter biasa belum membuktikan konsistensi state saat dua operasi async berjalan bersamaan.
3. **Saran - pertimbangkan filtering di SQLite/API.** Filtering lokal mengambil semua catatan terlebih dahulu jika data membesar di database.

## Tabel Terima/Tolak

| Saran AI | Keputusan | Alasan teknis | Bukti grep/test |
| :--- | :--- | :--- | :--- |
| Perlindungan race condition pada search async. | **Terima + refactor** | Version guard memastikan hanya request terakhir yang mengubah state. | Test `hasil search lama tidak menimpa query terbaru` di `test/get_notes_test.dart`. |
| Test request yang selesai tidak berurutan. | **Terima** | Test filtering biasa tidak menguji urutan penyelesaian Future. | `flutter test test/get_notes_test.dart` lulus. |
| Filtering dipindahkan ke SQLite/API. | **Tolak untuk scope ini** | Data masih lokal dan query SQL langsung di repository memperbesar scope tanpa kebutuhan dataset besar saat ini. | `flutter test test/search_filter_test.dart test/empty_state_test.dart` lulus. |
| Widget mengimpor detail framework/storage untuk filtering. | **Tolak** | Melanggar batas `presentation -> domain <- data`. | Grep import domain feature untuk Flutter/Dio/sqflite menghasilkan 0 baris. |

## Bukti Verifikasi

```powershell
flutter analyze
flutter test
```

Hasil terakhir yang dicatat: analyzer bersih (`No issues found!`) dan seluruh test lulus `+13`.

Fitur search/filter berada di use case domain `SearchNotes`, sedangkan widget hanya menampilkan daftar atau empty state.
