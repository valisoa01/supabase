import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/network_info.dart';
import '../../../core/constants/supabase_config.dart';
import '../data/post_remote_datasource.dart';
import '../data/post_local_datasource.dart';
import '../data/post_repository_impl.dart';
import '../domain/post_repository.dart';
import '../domain/post.dart';

final _publicDioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    baseUrl: 'https://jsonplaceholder.typicode.com',
    headers: {'Content-Type': 'application/json'},
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
});

final postLocalDataSourceProvider = Provider<PostLocalDataSource>((ref) {
  throw UnimplementedError('Override in main with Hive box');
});

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepositoryImpl(
    remote: PostRemoteDataSource(ref.read(_publicDioProvider)),
    local: ref.read(postLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

final postListProvider =
    AsyncNotifierProvider.autoDispose<PostListNotifier, List<Post>>(
  PostListNotifier.new,
);

class PostListNotifier extends AutoDisposeAsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    return ref.read(postRepositoryProvider).getPosts();
  }

  Future<void> refreshPosts() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(postRepositoryProvider).getPosts(),
    );
  }
}

final postDetailProvider =
    FutureProvider.autoDispose.family<Post, int>((ref, id) async {
  return ref.read(postRepositoryProvider).getPost(id);
});
