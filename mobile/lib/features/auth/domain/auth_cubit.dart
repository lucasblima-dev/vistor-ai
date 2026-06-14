import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vistor_ai_mobile/core/api/token_storage.dart';
import 'package:vistor_ai_mobile/core/di/service_locator.dart';
import 'package:vistor_ai_mobile/core/services/notification_service.dart';
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
      await _tokenStorage.saveUser(user);
      emit(AuthState.authenticated(user));
      _updateFcmToken();
    } catch (e) {
      // Se falhar o getMe por indisponibilidade de rede, tenta usar o cache local
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOffline = connectivityResult == ConnectivityResult.none || _isConnectionError(e);
      if (isOffline) {
        final cachedUser = await _tokenStorage.getUser();
        if (cachedUser != null) {
          emit(AuthState.authenticated(cachedUser));
          return;
        }
      }

      // Se falhar o getMe com rede disponível, tentamos dar refresh antes de deslogar
      final refreshed = await _authRepository.refreshToken();
      if (refreshed) {
        try {
          final user = await _authRepository.getMe();
          await _tokenStorage.saveUser(user);
          emit(AuthState.authenticated(user));
          _updateFcmToken();
          return;
        } catch (_) {}
      }
      
      emit(const AuthState.unauthenticated());
    }
  }

  bool _isConnectionError(dynamic error) {
    if (error is AuthException) {
      final msg = error.message.toLowerCase();
      return msg.contains('conectar') || msg.contains('conexão') || msg.contains('servidor');
    }
    final errStr = error.toString().toLowerCase();
    return errStr.contains('connection') || errStr.contains('timeout') || errStr.contains('host') || errStr.contains('network') || errStr.contains('dioexception');
  }

  Future<void> login(String email, String password) async {
    emit(const AuthState.loading());
    try {
      await _authRepository.login(email, password);
      final user = await _authRepository.getMe();
      await _tokenStorage.saveUser(user);
      emit(AuthState.authenticated(user));
      _updateFcmToken();
    } on AuthException catch (e) {
      emit(AuthState.error(e.message));
    } catch (e) {
      emit(const AuthState.error('Ocorreu um erro inesperado.'));
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(const AuthState.loading());
    try {
      await _authRepository.signUp(
        name: name,
        email: email,
        password: password,
      );
      // Auto-login after registration
      await login(email, password);
    } on AuthException catch (e) {
      emit(AuthState.error(e.message));
    } catch (e) {
      emit(const AuthState.error('Ocorreu um erro inesperado ao realizar cadastro.'));
    }
  }

  Future<void> logout() async {
    try {
      await _authRepository.logout();
    } finally {
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _updateFcmToken() async {
    final token = await getIt<NotificationService>().getToken();
    if (token != null) {
      await _authRepository.updateFcmToken(token);
    }
  }

  Future<void> updateProfile({required String name, required String email}) async {
    try {
      final updatedUser = await _authRepository.updateMe(name: name, email: email);
      await _tokenStorage.saveUser(updatedUser);
      emit(AuthState.authenticated(updatedUser));
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Erro inesperado ao atualizar perfil.');
    }
  }

  Future<void> uploadAvatar(String filePath) async {
    try {
      final updatedUser = await _authRepository.uploadAvatar(filePath);
      await _tokenStorage.saveUser(updatedUser);
      emit(AuthState.authenticated(updatedUser));
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Erro inesperado ao enviar foto de perfil.');
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _authRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Erro inesperado ao alterar senha.');
    }
  }
}
