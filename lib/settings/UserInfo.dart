import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserData {
  // Method to fetch user data
  static Future<Map<String, dynamic>> getUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('userData');
    if (userData != null) {
      return json.decode(userData);
    }
    return {};  
  }


  static Future<String?> getUserId() async {
    final userData = await getUserData();
    return userData['cpc']?.toString();
  }

 
  static Future<String?> getUserEmail() async {
    final userData = await getUserData();
    return userData['email']?.toString();
  }


  static Future<String?> getUserName() async {
    final userData = await getUserData();
    return userData['fullname']?.toString();
  }

  static Future<String?> getUserAddress() async {
    final userData = await getUserData();
    return userData['address']?.toString();
  }

  static Future<String?> getUserCity() async {
    final userData = await getUserData();
    return userData['city']?.toString();
  }


  static Future<String?> getUserPostalCode() async {
    final userData = await getUserData();
    return userData['cap']?.toString();
  }

  static Future<String?> getUserPhone() async {
    final userData = await getUserData();
    return userData['phone']?.toString();
  }


  static Future<String?> getUserType() async {
    final userData = await getUserData();
    return userData['type']?.toString();
  }

  // Method to update user data
  static Future<void> updateUserData({
    String? userId,
    String? userName,
    String? userEmail,
    String? userAddress,
    String? userCity,
    String? userPostalCode,
    String? userPhone,
    String? userType,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final currentUserData = await getUserData();

    final updatedUserData = {
      'cpc': userId ?? currentUserData['cpc'],
      'fullname': userName ?? currentUserData['fullname'],
      'email': userEmail ?? currentUserData['email'],
      'address': userAddress ?? currentUserData['address'],
      'city': userCity ?? currentUserData['city'],
      'cap': userPostalCode ?? currentUserData['cap'],
      'phone': userPhone ?? currentUserData['phone'],
      'type': userType ?? currentUserData['type'],
    };

    await prefs.setString('userData', json.encode(updatedUserData));
  }

  static Future<void> clearUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
    await prefs.remove('isLoggedIn');
    await prefs.remove('rememberMe');
  }
}
