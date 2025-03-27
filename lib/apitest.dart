import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dalfapp/settings/settings.dart';

void main() async {
  // Test data for registration API - matches your backend expectations
  final Map<String, dynamic> requestData = {
    'fullname': 'Mario Rossi',
    'email': 'm.labideone@gmail.com',
    'password': 'Test1234!',
    'address': 'Via Roma 123',
    'cap': '00100',
    'phone': '3331234567',
    'city': 'Roma'
  };

  try {
    print('Sending test registration to: ${Settings.register}');
    print('Request data: ${json.encode(requestData)}');

    // Make the POST request
    final response = await http.post(
      Uri.parse(Settings.register),
      headers: {
        "Content-Type": "application/json",
        "X-API-TOKEN": Settings.apiToken,
      },
      body: json.encode(requestData),
    );

    print('\nResponse Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      if (data['status'] == true) {
        print('\n✅ Registration successful!');
        print('Message: ${data['message']}');
        if (data.containsKey('email_sent')) {
          print('Email sent: ${data['email_sent'] ? 'Yes' : 'No'}');
        }
      } else {
        print('\n❌ Registration failed: ${data['message']}');
      }
    } else if (response.statusCode == 409) {
      print('\n❌ Registration failed: User already exists');
      final errorData = json.decode(response.body);
      print('Details: ${errorData['message']}');
    } else {
      print('\n❌ HTTP Error: ${response.statusCode}');
      try {
        final errorData = json.decode(response.body);
        print('Error details: ${errorData['message'] ?? errorData['error']}');
      } catch (e) {
        print('Could not parse error response');
      }
    }
  } catch (error) {
    print('\n❌ Exception occurred: $error');
  }
}
