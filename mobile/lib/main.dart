import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vistor_ai_mobile/app/app.dart';
import 'package:vistor_ai_mobile/core/di/service_locator.dart';
import 'package:vistor_ai_mobile/core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa Hive
  await Hive.initFlutter();
  
  // Service Locator
  await setupLocator();
  
  // Inicializa Notificações (Stub)
  await getIt<NotificationService>().init();
  
  runApp(const VistorApp());
}
