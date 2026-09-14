import 'post.dart';

abstract class PostRepository {
  Future<List<Post>> getPosts();
  Future<Post> getPost(int id);
  Future<Post> createPost({required String title, required String body});
}
