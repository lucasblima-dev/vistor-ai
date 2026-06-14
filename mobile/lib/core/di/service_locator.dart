import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:vistor_ai_mobile/core/api/api_client.dart';
import 'package:vistor_ai_mobile/core/api/token_storage.dart';
import 'package:vistor_ai_mobile/core/local/database.dart';
import 'package:vistor_ai_mobile/core/local/inspection_dao.dart';
import 'package:vistor_ai_mobile/core/local/sync_manager.dart';
import 'package:vistor_ai_mobile/core/services/theme_service.dart';
import 'package:vistor_ai_mobile/core/services/notification_service.dart';
import 'package:vistor_ai_mobile/features/auth/data/auth_repository.dart';
import 'package:vistor_ai_mobile/features/auth/data/user_repository.dart';
import 'package:vistor_ai_mobile/features/auth/data/admin_repository.dart';
import 'package:vistor_ai_mobile/features/auth/domain/auth_cubit.dart';
import 'package:vistor_ai_mobile/features/auth/domain/user_management_cubit.dart';
import 'package:vistor_ai_mobile/features/auth/domain/admin_settings_cubit.dart';
import 'package:vistor_ai_mobile/features/inspection/data/inspection_repository.dart';
import 'package:vistor_ai_mobile/features/inspection/domain/create_inspection_cubit.dart';
import 'package:vistor_ai_mobile/features/inspection/domain/inspection_cubit.dart';
import 'package:vistor_ai_mobile/features/inspection/domain/inspection_detail_cubit.dart';
import 'package:vistor_ai_mobile/features/inspection/domain/team_management_cubit.dart';
import 'package:vistor_ai_mobile/features/map/data/map_repository.dart';
import 'package:vistor_ai_mobile/features/map/domain/map_cubit.dart';
import 'package:vistor_ai_mobile/features/report/domain/repositories/report_repository.dart';
import 'package:vistor_ai_mobile/features/report/data/repositories/report_repository_impl.dart';
import 'package:vistor_ai_mobile/features/report/presentation/cubit/report_cubit.dart';
import 'package:vistor_ai_mobile/core/services/gps_service.dart';
import 'package:vistor_ai_mobile/core/services/media_service.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  // Services
  final themeService = await ThemeService.init();
  getIt.registerSingleton<ThemeService>(themeService);
  getIt.registerSingleton<NotificationService>(NotificationService());
  getIt.registerSingleton<ValueNotifier<ThemeMode>>(
    ValueNotifier(themeService.themeMode),
  );

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

  getIt.registerLazySingleton<UserRepository>(
    () => UserRepository(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<AdminRepository>(
    () => AdminRepository(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<InspectionRepository>(
    () => InspectionRepository(
      apiClient: getIt<ApiClient>(),
      inspectionDao: getIt<InspectionDao>(),
    ),
  );

  getIt.registerLazySingleton<ReportRepository>(
    () => ReportRepositoryImpl(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<MapRepository>(
    () => MapRepository(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<SyncManager>(
    () => SyncManager(
      getIt<ApiClient>(),
      getIt<InspectionDao>(),
      getIt<MediaService>(),
    ),
  );

  // Cubits
  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(
      authRepository: getIt<AuthRepository>(),
      tokenStorage: getIt<TokenStorage>(),
    ),
  );

  getIt.registerFactory<UserManagementCubit>(
    () => UserManagementCubit(
      userRepository: getIt<UserRepository>(),
    ),
  );

  getIt.registerFactory<AdminSettingsCubit>(
    () => AdminSettingsCubit(
      adminRepository: getIt<AdminRepository>(),
    ),
  );

  getIt.registerFactory<InspectionCubit>(
    () => InspectionCubit(
      repository: getIt<InspectionRepository>(),
    ),
  );

  getIt.registerFactory<TeamManagementCubit>(
    () => TeamManagementCubit(
      inspectionRepository: getIt<InspectionRepository>(),
      userRepository: getIt<UserRepository>(),
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

  getIt.registerFactory<MapCubit>(
    () => MapCubit(
      repository: getIt<MapRepository>(),
      gpsService: getIt<GpsService>(),
    ),
  );
}
