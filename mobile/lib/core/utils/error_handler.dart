import 'package:dio/dio.dart';
import 'package:vistor_ai_mobile/core/api/api_client.dart';

class ErrorHandler {
  /// Higieniza e formata qualquer tipo de erro/exceção para exibição segura ao usuário final.
  static String handle(Object error, [String defaultMessage = 'Ocorreu um erro inesperado']) {
    if (error is DioException) {
      return error.getErrorMessage(defaultMessage);
    }
    
    final errorStr = error.toString().replaceAll('Exception: ', '');
    final lower = errorStr.toLowerCase();
    
    // Lista de termos técnicos locais/servidor que não devem ser mostrados ao usuário comum
    final techKeywords = [
      'typeerror', 'nullpointer', 'nosuchmethod', 'rangeerror', 'formatexception',
      'unimplementederror', 'stateerror', 'outofmemory', 'stacktrace', 'stack overflow',
      'cast', 'subtype', 'initialize', 'late initialization', 'missing', 'failed', 
      'cannot', 'could not', 'minio', 's3', 'sqlalchemy', 'postgres', 'redis', 'exception',
      'bad response', 'http', 'socket', 'connection refused', 'failed host', 'internal server'
    ];
    
    if (techKeywords.any((keyword) => lower.contains(keyword))) {
      return defaultMessage;
    }
    
    return errorStr;
  }
}
