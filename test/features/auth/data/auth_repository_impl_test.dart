import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase/core/storage/token_storage.dart';
import 'package:supabase/features/auth/data/auth_remote_datasource.dart';
import 'package:supabase/features/auth/data/auth_repository_impl.dart';

@GenerateMocks([AuthRemoteDataSource, TokenStorage])
import 'auth_repository_impl_test.mocks.dart';

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemote;
  late MockTokenStorage mockTokenStorage;

  setUp(() {
    mockRemote = MockAuthRemoteDataSource();
    mockTokenStorage = MockTokenStorage();
    repository = AuthRepositoryImpl(mockRemote, mockTokenStorage);
  });

  group('AuthRepositoryImpl', () {
    test('login should save tokens on success', () async {
      when(mockRemote.login('test@email.com', 'password123')).thenAnswer(
        (_) async => {
          'access_token': 'access_token_value',
          'refresh_token': 'refresh_token_value',
        },
      );
      when(mockTokenStorage.saveTokens(
        access: anyNamed('access'),
        refresh: anyNamed('refresh'),
      )).thenAnswer((_) async {});

      await repository.login('test@email.com', 'password123');

      verify(mockTokenStorage.saveTokens(
        access: 'access_token_value',
        refresh: 'refresh_token_value',
      )).called(1);
    });

    test('register should save tokens when access_token is returned', () async {
      when(mockRemote.register('test@email.com', 'password123')).thenAnswer(
        (_) async => {
          'access_token': 'new_access',
          'refresh_token': 'new_refresh',
        },
      );
      when(mockTokenStorage.saveTokens(
        access: anyNamed('access'),
        refresh: anyNamed('refresh'),
      )).thenAnswer((_) async {});

      await repository.register('test@email.com', 'password123');

      verify(mockTokenStorage.saveTokens(
        access: 'new_access',
        refresh: 'new_refresh',
      )).called(1);
    });

    test('register should NOT save tokens when access_token is null', () async {
      when(mockRemote.register('test@email.com', 'password123')).thenAnswer(
        (_) async => {'user': {'id': '123'}},
      );

      await repository.register('test@email.com', 'password123');

      verifyNever(mockTokenStorage.saveTokens(
        access: anyNamed('access'),
        refresh: anyNamed('refresh'),
      ));
    });

    test('logout should clear tokens', () async {
      when(mockTokenStorage.clear()).thenAnswer((_) async {});

      await repository.logout();

      verify(mockTokenStorage.clear()).called(1);
    });

    test('isLoggedIn should return true when token exists', () async {
      when(mockTokenStorage.hasSession()).thenAnswer((_) async => true);

      final result = await repository.isLoggedIn();

      expect(result, isTrue);
    });

    test('isLoggedIn should return false when no token', () async {
      when(mockTokenStorage.hasSession()).thenAnswer((_) async => false);

      final result = await repository.isLoggedIn();

      expect(result, isFalse);
    });

    test('login should propagate remote exceptions', () async {
      when(mockRemote.login('bad@email.com', 'wrong'))
          .thenThrow(Exception('Invalid login credentials'));

      expect(
        () => repository.login('bad@email.com', 'wrong'),
        throwsException,
      );
    });
  });
}
