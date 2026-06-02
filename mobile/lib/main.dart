import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vistor_ai_mobile/app/app.dart';
import 'package:vistor_ai_mobile/core/di/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa Hive
  await Hive.initFlutter();
  
  // Service Locator
  await setupLocator();
  
  runApp(const VistorApp());
}
