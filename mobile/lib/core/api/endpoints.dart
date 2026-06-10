class AppEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String fcmToken = '/users/me/fcm-token';

  // Inspections
  static const String inspections = '/inspections/';
  static String inspectionDetail(String id) => '/inspections/$id';
  static String inspectionUpdate(String id) => '/inspections/$id';
  static String inspectionDelete(String id) => '/inspections/$id';

  // Geo
  static const String nearby = '/geo/nearby';
  static const String export = '/geo/export';

  // Media
  static const String presign = '/media/presign';
  static String mediaConfirm(String id) => '/media/$id/confirm';
  static String mediaUrl(String id) => '/media/$id/url';

  // Reports
  static const String generateReport = '/reports/generate';
  static String reportDetail(String id) => '/reports/$id';

  // Users
  static const String users = '/users/';
  static String userDetail(String id) => '/users/$id';
  static String userUpdate(String id) => '/users/$id';

  // Team
  static const String teamQueue = '/team/queue';
}
