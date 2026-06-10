import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeService {
  static const _boxName = 'settings';
  static const _key = 'theme_mode';

  static Future<ThemeService> init() async {
    await Hive.openBox(_boxName);
    return ThemeService();
  }

  final Box _box = Hive.box(_boxName);

  ThemeMode get themeMode {
    final mode = _box.get(_key, defaultValue: 'system');
    return ThemeMode.values.firstWhere(
      (e) => e.name == mode,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _box.put(_key, mode.name);
  }
}
