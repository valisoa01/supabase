import '../domain/auth_repository.dart';
import '../../../core/storage/token_storage.dart';
import 'auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final TokenStorage tokenStorage;
  AuthRepositoryImpl(this.remote, this.tokenStorage);

  @override
  Future<void> login(String email, String password) async {
    final data = await remote.login(email, password);
    await tokenStorage.saveTokens(
      access: data['access_token'],
      refresh: data['refresh_token'],
    );
  }

  @override
  Future<void> register(String email, String password) async {
    final data = await remote.register(email, password);
    if (data['access_token'] != null) {
      await tokenStorage.saveTokens(
        access: data['access_token'],
        refresh: data['refresh_token'],
      );
    }
  }

  @override
  Future<void> logout() => tokenStorage.clear();

  @override
  Future<bool> isLoggedIn() => tokenStorage.hasSession();
}