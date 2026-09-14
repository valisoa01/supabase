import 'package:dio/dio.dart';

class AuthRemoteDataSource {
  final Dio authDio;
  AuthRemoteDataSource(this.authDio);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await authDio.post('/token?grant_type=password',
        data: {'email': email, 'password': password});
    return res.data;
  }

  Future<Map<String, dynamic>> register(String email, String password) async {
    final res = await authDio.post('/signup', data: {'email': email, 'password': password});
    return res.data;
  }
}