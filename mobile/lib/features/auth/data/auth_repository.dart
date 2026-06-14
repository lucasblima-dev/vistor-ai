import 'package:dio/dio.dart';
import 'package:vistor_ai_mobile/core/api/api_client.dart';
import 'package:vistor_ai_mobile/core/api/endpoints.dart';
import 'package:vistor_ai_mobile/core/api/token_storage.dart';
import 'package:vistor_ai_mobile/shared/models/user.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

class AuthRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  AuthRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  Future<void> login(String email, String password) async {
    try {
      final response = await _apiClient.dio.post(
        AppEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final accessToken = response.data['access_token'];
        final refreshToken = response.data['refresh_token'];

        await _tokenStorage.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      } else {
        final message = response.data['detail'] ?? 'Erro ao realizar login';
        throw AuthException(message);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw AuthException('Não foi possível conectar ao servidor. Verifique sua conexão e se o backend está rodando.');
      }
      final message = e.response?.data['detail'] ?? 'Erro inesperado no servidor';
      throw AuthException(message);
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        AppEndpoints.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'role': 'inspector', // Default role for new signups
        },
      );

      if (response.statusCode != 201) {
        final message = response.data['detail'] ?? 'Erro ao realizar cadastro';
        throw AuthException(message);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw AuthException('Não foi possível conectar ao servidor. Verifique sua conexão.');
      }
      final message = e.response?.data['detail'] ?? 'Erro inesperado ao realizar cadastro';
      throw AuthException(message);
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.dio.post(AppEndpoints.logout);
    } finally {
      await _tokenStorage.clearTokens();
    }
  }

  Future<bool> refreshToken() async {
    try {
      final currentRefreshToken = await _tokenStorage.getRefreshToken();
      if (currentRefreshToken == null) return false;

      final response = await _apiClient.dio.post(
        AppEndpoints.refresh,
        data: {'refresh_token': currentRefreshToken},
      );

      if (response.statusCode == 200) {
        final accessToken = response.data['access_token'];
        final refreshToken = response.data['refresh_token'];

        await _tokenStorage.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<User> getMe() async {
    try {
      final response = await _apiClient.dio.get(AppEndpoints.me);
      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      }
      throw AuthException('Não foi possível obter dados do usuário');
    } on DioException catch (e) {
      final message = e.response?.data['detail'] ?? 'Erro ao obter dados do usuário';
      throw AuthException(message);
    }
  }

  Future<void> updateFcmToken(String token) async {
    try {
      await _apiClient.dio.patch(
        AppEndpoints.fcmToken,
        data: {'fcm_token': token},
      );
    } catch (_) {
      // Falha silenciosa para não travar o login
    }
  }

  Future<User> updateMe({required String name, required String email}) async {
    try {
      final response = await _apiClient.dio.patch(
        AppEndpoints.updateMe,
        data: {
          'name': name,
          'email': email,
        },
      );
      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      }
      final message = response.data['detail'] ?? 'Erro ao atualizar dados do perfil';
      throw AuthException(message);
    } on DioException catch (e) {
      final message = e.response?.data['detail'] ?? 'Erro ao atualizar dados do perfil';
      throw AuthException(message);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        AppEndpoints.changePassword,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        final message = response.data['detail'] ?? 'Erro ao alterar senha';
        throw AuthException(message);
      }
    } on DioException catch (e) {
      final message = e.response?.data['detail'] ?? 'Erro ao alterar senha';
      throw AuthException(message);
    }
  }
}

