import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dalfapp/settings/settings.dart';

void main() async {
  // Test data to send to the register API
  final Map<String, dynamic> requestData = {
    'fullname': 'John Doe',
    'email': 'johndoe@example.com',
    'password': 'securepassword123',
    'address': '123 Main St',
    'cap': '12345',
    'phone': '555-5555',
    'city': 'Rome',
  };

  try {
    // Make the POST request with the API token in the headers and send test data
    final response = await http.post(
      Uri.parse(Settings.getProduct),
      headers: {
        "Content-Type": "application/json",
        "X-API-TOKEN": Settings.apiToken, // Include the API token in the headers
      },
      body: json.encode(requestData), // Encode the request data to JSON format
    );

    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Parsed Data: $data');
    } else {
      print('Failed to load data');
    }
  } catch (error) {
    print('Error: $error');
  }
}
