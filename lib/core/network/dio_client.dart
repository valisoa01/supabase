import 'package:dio/dio.dart';
import '../constants/supabase_config.dart';
import '../storage/token_storage.dart';
import 'auth_interceptor.dart';

class DioClient {
  final TokenStorage tokenStorage;
  late final Dio restDio;
  late final Dio authDio;

  static const _connectTimeout = Duration(seconds: 15);
  static const _receiveTimeout = Duration(seconds: 15);

  DioClient(this.tokenStorage) {
    restDio = Dio(BaseOptions(
      baseUrl: '${SupabaseConfig.projectUrl}/rest/v1',
      headers: {
        'apikey': SupabaseConfig.anonKey,
        'Content-Type': 'application/json',
      },
      connectTimeout: _connectTimeout,
      receiveTimeout: _receiveTimeout,
    ));
    restDio.interceptors.add(AuthInterceptor(this, tokenStorage));

    authDio = Dio(BaseOptions(
      baseUrl: '${SupabaseConfig.projectUrl}/auth/v1',
      headers: {
        'apikey': SupabaseConfig.anonKey,
        'Content-Type': 'application/json',
      },
      connectTimeout: _connectTimeout,
      receiveTimeout: _receiveTimeout,
    ));
  }

  Dio get authClient => authDio;
  Dio get restClient => restDio;
}
