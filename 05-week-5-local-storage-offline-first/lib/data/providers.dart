import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'repositories/note_repository.dart';
// Import file terkait lainnya yang sudah Anda miliki

// ---------------------------------------------------------
// [BARU] 1. Toggle Simulasi Offline (Deterministik)
// ---------------------------------------------------------
// Provider ini bisa Anda hubungkan ke widget Switch di halaman Settings.
// Jika bernilai true, aplikasi pura-pura tidak punya internet.
class ForceOfflineNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle(bool value) {
    state = value;
  }
}

final forceOfflineProvider = NotifierProvider<ForceOfflineNotifier, bool>(ForceOfflineNotifier.new);

// ---------------------------------------------------------
// [BARU] 2. Logika Sinkronisasi Catatan Kotor (Praktikum 3)
// ---------------------------------------------------------
Future<int> syncNotes(NoteRepository repo) async {
  // Hitung jumlah catatan yang belum terkirim ke server (dirty = 1)
  final dirtyCount = await repo.countDirty();
  if (dirtyCount == 0) return 0; // Jika tidak ada, hentikan

  // Simulasi upload: pada project nyata, kirim tiap catatan dirty
  // ke REST API di sini, lalu tandai bersih bila server menjawab 2xx.
  
  await Future.delayed(const Duration(seconds: 1)); // Simulasi jeda internet 1 detik
  await repo.markAllSynced(); // Ubah semua status dirty menjadi 0
  
  return dirtyCount;
}

// ---------------------------------------------------------
// [BARU] 3. Provider NoteRepository
// ---------------------------------------------------------
final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepository();
});