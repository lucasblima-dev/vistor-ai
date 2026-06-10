import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vistor_ai_mobile/app/theme.dart';
import 'package:vistor_ai_mobile/app/router.dart';
import 'package:vistor_ai_mobile/core/di/service_locator.dart';
import 'package:vistor_ai_mobile/features/auth/domain/auth_cubit.dart';
import 'package:vistor_ai_mobile/features/inspection/domain/inspection_cubit.dart';
import 'package:vistor_ai_mobile/features/map/domain/map_cubit.dart';
import 'package:vistor_ai_mobile/features/report/domain/report_cubit.dart';

class VistorApp extends StatefulWidget {
  const VistorApp({super.key});

  @override
  State<VistorApp> createState() => _VistorAppState();
}

class _VistorAppState extends State<VistorApp> {
  late final AuthCubit _authCubit;

  @override
  void initState() {
    super.initState();
    _authCubit = getIt<AuthCubit>()..checkAuth();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authCubit),
        BlocProvider(create: (context) => getIt<InspectionCubit>()),
        BlocProvider(create: (context) => getIt<ReportCubit>()),
        BlocProvider(create: (context) => getIt<MapCubit>()),
      ],
      child: MaterialApp.router(
        title: 'Vistor AI',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        theme: lightTheme(),
        darkTheme: darkTheme(),
        locale: const Locale('pt', 'BR'),
        routerConfig: buildRouter(_authCubit),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('pt', 'BR'),
        ],
      ),
    );
  }
}
