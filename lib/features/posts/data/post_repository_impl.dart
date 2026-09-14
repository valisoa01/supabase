import 'package:dio/dio.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/network/network_info.dart';
import '../domain/post.dart';
import '../domain/post_repository.dart';
import 'post_remote_datasource.dart';
import 'post_local_datasource.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remote;
  final PostLocalDataSource local;
  final NetworkInfo networkInfo;

  PostRepositoryImpl({
    required this.remote,
    required this.local,
    required this.networkInfo,
  });

  @override
  Future<List<Post>> getPosts() async {
    if (await networkInfo.isConnected) {
      try {
        final posts = await remote.fetchPosts();
        await local.cachePosts(posts);
        return posts;
      } on DioException catch (e) {
        throw ServerException(
          _mapDioError(e),
          e.response?.statusCode,
        );
      }
    } else {
      final cached = await local.getCachedPosts();
      if (cached.isNotEmpty) return cached;
      throw const NetworkException();
    }
  }

  @override
  Future<Post> getPost(int id) async {
    if (await networkInfo.isConnected) {
      try {
        final post = await remote.fetchPost(id);
        await local.cachePost(post);
        return post;
      } on DioException catch (e) {
        throw ServerException(_mapDioError(e), e.response?.statusCode);
      }
    } else {
      final cached = await local.getCachedPosts();
      final match = cached.where((p) => p.id == id);
      if (match.isNotEmpty) return match.first;
      throw const NetworkException();
    }
  }

  @override
  Future<Post> createPost({required String title, required String body}) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkException(
        'Impossible de créer un post sans connexion Internet.',
      );
    }
    try {
      return await remote.createPost(title: title, body: body);
    } on DioException catch (e) {
      throw ServerException(_mapDioError(e), e.response?.statusCode);
    }
  }

  String _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Délai d\'attente dépassé. Réessayez.';
      case DioExceptionType.connectionError:
        return 'Pas de connexion au serveur.';
      case DioExceptionType.badResponse:
        return 'Erreur serveur (${e.response?.statusCode}).';
      case DioExceptionType.cancel:
        return 'Requête annulée.';
      default:
        return 'Erreur réseau inconnue.';
    }
  }
}
