import 'package:flutter_test/flutter_test.dart';
// Sesuaikan dengan nama project Anda jika berbeda
import 'package:week4_api/data/models/comment.dart'; 

void main() {
  group('Comment Model Tests', () {
    test('fromJson menangani data JSON yang lengkap dengan benar', () {
      final json = {
        "postId": 1,
        "id": 1,
        "name": "Budi",
        "email": "budi@gmail.com",
        "body": "Komentar bagus"
      };

      final comment = Comment.fromJson(json);

      expect(comment.id, 1);
      expect(comment.name, "Budi");
    });

    test('fromJson kebal (null-safe) terhadap field JSON yang hilang', () {
      // JSON sengaja dibuat tidak lengkap (misal: email dan body hilang/null)
      final incompleteJson = {
        "postId": 2,
        "id": 5,
        "name": null, // Diisi null
        // email tidak ada sama sekali
      };

      final comment = Comment.fromJson(incompleteJson);

      // Verifikasi bahwa aplikasi tidak crash dan fallback default berjalan
      expect(comment.postId, 2);
      expect(comment.id, 5);
      expect(comment.name, 'Tanpa Nama'); // Teks default
      expect(comment.email, 'Tidak ada email'); // Teks default
      expect(comment.body, ''); // Teks default
    });
  });
}