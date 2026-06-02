import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vistor_ai_mobile/core/api/token_storage.dart';
import 'package:vistor_ai_mobile/features/auth/data/auth_repository.dart';
import 'package:vistor_ai_mobile/features/auth/domain/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final TokenStorage _tokenStorage;

  AuthCubit({
    required AuthRepository authRepository,
    required TokenStorage tokenStorage,
  })  : _authRepository = authRepository,
        _tokenStorage = tokenStorage,
        super(const AuthState.initial());

  Future<void> checkAuth() async {
    final token = await _tokenStorage.getAccessToken();
    if (token == null) {
      emit(const AuthState.unauthenticated());
      return;
    }

    try {
      emit(const AuthState.loading());
      final user = await _authRepository.getMe();
      emit(AuthState.authenticated(user));
    } catch (e) {
      // Se falhar o getMe, tentamos dar refresh antes de deslogar
      final refreshed = await _authRepository.refreshToken();
      if (refreshed) {
        try {
          final user = await _authRepository.getMe();
          emit(AuthState.authenticated(user));
          return;
        } catch (_) {}
      }
      
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    emit(const AuthState.loading());
    try {
      await _authRepository.login(email, password);
      final user = await _authRepository.getMe();
      emit(AuthState.authenticated(user));
    } on AuthException catch (e) {
      emit(AuthState.error(e.message));
    } catch (e) {
      emit(AuthState.error('Ocorreu um erro inesperado.'));
    }
  }

  Future<void> logout() async {
    try {
      await _authRepository.logout();
    } finally {
      emit(const AuthState.unauthenticated());
    }
  }
}
