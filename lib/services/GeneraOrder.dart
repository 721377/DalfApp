import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/cart_provider.dart';
import '../settings/settings.dart';

class OrderService {
  final CartProvider cartProvider;

  OrderService(this.cartProvider);

  Future<Map<String, dynamic>> sendOrder({
    String? notes,
    String? shippingAddressId = 'main',
    required String paymentMethod, // Make payment method required
  }) async {
    try {
      // Get user data from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('userData');
      
      if (userDataString == null) {
        throw Exception('User not logged in');
      }

      final userData = json.decode(userDataString);
      final cpc = userData['cpc'];
      
      if (cpc == null) {
        throw Exception('Client code (cpc) not found in user data');
      }

      // Prepare cart items for API - matching PHP backend expectations
      final cartItems = cartProvider.cartItems.map((item) {
        return {
          'id': item.id,
          'codart': item.codart,
          'name': item.name,
          'image': item.image,
          'price': item.price,
          'iva': item.iva,
          'weight': item.weight,
          'weightPrezzo': item.weightPrezzo,
          'quantity': item.quantity,
        };
      }).toList();

      // Prepare the request body - matching PHP backend parameters
      final requestBody = {
        'cart_items': cartItems,
        'cpc': cpc,
        'payment_method': paymentMethod, // Now using the required parameter
        'shipping_address_id': shippingAddressId,
        'notes': notes ?? '',
      };

      // Make the API call
      final response = await http.post(
        Uri.parse(Settings.sendOrder),
        headers: {
          "Content-Type": "application/json",
          "X-API-TOKEN": Settings.apiToken,
        },
        body: json.encode(requestBody),
      );

      // Handle response based on your PHP backend structure
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // Assuming your PHP returns JSON with 'status' and 'data' fields
        if (responseData['status'] == 'ok') {
          await cartProvider.clearCart();
          return {
            'success': true,
            'order_number': responseData['nmov'] ?? '',
            'total': responseData['tot'] ?? 0,
            'message': 'Order placed successfully',
          };
        } else {
          return {
            'success': false,
            'error': responseData['msg'] ?? 'Failed to place order',
          };
        }
      } else {
        final errorResponse = json.decode(response.body);
        return {
          'success': false,
          'error': errorResponse['message'] ?? 'HTTP Error ${response.statusCode}',
        };
      }
    } catch (error) {
      return {
        'success': false,
        'error': error.toString(),
      };
    }
  }
}