import 'package:dio/dio.dart';
import '../constants/supabase_config.dart';
import '../storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final TokenStorage tokenStorage;
  AuthInterceptor(this.dio, this.tokenStorage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await tokenStorage.getAccessToken();
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer ${await tokenStorage.getAccessToken()}';
        try {
          final clone = await dio.fetch(opts);
          return handler.resolve(clone);
        } catch (e) {
          return handler.next(err);
        }
      }
    }
    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    final refreshToken = await tokenStorage.getRefreshToken();
    if (refreshToken == null) return false;
    try {
      final res = await Dio(BaseOptions(
        baseUrl: '${SupabaseConfig.projectUrl}/auth/v1',
        headers: {'apikey': SupabaseConfig.anonKey},
      )).post('/token?grant_type=refresh_token', data: {'refresh_token': refreshToken});
      await tokenStorage.saveTokens(
        access: res.data['access_token'],
        refresh: res.data['refresh_token'],
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}