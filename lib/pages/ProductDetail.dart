import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart'; // Add this import
import '../providers/cart_provider.dart'; // Import your CartProvider
import '../models/CartModel.dart'; // Import your CartModel
import '../pages/Cart.dart'; 
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';// Import your CartPage

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;

  ProductDetailPage({required this.product});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  String selectedWeight = '250g'; // Default weight selection
  TextEditingController customWeightController = TextEditingController();
  bool isCustomWeightSelected = false;
  bool isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final cartProvider =
        Provider.of<CartProvider>(context); // Access CartProvider

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🖼 Product Image
            Padding(
              padding: EdgeInsets.all(10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  imageUrl: widget.product["image"],
                  height: MediaQuery.of(context).size.height * 0.45,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.45,
                      width: double.infinity,
                      color: Colors.white, // Background color for shimmer effect
                    ),
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error, size: 50), // Error widget
                ),
              ),
            ),

            SizedBox(height: 18),

            // 📌 Product Information
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.product["name"],
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF060505),
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  Text(
                    "€${widget.product["price"]}/Kg",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF060505),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 22),

            // 📌 Weight Selection
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Selezione peso",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF060505),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),

            // 📌 Weight Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...['250g', '500g', '1kg', '2kg'].map((weight) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedWeight = weight;
                              isCustomWeightSelected = false;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: selectedWeight == weight
                                  ? Color(0xFFE3051B)
                                  : Colors.white,
                              border: Border.all(
                                color: selectedWeight == weight
                                    ? Colors.transparent
                                    : Colors.black,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              weight,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: selectedWeight == weight
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),

                    // "Altro" Option
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isCustomWeightSelected = true;
                          selectedWeight = '';
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isCustomWeightSelected
                                ? Color(0xFFE3051B)
                                : Colors.white,
                            border: Border.all(
                              color: isCustomWeightSelected
                                  ? Colors.transparent
                                  : Colors.black,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Altro",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isCustomWeightSelected
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Custom Weight Input
            if (isCustomWeightSelected)
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 20, right: 20),
                child: TextField(
                  controller: customWeightController,
                  decoration: InputDecoration(
                    labelText: 'Inserisci peso personalizzato',
                    labelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                ),
              ),

            SizedBox(height: 22),

            // 📌 Ingredients Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Ingredienti:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF060505),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Ingrediente 1",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 22),

            // 📌 Description Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Descrizione:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF060505),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.product["desLong"] = widget.product["desLong"]?.replaceAll(RegExp(r'<\/?p>'), ''),
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                    maxLines: isDescriptionExpanded ? null : 3,
                    overflow: isDescriptionExpanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isDescriptionExpanded = !isDescriptionExpanded;
                      });
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Text(
                        isDescriptionExpanded ? "Mostra meno" : "Mostra di più",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(35),
            topRight: Radius.circular(35),
          ),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(34, 0, 0, 0),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
          border: Border.all(color: Color.fromARGB(255, 235, 235, 235)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🛒 Add to Cart Button with Badge
            GestureDetector(
              onTap: () {
                // Add product to cart
                final weight = isCustomWeightSelected
                    ? customWeightController.text
                    : selectedWeight;
                final cartItem = Cart(
                  id: widget.product["id"],
                  name: widget.product["name"],
                  image: widget.product["image"],
                  price: double.parse(widget.product["price"]),
                  iva : double.parse(widget.product["iva"]),
                  weight: weight,
                );
                cartProvider.addToCart(cartItem); // Add to cart
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.white,
                    elevation: 8, // Light shadow for a floating effect
                    content: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle,
                            color: Colors.green.shade600, size: 24),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Prodotto aggiunto al carrello",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color:
                                  Colors.green.shade700, // Nice shade of green
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    action: SnackBarAction(
                      label: "Annulla",
                      textColor: Colors.green.shade700,
                      onPressed: () {
                        cartProvider.removeFromCart(
                            int.parse(cartItem.id)); // Undo action
                      },
                    ),
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: cartProvider.cartItems.isNotEmpty ? 18 : 38,
                        vertical: 18),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.shopping_cart, color: Colors.black),
                        SizedBox(width: 10),
                        Text(
                          "Aggiungi nel carrello",
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  if (cartProvider.cartItems.isNotEmpty)
                    Positioned(
                      right: -5,
                      top: -5,
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          cartProvider.cartItems.length.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // 🛒 Show "Carrello" button if there are items in the cart
            if (cartProvider.cartItems.isNotEmpty)
              SizedBox(width: 8), // Add spacing between buttons
            if (cartProvider.cartItems.isNotEmpty)
              GestureDetector(
                onTap: () {
                  // Navigate to the Cart page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CartPage(),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 21, vertical: 18),
                  decoration: BoxDecoration(
                    color: Color(0xFF060505),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    "Carrello",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
