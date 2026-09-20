class Comment {
  final int postId;
  final int id;
  final String name;
  final String email;
  final String body;

  const Comment({
    required this.postId,
    required this.id,
    required this.name,
    required this.email,
    required this.body,
  });

  // Factory dari JSON dengan penanganan null-safety.
  // Jika field tidak ada (null), kita berikan nilai default (fallback).
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      postId: (json['postId'] as num?)?.toInt() ?? 0,
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? 'Tanpa Nama',
      email: json['email'] as String? ?? 'Tidak ada email',
      body: json['body'] as String? ?? '',
    );
  }
}