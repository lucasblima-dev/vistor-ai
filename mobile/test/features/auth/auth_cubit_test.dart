import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vistor_ai_mobile/core/api/token_storage.dart';
import 'package:vistor_ai_mobile/features/auth/data/auth_repository.dart';
import 'package:vistor_ai_mobile/features/auth/domain/auth_cubit.dart';
import 'package:vistor_ai_mobile/features/auth/domain/auth_state.dart';
import 'package:vistor_ai_mobile/shared/models/user.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  late AuthRepository authRepository;
  late TokenStorage tokenStorage;
  late AuthCubit authCubit;

  const tUser = User(
    id: '1',
    email: 'test@example.com',
    name: 'Test User',
    role: UserRole.inspector,
  );

  setUp(() {
    authRepository = MockAuthRepository();
    tokenStorage = MockTokenStorage();
    authCubit = AuthCubit(
      authRepository: authRepository,
      tokenStorage: tokenStorage,
    );
  });

  group('AuthCubit - Login', () {
    blocTest<AuthCubit, AuthState>(
      'emits [loading, authenticated] when login is successful',
      build: () {
        when(() => authRepository.login(any(), any())).thenAnswer((_) async => {});
        when(() => authRepository.getMe()).thenAnswer((_) async => tUser);
        return authCubit;
      },
      act: (cubit) => cubit.login('test@example.com', 'password'),
      expect: () => [
        const AuthState.loading(),
        const AuthState.authenticated(tUser),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [loading, error] when login fails',
      build: () {
        when(() => authRepository.login(any(), any()))
            .thenThrow(AuthException('Credenciais inválidas'));
        return authCubit;
      },
      act: (cubit) => cubit.login('test@example.com', 'wrong'),
      expect: () => [
        const AuthState.loading(),
        const AuthState.error('Credenciais inválidas'),
      ],
    );
  });

  group('AuthCubit - Logout', () {
    blocTest<AuthCubit, AuthState>(
      'emits unauthenticated when logout is called',
      build: () {
        when(() => authRepository.logout()).thenAnswer((_) async => {});
        return authCubit;
      },
      act: (cubit) => cubit.logout(),
      expect: () => [
        const AuthState.unauthenticated(),
      ],
    );
  });
}
