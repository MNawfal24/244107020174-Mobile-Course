import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3_navigation/pages/stats_pages.dart';

void main() {
  test('StatsNotifier transisi dari Loading ke Data atau Error', () async {
    // 1. Siapkan container untuk menampung provider selama masa pengujian
    final container = ProviderContainer();
    addTearDown(container.dispose); // Bersihkan memori setelah test selesai

    // 2. Baca state pertama kali. Seharusnya statusnya langsung 'loading' (karena ada delay 2 detik)
    var initialState = container.read(statsProvider);
    expect(initialState.isLoading, true, reason: 'State awal harus berupa loading');

    // 3. Tunggu hingga proses future selesai (diambil dari notifier)
    // Kita gunakan catchError agar test tidak hancur (*crash*) saat terkena peluang error 30%
   await container.read(statsProvider.notifier).future.catchError((_) => <String>[]);

    // 4. Baca state setelah proses asinkron selesai
    var finalState = container.read(statsProvider);

    // 5. Validasi hasil akhir (karena hasilnya random, kita cek kedua kemungkinannya)
    expect(finalState.isLoading, false, reason: 'State akhir tidak boleh loading');
    
    if (finalState.hasValue) {
      // Jika masuk probabilitas 70% Sukses
      expect(finalState.value, isA<List<String>>());
      expect(finalState.value!.length, 3);
    } else {
      // Jika masuk probabilitas 30% Error
      expect(finalState.hasError, true);
    }
  });
}