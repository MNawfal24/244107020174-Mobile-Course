import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week4_api/data/models/post.dart';
import 'package:week4_api/data/repositories/post_repository.dart';
import 'package:week4_api/data/network_error.dart';

// Provider untuk mengetes repository
final postRepositoryProvider = Provider<PostRepository>((ref) => PostRepository(Dio()));

// Membuat Repository Palsu (Mock) yang seolah-olah mengambil data dari internet
class FakePostRepository extends PostRepository {
  FakePostRepository({this.items, this.throwError = false}) : super(Dio());
  final List<Post>? items;
  final bool throwError;

  @override
  Future<List<Post>> fetchPosts() async {
    if (throwError) {
      throw DioException(
        requestOptions: RequestOptions(path: '/posts'),
        type: DioExceptionType.connectionError,
      );
    }
    return items ?? const [];
  }
}

void main() {
  test('fromJson aman terhadap field yang hilang', () {
    final post = Post.fromJson({'id': 7});
    expect(post.id, 7);
    expect(post.title, '');
    expect(post.userId, 0);
  });

  test('friendlyErrorMessage untuk connection error', () {
    final err = DioException(
      requestOptions: RequestOptions(path: '/posts'),
      type: DioExceptionType.connectionError,
    );
    expect(friendlyErrorMessage(err), contains('terhubung'));
  });

  test('provider sukses dengan repository palsu', () async {
    final container = ProviderContainer(
      overrides: [
        postRepositoryProvider.overrideWithValue(
          FakePostRepository(
            items: [
              const Post(userId: 1, id: 1, title: 'Tes', body: 'Isi'),
            ],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    // Membaca data dari repository palsu
    final repository = container.read(postRepositoryProvider);
    final posts = await repository.fetchPosts();

    expect(posts.length, 1);
    expect(posts.first.title, 'Tes');
  });

  test('provider error dengan repository palsu', () async {
    final container = ProviderContainer(
      overrides: [
        postRepositoryProvider.overrideWithValue(
          FakePostRepository(throwError: true),
        ),
      ],
    );
    addTearDown(container.dispose);

    final repository = container.read(postRepositoryProvider);

    // Memastikan function benar-benar menghasilkan error
    expect(
      () async => await repository.fetchPosts(),
      throwsA(isA<DioException>()),
    );
  });
}