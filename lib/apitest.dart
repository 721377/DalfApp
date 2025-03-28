import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dalfapp/settings/settings.dart';

void main() async {
  // Test data for email testing API - matches your backend expectations
  final Map<String, dynamic> requestData = {
    'cpc': '633', // Customer code
    'cart_items': [
      {
        'name': 'Test Product 1',
        'codart': 'PROD001',
        'weight': 2,
        'price': 10.99
      },
      {
        'name': 'Test Product 2',
        'codart': 'PROD002',
        'weight': 1,
        'price': 24.50
      }
    ]
  };

  try {
    print('Sending test email to: ${Settings.testemail}'); // Make sure you have this in your Settings
    print('Request data: ${json.encode(requestData)}');

    // Make the POST request
    final response = await http.post(
      Uri.parse(Settings.testemail), // Update this to your testemail endpoint
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
        print('\n✅ Email sent successfully!');
        print('Message: ${data['message']}');
      } else {
        print('\n❌ Email sending failed: ${data['message']}');
      }
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