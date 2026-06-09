import 'package:get_it/get_it.dart';
import 'package:vistor_ai_mobile/core/api/api_client.dart';
import 'package:vistor_ai_mobile/core/api/token_storage.dart';
import 'package:vistor_ai_mobile/core/local/database.dart';
import 'package:vistor_ai_mobile/core/local/inspection_dao.dart';
import 'package:vistor_ai_mobile/features/auth/data/auth_repository.dart';
import 'package:vistor_ai_mobile/features/auth/domain/auth_cubit.dart';
import 'package:vistor_ai_mobile/features/inspection/data/inspection_repository.dart';
import 'package:vistor_ai_mobile/features/inspection/domain/create_inspection_cubit.dart';
import 'package:vistor_ai_mobile/features/inspection/domain/inspection_cubit.dart';
import 'package:vistor_ai_mobile/features/inspection/domain/inspection_detail_cubit.dart';
import 'package:vistor_ai_mobile/features/report/data/report_repository.dart';
import 'package:vistor_ai_mobile/features/report/domain/report_cubit.dart';
import 'package:vistor_ai_mobile/core/services/gps_service.dart';
import 'package:vistor_ai_mobile/core/services/media_service.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  // Database
  final database = AppDatabase();
  getIt.registerSingleton<AppDatabase>(database);
  getIt.registerSingleton<InspectionDao>(database.inspectionDao);

  // Core
  final tokenStorage = TokenStorage();
  getIt.registerSingleton<TokenStorage>(tokenStorage);
  
  final apiClient = ApiClient();
  getIt.registerSingleton<ApiClient>(apiClient);

  getIt.registerLazySingleton<MediaService>(
    () => MediaService(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<GpsService>(() => GpsService());

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      apiClient: getIt<ApiClient>(),
      tokenStorage: getIt<TokenStorage>(),
    ),
  );

  getIt.registerLazySingleton<InspectionRepository>(
    () => InspectionRepository(
      apiClient: getIt<ApiClient>(),
      inspectionDao: getIt<InspectionDao>(),
    ),
  );

  getIt.registerLazySingleton<ReportRepository>(
    () => ReportRepository(apiClient: getIt<ApiClient>()),
  );

  // Cubits
  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(
      authRepository: getIt<AuthRepository>(),
      tokenStorage: getIt<TokenStorage>(),
    ),
  );

  getIt.registerFactory<InspectionCubit>(
    () => InspectionCubit(
      repository: getIt<InspectionRepository>(),
    ),
  );

  getIt.registerFactory<CreateInspectionCubit>(
    () => CreateInspectionCubit(
      gpsService: getIt<GpsService>(),
      mediaService: getIt<MediaService>(),
      repository: getIt<InspectionRepository>(),
    ),
  );

  getIt.registerFactoryParam<InspectionDetailCubit, String, void>(
    (id, _) => InspectionDetailCubit(
      repository: getIt<InspectionRepository>(),
      inspectionId: id,
    ),
  );

  getIt.registerFactory<ReportCubit>(
    () => ReportCubit(repository: getIt<ReportRepository>()),
  );
}
