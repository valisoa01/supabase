import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:supabase/features/posts/data/post_local_datasource.dart';
import 'package:supabase/features/posts/domain/post.dart';

void main() {
  late PostLocalDataSource dataSource;
  late Box<String> box;

  final tPosts = [
    const Post(id: 1, userId: 1, title: 'Title 1', body: 'Body 1'),
    const Post(id: 2, userId: 2, title: 'Title 2', body: 'Body 2'),
  ];

  setUp(() async {
    Hive.init('');
    box = await Hive.openBox<String>('test_posts_cache');
    dataSource = PostLocalDataSource(box);
  });

  tearDown(() async {
    await box.close();
    await Hive.deleteBoxFromDisk('test_posts_cache');
  });

  group('PostLocalDataSource', () {
    test('cachePosts should store posts as JSON', () async {
      await dataSource.cachePosts(tPosts);

      final raw = box.get('cached_posts');
      expect(raw, isNotNull);

      final decoded = jsonDecode(raw!) as List;
      expect(decoded.length, equals(2));
      expect(decoded[0]['title'], equals('Title 1'));
    });

    test('getCachedPosts should return empty list when no cache', () async {
      final result = await dataSource.getCachedPosts();

      expect(result, isEmpty);
    });

    test('getCachedPosts should return cached posts', () async {
      await dataSource.cachePosts(tPosts);

      final result = await dataSource.getCachedPosts();

      expect(result.length, equals(2));
      expect(result[0], equals(tPosts[0]));
      expect(result[1], equals(tPosts[1]));
    });

    test('cachePost should add a new post to cache', () async {
      await dataSource.cachePosts(tPosts);

      final newPost = const Post(id: 3, userId: 3, title: 'Title 3', body: 'Body 3');
      await dataSource.cachePost(newPost);

      final result = await dataSource.getCachedPosts();
      expect(result.length, equals(3));
      expect(result[2], equals(newPost));
    });

    test('cachePost should update existing post in cache', () async {
      await dataSource.cachePosts(tPosts);

      const updatedPost = Post(id: 1, userId: 1, title: 'Updated Title', body: 'Updated Body');
      await dataSource.cachePost(updatedPost);

      final result = await dataSource.getCachedPosts();
      expect(result.length, equals(2));
      expect(result[0].title, equals('Updated Title'));
    });

    test('clearCache should remove all cached posts', () async {
      await dataSource.cachePosts(tPosts);
      await dataSource.clearCache();

      final result = await dataSource.getCachedPosts();
      expect(result, isEmpty);
    });
  });
}
