import 'package:cached_network_image/cached_network_image.dart';
import 'package:dalfapp/pages/Mainscreen.dart';
import 'package:dalfapp/pages/Procedtopay.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/cart_provider.dart';
import '../models/CartModel.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {

  @override
  Widget build(BuildContext context) {
    final cartProvider =
        Provider.of<CartProvider>(context); // Access CartProvider
    final cartItems = cartProvider.cartItems; // Get cart items from provider

    double cartiva = cartProvider.ivaPrice; // Calculate subtotal
    double subtotal = cartProvider.totalPrice - cartiva;
    double tot = cartProvider.totalPrice;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar as a Container
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              color: Colors.white,
              child: Row(
                children: [
                  // Back Button
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black, size: 30),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => MainScreen()),
                        (route) => false, // Clears the navigation stack
                      );
                    },
                  ),
                  Spacer(), // Spacer to push the cart icon to the right
                  // Cart Icon with number of items
                  Stack(
                    children: [
                      IconButton(
                        icon: Icon(Icons.shopping_bag_outlined,
                            color: Colors.black, size: 30),
                        onPressed: () {
                          // Handle cart icon action
                        },
                      ),
                      if (cartItems.isNotEmpty)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              cartItems.length.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Body Content
            Expanded(
              child: Column(
                children: [
                  // Check if cartItems is not empty
                  cartItems.isNotEmpty
                      ? Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children:
                                  List.generate(cartItems.length, (index) {
                                final item = cartItems[index];

                                // Remove item when quantity is 0
                                if (item.quantity == 0) {
                                  cartProvider.removeFromCart(
                                      index); // Automatically remove item
                                }

                                return Dismissible(
                                  key: Key(item.id
                                      .toString()), // Use a unique key (e.g., item.id)
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: EdgeInsets.only(right: 20),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child:
                                        Icon(Icons.delete, color: Colors.white),
                                  ),
                                  onDismissed: (direction) {
                                    cartProvider.removeFromCart(
                                        index); // Remove item from cart
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 10),
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 5,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        // 🖼 Product Image
                                        Container(
                                          width: 90,
                                          height: 90,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            child: CachedNetworkImage(
                                              imageUrl: item.image,
                                              fit: BoxFit.fill,
                                              placeholder: (context, url) =>
                                                  Shimmer.fromColors(
                                                baseColor: Colors.grey[300]!,
                                                highlightColor:
                                                    Colors.grey[100]!,
                                                child: Container(
                                                  width: 90,
                                                  height: 90,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              errorWidget: (context, url,
                                                      error) =>
                                                  Icon(Icons.error, size: 40),
                                            ),
                                          ),
                                        ),

                                        SizedBox(width: 10),

                                        // 📌 Product Name and Price + Quantity
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.name,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF060505),
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                "€${item.price}/Kg",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF060505),
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              // 🔢 Quantity Control
                                              Row(
                                                children: [
                                                  IconButton(
                                                    icon: Icon(
                                                        Icons.remove_circle,
                                                        color: Colors.black,
                                                        size: 28),
                                                    onPressed: () {
                                                      cartProvider.decreaseQuantity(
                                                          index); // Decrease quantity
                                                    },
                                                  ),
                                                  Text(
                                                    item.quantity.toString(),
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  IconButton(
                                                    icon: Icon(Icons.add_circle,
                                                        color: Colors.black,
                                                        size: 28),
                                                    onPressed: () {
                                                      cartProvider.increaseQuantity(
                                                          index); // Increase quantity
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        // 📏 Weight on the far right of the row
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            // Display the weight
                                            Text(
                                              "Peso: ${item.weight}",
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black54,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            SizedBox(height: 8),
                                            Text(
                                              "€${item.weightPrezzo}",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                'images/Dalf_carne/emptyCart.jpg',
                                height: 430,
                                fit: BoxFit.fill,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Il tuo carrello è vuoto',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),

                  if (cartItems.isNotEmpty)
                    // 📌 Bottom Fixed Section
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // 🧾 Subtotal, Shipping, Total
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Subtotale",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black54),
                              ),
                              Text(
                                "€${subtotal.toStringAsFixed(2)}",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "IVA",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black54),
                              ),
                              Text(
                                "€${cartiva.toStringAsFixed(2)}",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Totale",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black54),
                              ),
                              Text(
                                "€${tot.toStringAsFixed(2)}",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),      
                          SizedBox(height: 10),
                          Divider(
                            color: Colors.black54,
                            thickness: 1,
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Totale",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "€${tot.toStringAsFixed(2)}",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),

                          // 🛒 Checkout Button
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CheckoutPage()),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(
                                color: Color(0xFF060505),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  "Procedi con l'ordine",
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
