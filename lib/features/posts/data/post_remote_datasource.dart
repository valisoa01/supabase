import 'package:dio/dio.dart';
import '../domain/post.dart';

class PostRemoteDataSource {
  final Dio dio;
  PostRemoteDataSource(this.dio);

  Future<List<Post>> fetchPosts() async {
    final response = await dio.get('/posts');
    return (response.data as List).map((json) => Post.fromJson(json)).toList();
  }

  Future<Post> fetchPost(int id) async {
    final response = await dio.get('/posts/$id');
    return Post.fromJson(response.data);
  }

  Future<Post> createPost({required String title, required String body}) async {
    final response = await dio.post('/posts', data: {
      'title': title,
      'body': body,
      'userId': 1,
    });
    return Post.fromJson(response.data);
  }
}
