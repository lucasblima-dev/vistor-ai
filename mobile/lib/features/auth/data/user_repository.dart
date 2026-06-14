import 'package:dio/dio.dart';
import 'package:vistor_ai_mobile/core/api/api_client.dart';
import 'package:vistor_ai_mobile/core/api/endpoints.dart';
import 'package:vistor_ai_mobile/shared/models/user.dart';

class UserRepository {
  final ApiClient _apiClient;

  UserRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<User>> getAll({UserRole? role, bool? isActive}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (role != null) {
        queryParams['role'] = role.name;
      }
      if (isActive != null) {
        queryParams['is_active'] = isActive;
      }

      final response = await _apiClient.dio.get(
        AppEndpoints.users,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => User.fromJson(json)).toList();
      }
      throw Exception('Erro ao buscar usuários');
    } on DioException catch (e) {
      throw Exception(e.getErrorMessage('Erro ao buscar usuários'));
    }
  }

  Future<User> updateRole(String userId, UserRole role) async {
    try {
      final response = await _apiClient.dio.patch(
        AppEndpoints.userUpdate(userId),
        data: {'role': role.name},
      );

      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      }
      throw Exception('Erro ao atualizar papel do usuário');
    } on DioException catch (e) {
      throw Exception(e.getErrorMessage('Erro ao atualizar papel do usuário'));
    }
  }

  Future<User> toggleActive(String userId, bool isActive) async {
    try {
      final response = await _apiClient.dio.patch(
        AppEndpoints.userUpdate(userId),
        data: {'is_active': isActive},
      );

      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      }
      throw Exception('Erro ao alterar status do usuário');
    } on DioException catch (e) {
      throw Exception(e.getErrorMessage('Erro ao alterar status do usuário'));
    }
  }

  Future<User> create({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        AppEndpoints.users,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'role': role.name,
        },
      );

      if (response.statusCode == 201) {
        return User.fromJson(response.data);
      }
      throw Exception('Erro ao criar usuário');
    } on DioException catch (e) {
      throw Exception(e.getErrorMessage('Erro ao criar usuário'));
    }
  }
}
