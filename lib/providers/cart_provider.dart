import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/CartModel.dart';

class CartProvider with ChangeNotifier {
  List<Cart> _cartItems = [];
  List<Cart> get cartItems => _cartItems;
  final String apiUrl = "";

  CartProvider() {
    _loadCart(); // Load cart when the provider is initialized
  }

  // Add item to cart or update quantity if it exists
  void addToCart(Cart cart) async {
    int index = _cartItems.indexWhere((item) => item.id == cart.id);

    if (index != -1) {
      _cartItems[index].quantity += cart.quantity;
    } else {
      _cartItems.add(cart);
    }

    await _saveCart(); // Save updated cart
    notifyListeners();
  }

  // Remove item from cart
  void removeFromCart(int index) async {
    _cartItems.removeAt(index);
    await _saveCart();
    notifyListeners();
  }

  // Increase quantity of item in cart
  void increaseQuantity(int index) async {
    _cartItems[index].quantity++;
    await _saveCart();
    notifyListeners();
  }

  // Decrease quantity of item in cart
  void decreaseQuantity(int index) async {
    if (_cartItems[index].quantity > 1) {
      _cartItems[index].quantity--;
      await _saveCart();
      notifyListeners();
    } else if (_cartItems[index].quantity == 1) {
      removeFromCart(index);
    }
  }

  // Get total price of cart
  double get totalPrice {
    return _cartItems.fold(0, (sum, item) => sum + (item.weightPrezzo * item.quantity));
  }

  double get ivaPrice {
    return _cartItems.fold(0, (sum, item) => sum + (item.iva));
  }

  // Update cart items based on codart with new product data
  void updateCartItems(List<Map<String, dynamic>> products) {
    bool hasChanges = false;
    
    for (int i = 0; i < _cartItems.length; i++) {
      final cartItem = _cartItems[i];
      final product = products.firstWhere(
        (p) => p['codart'] == cartItem.codart,
        orElse: () => {},
      );

      if (product.isNotEmpty) {
        // Check if any properties need updating
        if (cartItem.name != product['name'] ||
            cartItem.price != double.parse(product['price']) ||
            cartItem.iva != double.parse(product['iva']) ||
            cartItem.image != product['image']) {
          
          _cartItems[i] = Cart(
            id: cartItem.id,
            codart: cartItem.codart,
            name: product['name'],
            image: product['image'],
            price: double.parse(product['price']),
            iva: double.parse(product['iva']),
            weight: cartItem.weight,
            weightPrezzo: cartItem.weightPrezzo,
            quantity: cartItem.quantity,
          );
          hasChanges = true;
        }
      }
    }

    if (hasChanges) {
      _saveCart();
      notifyListeners();
    }
  }

  // Save cart to local storage with timestamp
  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    String cartData = jsonEncode(_cartItems.map((item) => item.toJson()).toList());
    prefs.setString('cartItems', cartData);
    prefs.setString('cartTimestamp', DateTime.now().toIso8601String());
  }

  // Load cart from local storage
  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    String? cartData = prefs.getString('cartItems');
    String? timestamp = prefs.getString('cartTimestamp');

    if (cartData != null && timestamp != null) {
      DateTime savedTime = DateTime.parse(timestamp);
      DateTime now = DateTime.now();
      Duration difference = now.difference(savedTime);

      if (difference.inDays >= 3) {
        // If 3 days have passed, clear the cart
        await clearCart();
      } else {
        // Otherwise, load the saved cart
        List<dynamic> decodedData = jsonDecode(cartData);
        _cartItems = decodedData.map((item) => Cart.fromJson(item)).toList();
      }
    }

    notifyListeners();
  }

  // Clear cart manually or automatically after 3 days
  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    _cartItems.clear();
    prefs.remove('cartItems');
    prefs.remove('cartTimestamp');
    notifyListeners();
  }
}