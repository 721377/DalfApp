import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dalfapp/settings/settings.dart';

void main() async {
  // Test data for order API - matches your backend expectations
  final Map<String, dynamic> requestData = {
    'cart_items': [
      {
        'id': 1,
        'codart': '1004',
        'name': 'FILETTO BOVINO ADULTO',
        'price': 25.90,
        'iva':2.59,
        'weight': 0.5,
        'weightPrezzo': 0,
        'quantity': 1,
      }
    ],
    'cpc': '632', // Test client code
    'payment_method': 'cash', // Test payment method
    'shipping_address_id': 'main', // Default shipping address
    'notes': 'Test order from API tester',
    'request_invoice': {
      'requested': true,
      'type': 'cliente', // or 'azienda'
    },
  };

  try {
    print('Sending test order to: ${Settings.sendOrder}');
    print('Request data: ${json.encode(requestData)}');

    // Make the POST request
    final response = await http.post(
      Uri.parse(Settings.sendOrder),
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
      
      if (data['status']) {
        print('\n✅ Order created successfully!');
        print('Order Number: ${data['data']['order_number']}');
        print('Total Amount: ${data['data']['total_net']}');
        if (data['data'] != null) {
          print('Products number : ${data['data']['items_count']}');
        }
      } else {
        print('\n❌ Order failed: ${data['msg']}');
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