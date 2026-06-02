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
      final message = e.response?.data['detail'] ?? 'Erro de conexão com o servidor';
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
}
