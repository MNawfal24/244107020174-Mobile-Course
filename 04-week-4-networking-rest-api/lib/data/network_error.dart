import 'package:dio/dio.dart';

String friendlyErrorMessage(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
      return 'Waktu koneksi habis. Silakan periksa jaringan Anda.';
    case DioExceptionType.connectionError:
      return 'Gagal terhubung ke server. Pastikan internet Anda aktif.';
    case DioExceptionType.badResponse:
      final statusCode = e.response?.statusCode;
      if (statusCode == 404) return 'Data tidak ditemukan (404).';
      if (statusCode == 500) return 'Terjadi gangguan pada server (500).';
      return 'Terjadi kesalahan server ($statusCode).';
    default:
      return 'Terjadi masalah jaringan.';
  }
}