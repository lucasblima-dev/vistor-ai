import 'package:get_it/get_it.dart';
import 'package:vistor_ai_mobile/core/api/api_client.dart';
import 'package:vistor_ai_mobile/core/api/token_storage.dart';
import 'package:vistor_ai_mobile/features/auth/data/auth_repository.dart';
import 'package:vistor_ai_mobile/features/auth/domain/auth_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  // Core
  final tokenStorage = TokenStorage();
  getIt.registerSingleton<TokenStorage>(tokenStorage);
  
  final apiClient = ApiClient();
  getIt.registerSingleton<ApiClient>(apiClient);

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      apiClient: getIt<ApiClient>(),
      tokenStorage: getIt<TokenStorage>(),
    ),
  );

  // Cubits
  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(
      authRepository: getIt<AuthRepository>(),
      tokenStorage: getIt<TokenStorage>(),
    ),
  );
}
