import 'package:dalfapp/widgets/CustomSnackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/CartModel.dart';
import '../pages/Cart.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;

  ProductDetailPage({required this.product});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  String selectedWeight = '500g';
  TextEditingController customWeightController = TextEditingController();
  bool isCustomWeightSelected = false;
  bool isDescriptionExpanded = false;

  double getPricePerKg() {
    try {
      return double.parse(widget.product["price"]?.toString() ?? '0');
    } catch (e) {
      return 0.0;
    }
  }

  double calculatePrice(String weight) {
    final pricePerKg = getPricePerKg();
    var price = 0.00;
    if (weight.isEmpty) return 0.0;

    // Extract numerical value
    final numericalValue =
        double.tryParse(weight.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;

    if (weight.contains('kg')) {
     price =numericalValue * pricePerKg;
    } else if (weight.contains('g')) {
      price = (numericalValue / 1000) * pricePerKg;
    }
    // If no unit specified, assume kg
    return  price;
  }

  String getFormattedWeight(String weight) {
    if (weight.isEmpty) return '';
    if (weight.contains('g') || weight.contains('kg')) return weight;
    return '${weight}kg'; // Default to kg if no unit specified
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final pricePerKg = getPricePerKg();
    final currentWeight =
        isCustomWeightSelected ? customWeightController.text : selectedWeight;
    final totalPrice = calculatePrice(currentWeight);

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
            // Product Image
            Padding(
              padding: EdgeInsets.all(10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  imageUrl: widget.product["image"] ?? '',
                  height: MediaQuery.of(context).size.height * 0.45,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.45,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                  ),
                  errorWidget: (context, url, error) =>
                      Icon(Icons.error, size: 50),
                ),
              ),
            ),

            SizedBox(height: 18),

            // Product Information
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.product["name"] ?? 'No name',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  Text(
                    "€${pricePerKg.toStringAsFixed(2)}/kg",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 22),

            // Weight Selection
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Selezione peso",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),

            // Weight Options
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
                              color: selectedWeight == weight &&
                                      !isCustomWeightSelected
                                  ? Color(0xFFE3051B)
                                  : Colors.white,
                              border: Border.all(
                                color: selectedWeight == weight &&
                                        !isCustomWeightSelected
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
                                color: selectedWeight == weight &&
                                        !isCustomWeightSelected
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
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isCustomWeightSelected
                                ? Colors.black
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
                    labelText: 'Inserisci peso (es. 750g o 1.5kg)',
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
                  onChanged: (value) {
                    setState(() {
                      selectedWeight = value;
                    });
                  },
                ),
              ),

            SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Prezzo totale:",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "€${totalPrice.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 22),

            // Ingredients Section
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
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      widget.product["ingredients"] ??
                          "Nessun ingrediente specificato",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 22),

            // Description Section
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
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    (widget.product["desLong"]?.toString() ??
                            'Nessuna descrizione disponibile')
                        .replaceAll(RegExp(r'<\/?p>'), ''),
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
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Text(
                        isDescriptionExpanded ? "Mostra meno" : "Mostra di più",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
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
      bottomNavigationBar: SafeArea(
        child: Container(
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
            border: Border(
              top: BorderSide(color: Colors.grey[200]!),
              left: BorderSide(color: Colors.grey[200]!),
              right: BorderSide(color: Colors.grey[200]!),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Add to Cart Button with Badge
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    final weight = isCustomWeightSelected
                        ? customWeightController.text
                        : selectedWeight;

                    if (isCustomWeightSelected &&
                        (weight.isEmpty ||
                            double.tryParse(weight.replaceAll(
                                    RegExp(r'[^0-9.]'), '')) ==
                                null)) {
                      showCustomSnackBar(
                        context: context,
                        message: "Inserisci un peso valido",
                        type: SnackBarType.error,
                      );
                      return;
                    }

                    final cartItem = Cart(
                      id: widget.product["id"]?.toString() ?? '',
                      codart: widget.product['codart'].toString() ,
                      name: widget.product["name"]?.toString() ?? 'No name',
                      image: widget.product["image"]?.toString() ?? '',
                      price:double.parse(widget.product["price"]) ,
                      weightPrezzo:calculatePrice(weight) ,
                      iva: double.tryParse(
                              widget.product["iva"]?.toString() ?? '0') ??
                          0,
                      weight: getFormattedWeight(weight),
                    );

                    cartProvider.addToCart(cartItem);
                    showCustomSnackBar(
                      context: context,
                      message: "Prodotto aggiunto al carrello",
                      type: SnackBarType.success,
                    );
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.black,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart, color: Colors.white),
                            SizedBox(width: 10),
                            Text(
                              "Aggiungi nel carrello",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
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
              ),

              // Cart Button (only shown when there are items)
              if (cartProvider.cartItems.isNotEmpty) SizedBox(width: 12),
              if (cartProvider.cartItems.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CartPage()),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      "Carrello",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
