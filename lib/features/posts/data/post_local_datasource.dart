import 'dart:convert';
import 'package:hive/hive.dart';
import '../domain/post.dart';

class PostLocalDataSource {
  final Box<String> box;

  PostLocalDataSource(this.box);

  static const String _postsKey = 'cached_posts';

  Future<void> cachePosts(List<Post> posts) async {
    final jsonData = posts.map((p) => p.toJson()).toList();
    await box.put(_postsKey, jsonEncode(jsonData));
  }

  Future<List<Post>> getCachedPosts() async {
    final raw = box.get(_postsKey);
    if (raw == null) return [];
    final List decoded = jsonDecode(raw);
    return decoded.map((json) => Post.fromJson(json)).toList();
  }

  Future<void> cachePost(Post post) async {
    final posts = await getCachedPosts();
    final index = posts.indexWhere((p) => p.id == post.id);
    if (index >= 0) {
      posts[index] = post;
    } else {
      posts.add(post);
    }
    await cachePosts(posts);
  }

  Future<void> clearCache() async {
    await box.delete(_postsKey);
  }
}
