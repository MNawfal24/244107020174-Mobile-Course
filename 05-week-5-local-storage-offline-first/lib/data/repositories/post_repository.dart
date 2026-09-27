import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';
import '../local/db.dart';
import '../models/post.dart';

class PostRepository {
  // Constructor sekarang menerima Dio dan SQLite db
  PostRepository(this._dio, {Future<Database> Function()? openDb})
      : _openDb = openDb ?? openNotesDb;

  final Dio _dio;
  final Future<Database> Function() _openDb;

  // ---------------------------------------------------------
  // [BARU] 1. Fungsi membaca data dari tabel SQLite (Cache)
  // ---------------------------------------------------------
  Future<List<Post>> readCachedPosts() async {
    final db = await _openDb();
    final rows = await db.query('cached_posts', orderBy: 'id ASC');
    if (rows.isEmpty) return [];

    return rows.map((row) {
      // Mengubah string JSON yang tersimpan kembali menjadi objek Post
      final payload = jsonDecode(row['payload'] as String);
      return Post.fromJson(payload);
    }).toList();
  }

  // ---------------------------------------------------------
  // [BARU] 2. Fungsi menimpa (save) data dari internet ke SQLite
  // ---------------------------------------------------------
  Future<void> _savePostsToCache(List<dynamic> data) async {
    final db = await _openDb();
    final batch = db.batch();
    batch.delete('cached_posts'); // Hapus cache lama
    
    for (var item in data) {
      batch.insert('cached_posts', {
        'id': item['id'],
        'payload': jsonEncode(item),
        'cached_at': DateTime.now().toIso8601String(),
      });
    }
    await batch.commit(noResult: true);
  }

  // ---------------------------------------------------------
  // [BARU] 3. Fungsi mengambil data dari API di latar belakang
  // ---------------------------------------------------------
  Future<void> refreshPostsInBackground() async {
    try {
      final response = await _dio.get('/posts');
      final data = response.data as List?;
      if (data != null) {
        await _savePostsToCache(data);
      }
    } catch (e) {
      // Abaikan error jika gagal (misal karena benar-benar offline)
    }
  }

  // ---------------------------------------------------------
  // [BARU] 4. Logika Utama Praktikum 3: Cache-First Read
  // ---------------------------------------------------------
  Future<List<Post>> loadPostsCacheFirst({bool forceOffline = false}) async {
    // 1. Segera kembalikan cache agar UI tidak blank saat offline.
    final cached = await readCachedPosts();

    // 2. Di background: fetch Dio -> simpan ke cached_posts
    // Jika forceOffline aktif, jangan lakukan request internet
    if (!forceOffline) {
      refreshPostsInBackground();
    }

    return cached;
  }
}