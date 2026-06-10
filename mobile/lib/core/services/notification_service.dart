import 'package:flutter/foundation.dart';

class NotificationService {
  Future<void> init() async {
    if (kDebugMode) {
      print("🔔 NotificationService stub initialized (Firebase disabled).");
    }
  }

  Future<void> requestPermission() async {
    // No-op
  }

  Future<String?> getToken() async {
    // Return null as Firebase is disabled
    return null;
  }
}
