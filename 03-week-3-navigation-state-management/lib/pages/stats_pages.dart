import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. NOTIFIER: Mendefinisikan AsyncNotifier untuk mengelola state asinkron
class StatsNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    // Fungsi build otomatis dijalankan pertama kali provider dipantau
    return _fetchStatistics();
  }

  // Fungsi simulasi pengambilan data dari server/API
  Future<List<String>> _fetchStatistics() async {
    // Simulasi delay (waktu tunggu) selama 2 detik
    await Future.delayed(const Duration(seconds: 2));

    // Simulasi kemungkinan gagal sebesar 30% menggunakan Random
    final random = Random();
    if (random.nextDouble() < 0.3) {
      throw Exception('Gagal mengambil data dari server (Simulasi Error 30%).');
    }

    // Jika sukses (70% kemungkinan), kembalikan List berisi 3 item statistik
    return [
      'Total Pengunjung: 1.542',
      'Pendapatan: Rp 4.500.000',
      'Tingkat Konversi: 4.8%'
    ];
  }

  // Fungsi untuk tombol "Retry" agar memuat ulang data
  Future<void> retry() async {
    // Ubah state menjadi loading secara eksplisit
    state = const AsyncValue.loading();
    // Gunakan AsyncValue.guard untuk menangkap error (try/catch otomatis)
    // Nilai state akan otomatis menjadi data (jika sukses) atau error (jika gagal)
    state = await AsyncValue.guard(() => _fetchStatistics());
  }
}

// 2. PROVIDER: Deklarasi tipe secara eksplisit (StatsNotifier dan tipe kembalian List<String>)
final statsProvider = AsyncNotifierProvider<StatsNotifier, List<String>>(
  StatsNotifier.new,
);

// 3. UI (USER INTERFACE): Menggunakan ConsumerWidget
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Memantau (watch) state provider. Akan selalu update jika state berubah.
    final statsAsyncValue = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      // .when memaksa kita menangani 3 kemungkinan state (loading, error, success)
      body: statsAsyncValue.when(
        // Kondisi Loading: Tampilkan spinner
        loading: () => const Center(child: CircularProgressIndicator()),
        
        // Kondisi Error: Tampilkan pesan gagal dan tombol Retry
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                // Menggunakan ref.read() di dalam callback tombol (bukan ref.watch)
                onPressed: () => ref.read(statsProvider.notifier).retry(),
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
        
        // Kondisi Success: Tampilkan ListView
        data: (statsData) => ListView.builder(
          itemCount: statsData.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.bar_chart)),
              title: Text(statsData[index]),
            );
          },
        ),
      ),
    );
  }
}