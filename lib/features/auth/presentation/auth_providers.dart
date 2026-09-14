import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/network/dio_client.dart';
import '../data/auth_remote_datasource.dart';
import '../data/auth_repository_impl.dart';
import '../domain/auth_repository.dart';

final tokenStorageProvider = Provider((ref) => TokenStorage());

final dioClientProvider = Provider((ref) => DioClient(ref.read(tokenStorageProvider)));

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.read(dioClientProvider);
  final tokenStorage = ref.read(tokenStorageProvider);
  return AuthRepositoryImpl(AuthRemoteDataSource(dio.authDio), tokenStorage);
});