// settings.dart

class Settings {
  // API Configuration
  static const String apiBaseUrl = 'http://demo2.prowebsuite.com/api';
  static const String apiToken = "dd37e8604b471bf5df12dafdac61672416ff5e8d6a3575435758fc8709d6d626";

  // API Endpoints
  static const String getProduct = '$apiBaseUrl/routes.php?action=getproduct';
  static const String evidenza = '$apiBaseUrl/routes.php?action=getproduct&filter=evidenza';
  static const String categories = '$apiBaseUrl/routes.php?action=cate';
  static const String login = '$apiBaseUrl/routes.php?action=login';
  static const String register = '$apiBaseUrl/routes.php?action=register';


  static const int maxRetryAttempts = 3;
  static const Duration apiTimeout = Duration(seconds: 10);
}