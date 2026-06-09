import 'package:dio/dio.dart';
import 'package:vistor_ai_mobile/core/api/endpoints.dart';
import 'package:vistor_ai_mobile/core/api/token_storage.dart';
import 'package:vistor_ai_mobile/core/utils/env.dart';

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([this.message = 'Acesso negado']);
}

class ApiClient {
  late final Dio dio;
  final TokenStorage _tokenStorage = TokenStorage();
  bool _isRefreshing = false;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: '${Env.apiBaseUrl}/api',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Se for 401 e não estivermos já tentando dar refresh
          if (error.response?.statusCode == 401 && !_isRefreshing) {
            _isRefreshing = true;
            try {
              final refreshToken = await _tokenStorage.getRefreshToken();
              if (refreshToken == null) throw DioException(requestOptions: error.requestOptions);

              // Tenta dar refresh
              final response = await Dio(BaseOptions(baseUrl: '${Env.apiBaseUrl}/api')).post(
                AppEndpoints.refresh,
                data: {'refresh_token': refreshToken},
              );

              if (response.statusCode == 200) {
                final newAccessToken = response.data['access_token'];
                final newRefreshToken = response.data['refresh_token'];

                await _tokenStorage.saveTokens(
                  accessToken: newAccessToken,
                  refreshToken: newRefreshToken,
                );

                // Refaz a requisição original com o novo token
                error.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                final clonedRequest = await dio.request(
                  error.requestOptions.path,
                  options: Options(
                    method: error.requestOptions.method,
                    headers: error.requestOptions.headers,
                  ),
                  data: error.requestOptions.data,
                  queryParameters: error.requestOptions.queryParameters,
                );
                return handler.resolve(clonedRequest);
              }
            } catch (e) {
              // Se o refresh falhar, limpa tudo e vai para o login
              await _tokenStorage.clearTokens();
              // TODO: Navegar para /login (precisa de acesso ao router ou contexto global)
            } finally {
              _isRefreshing = false;
            }
          }

          if (error.response?.statusCode == 403) {
            return handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: UnauthorizedException(),
              ),
            );
          }

          return handler.next(error);
        },
      ),
    );
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) {
    return dio.post(path, data: data, queryParameters: queryParameters);
  }
}
