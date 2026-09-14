import 'package:dio/dio.dart';
import '../constants/supabase_config.dart';
import '../storage/token_storage.dart';
import 'dio_client.dart';

class AuthInterceptor extends Interceptor {
  final DioClient _dioClient;
  final TokenStorage tokenStorage;
  bool _isRefreshing = false;

  AuthInterceptor(this._dioClient, this.tokenStorage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final token = await tokenStorage.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    } catch (e) {
      handler.next(options);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshed = await _refreshToken();
        if (refreshed) {
          final token = await tokenStorage.getAccessToken();
          if (token != null) {
            err.requestOptions.headers['Authorization'] = 'Bearer $token';
          }
          try {
            final clone = await _dioClient.authClient.fetch(err.requestOptions);
            return handler.resolve(clone);
          } on DioException {
            return handler.next(err);
          }
        } else {
          await tokenStorage.clear();
          return handler.next(err);
        }
      } catch (_) {
        return handler.next(err);
      } finally {
        _isRefreshing = false;
      }
    }
    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    final refreshToken = await tokenStorage.getRefreshToken();
    if (refreshToken == null) return false;
    try {
      final dio = Dio(BaseOptions(
        baseUrl: '${SupabaseConfig.projectUrl}/auth/v1',
        headers: {'apikey': SupabaseConfig.anonKey},
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));
      final res = await dio.post(
        '/token?grant_type=refresh_token',
        data: {'refresh_token': refreshToken},
      );
      await tokenStorage.saveTokens(
        access: res.data['access_token'],
        refresh: res.data['refresh_token'],
      );
      return true;
    } on DioException {
      await tokenStorage.clear();
      return false;
    } catch (_) {
      return false;
    }
  }
}
