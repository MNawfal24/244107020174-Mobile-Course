import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api_client.dart'; // Menggunakan Dio terpusat yang Anda buat sebelumnya
import '../models/comment.dart';

// --- REPOSITORY LAYER ---
class CommentRepository {
  final Dio _dio;
  CommentRepository(this._dio);

  Future<List<Comment>> fetchComments(int postId) async {
    try {
      // Mengirim request GET dengan tambahan timeout khusus 10 detik
      final response = await _dio.get(
        '/comments',
        queryParameters: {'postId': postId},
        options: Options(receiveTimeout: const Duration(seconds: 10)),
      );

      final data = response.data as List?;
      if (data == null) return [];

      return data.whereType<Map<String, dynamic>>().map(Comment.fromJson).toList();
    } on DioException catch (e) {
      // Melempar error ke Notifier dengan pesan yang ramah pengguna
      throw _getFriendlyErrorMessage(e);
    } catch (e) {
      throw 'Terjadi kesalahan yang tidak terduga.';
    }
  }

  // Fungsi untuk memetakan tipe error Dio ke teks Indonesia
  String _getFriendlyErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Waktu koneksi habis. Silakan periksa jaringan Anda.';
      case DioExceptionType.connectionError:
        return 'Gagal terhubung ke server. Pastikan internet Anda aktif.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 404) return 'Komentar tidak ditemukan (404).';
        if (statusCode == 500) return 'Terjadi gangguan pada server (500).';
        return 'Terjadi kesalahan server ($statusCode).';
      default:
        return 'Terjadi masalah jaringan.';
    }
  }
}

// --- RIVERPOD PROVIDER ---
// Provider untuk membuat instance repository
final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  final dio = createDio(); // Mengambil konfigurasi dio terpusat
  return CommentRepository(dio);
});

// Solusi yang jauh lebih bersih tanpa error (menggantikan AsyncNotifier yang rumit)
final commentsProvider = FutureProvider.autoDispose.family<List<Comment>, int>((ref, postId) async {
  // Langsung memanggil repository
  final repository = ref.read(commentRepositoryProvider);
  return repository.fetchComments(postId);
});