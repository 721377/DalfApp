// settings.dart

class Settings {
  // API Configuration
  static const String apiBaseUrl = 'http://192.168.0.8/sviluppo/mohamed/web_dalfcarni/api';
  static const String apiToken = "dd37e8604b471bf5df12dafdac61672416ff5e8d6a3575435758fc8709d6d626";

  // API Endpoints
  static const String getProduct = '$apiBaseUrl/routes.php?action=getproduct';
  static const String evidenza = '$apiBaseUrl/routes.php?action=getproduct&filter=evidenza';
  static const String categories = '$apiBaseUrl/routes.php?action=cate';
  static const String login = '$apiBaseUrl/routes.php?action=login';
  static const String register = '$apiBaseUrl/routes.php?action=register';
  static const String updateUser = '$apiBaseUrl/routes.php?action=updateuser';
  static const String sendOrder = '$apiBaseUrl/routes.php?action=sendorder';
  static const int maxRetryAttempts = 3;
  static const Duration apiTimeout = Duration(seconds: 10);
  
 static const String alias = "ALIAS_WEB_00090690";
  static const String secretKey = "IQ7CDB50XANRHHT0M4AL4DZP3X4MUBOT";
  static const String group = "GRP_184527";
  static const String paymentUrl = "https://int-ecommerce.nexi.it/ecomm/ecomm/DispatcherServlet";
  static const String terminalId = "00090691";
 
}