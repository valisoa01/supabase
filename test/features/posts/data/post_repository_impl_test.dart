import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase/core/error/app_exception.dart';
import 'package:supabase/core/network/network_info.dart';
import 'package:supabase/features/posts/data/post_local_datasource.dart';
import 'package:supabase/features/posts/data/post_remote_datasource.dart';
import 'package:supabase/features/posts/data/post_repository_impl.dart';
import 'package:supabase/features/posts/domain/post.dart';

@GenerateMocks([PostRemoteDataSource, PostLocalDataSource, NetworkInfo])
import 'post_repository_impl_test.mocks.dart';

void main() {
  late PostRepositoryImpl repository;
  late MockPostRemoteDataSource mockRemote;
  late MockPostLocalDataSource mockLocal;
  late MockNetworkInfo mockNetworkInfo;

  final tPosts = [
    const Post(id: 1, userId: 1, title: 'Test Title 1', body: 'Test Body 1'),
    const Post(id: 2, userId: 2, title: 'Test Title 2', body: 'Test Body 2'),
  ];

  final tPost = const Post(id: 1, userId: 1, title: 'Test Title 1', body: 'Test Body 1');

  setUp(() {
    mockRemote = MockPostRemoteDataSource();
    mockLocal = MockPostLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = PostRepositoryImpl(
      remote: mockRemote,
      local: mockLocal,
      networkInfo: mockNetworkInfo,
    );
  });

  group('getPosts - Online', () {
    setUp(() {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
    });

    test('should return remote posts and cache them when online', () async {
      when(mockRemote.fetchPosts()).thenAnswer((_) async => tPosts);
      when(mockLocal.cachePosts(tPosts)).thenAnswer((_) async {});

      final result = await repository.getPosts();

      expect(result, equals(tPosts));
      verify(mockRemote.fetchPosts()).called(1);
      verify(mockLocal.cachePosts(tPosts)).called(1);
    });

    test('should throw ServerException when remote call fails', () async {
      when(mockRemote.fetchPosts()).thenThrow(Exception('Server error'));

      expect(
        () => repository.getPosts(),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('getPosts - Offline', () {
    setUp(() {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
    });

    test('should return cached posts when offline', () async {
      when(mockLocal.getCachedPosts()).thenAnswer((_) async => tPosts);

      final result = await repository.getPosts();

      expect(result, equals(tPosts));
      verify(mockLocal.getCachedPosts()).called(1);
      verifyNever(mockRemote.fetchPosts());
    });

    test('should throw NetworkException when cache is empty and offline', () async {
      when(mockLocal.getCachedPosts()).thenAnswer((_) async => []);

      expect(
        () => repository.getPosts(),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('getPost', () {
    test('should return remote post when online', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemote.fetchPost(1)).thenAnswer((_) async => tPost);
      when(mockLocal.cachePost(tPost)).thenAnswer((_) async {});

      final result = await repository.getPost(1);

      expect(result, equals(tPost));
      verify(mockRemote.fetchPost(1)).called(1);
      verify(mockLocal.cachePost(tPost)).called(1);
    });

    test('should return cached post when offline', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(mockLocal.getCachedPosts()).thenAnswer((_) async => tPosts);

      final result = await repository.getPost(1);

      expect(result, equals(tPost));
    });
  });

  group('createPost', () {
    final tNewPost = const Post(id: 101, userId: 1, title: 'New', body: 'Content');

    test('should create post when online', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemote.createPost(title: 'New', body: 'Content'))
          .thenAnswer((_) async => tNewPost);

      final result = await repository.createPost(title: 'New', body: 'Content');

      expect(result, equals(tNewPost));
    });

    test('should throw NetworkException when offline', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      expect(
        () => repository.createPost(title: 'New', body: 'Content'),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
