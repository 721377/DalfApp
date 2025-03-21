import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dalfapp/settings/settings.dart'; 

void main() async {
  // Initialize secure storage

  try {
    // Make the POST request with the API token in the headers
    final response = await http.post(
      Uri.parse(Settings.evidenza),
      headers: {
        "Content-Type": "application/json",
        "X-API-TOKEN": Settings.apiToken, // Include the API token in the headers
      },
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