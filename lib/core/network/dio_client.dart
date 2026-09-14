import 'package:dio/dio.dart';
import '../constants/supabase_config.dart';
import '../storage/token_storage.dart';
import 'auth_interceptor.dart';

class DioClient {
  final TokenStorage tokenStorage;
  late final Dio restDio;
  late final Dio authDio;

  DioClient(this.tokenStorage) {
    restDio = Dio(BaseOptions(
      baseUrl: '${SupabaseConfig.projectUrl}/rest/v1',
      headers: {
        'apikey': SupabaseConfig.anonKey,
        'Content-Type': 'application/json',
      },
    ));
    restDio.interceptors.add(AuthInterceptor(restDio, tokenStorage));

    authDio = Dio(BaseOptions(
      baseUrl: '${SupabaseConfig.projectUrl}/auth/v1',
      headers: {
        'apikey': SupabaseConfig.anonKey,
        'Content-Type': 'application/json',
      },
    ));
  }
}