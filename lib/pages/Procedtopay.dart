import 'package:cached_network_image/cached_network_image.dart';
import 'package:dalfapp/pages/Cart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/cart_provider.dart';
import '../models/CartModel.dart'; // Import the CartPage

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  int _currentStep = 0; // Track the current step
  bool _isDataModified = false; // Track if user data is modified

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _capController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize user data (you can fetch this from shared preferences or API)
    _fullNameController.text = 'John Doe';
    _phoneController.text = '1234567890';
    _emailController.text = 'john.doe@example.com';
    _addressController.text = '123 Main Street';
    _cityController.text = 'New York';
    _capController.text = '10001';

    // Add listeners to detect changes in input fields
    _fullNameController.addListener(_checkForChanges);
    _phoneController.addListener(_checkForChanges);
    _emailController.addListener(_checkForChanges);
    _addressController.addListener(_checkForChanges);
    _cityController.addListener(_checkForChanges);
    _capController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    setState(() {
      _isDataModified = true;
    });
  }

  void _updateUserData() {
    // Save updated user data (you can save to shared preferences or API)
    setState(() {
      _isDataModified = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dati aggiornati con successo!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context); // Access CartProvider
    final cartItems = cartProvider.cartItems; // Get cart items from provider

    double subtotal = cartProvider.totalPrice - cartProvider.ivaPrice; // Calculate subtotal
    double total = subtotal + 5.00; // Fixed shipping cost

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Section: Simple Container
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Spacer(),
                  _buildStepIndicator('User Details', 0),
                  const SizedBox(width: 10),
                  _buildStepIndicator('Payment', 1),
                  const Spacer(),
                ],
              ),
            ),
            const SizedBox(height: 20), // Added more space

            // User Details Section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20), // Added space at the top
                    _buildTextField(_fullNameController, 'Nome Completo', Icons.person),
                    const SizedBox(height: 15),
                    _buildTextField(_phoneController, 'Numero di Telefono', Icons.phone),
                    const SizedBox(height: 15),
                    _buildTextField(_emailController, 'Indirizzo Email', Icons.email),
                    const SizedBox(height: 15),
                    _buildTextField(_addressController, 'Indirizzo', Icons.location_on),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(_cityController, 'Città', Icons.location_city),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(_capController, 'CAP', Icons.map),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isDataModified ? _updateUserData : () {},
                        child: Text(
                          _isDataModified ? 'Aggiorna' : 'Paga',
                          style: const TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1C304E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Cart Items Section
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartPage()),
                );
              },
              child: Container(
                width: double.infinity, // Full width
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1), // Lighter shadow
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 70, // Reduced height
                      child: Row(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: cartItems.length,
                              itemBuilder: (context, index) {
                                final item = cartItems[index];
                                return Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  width: 70, // Reduced width
                                  height: 70, // Reduced height
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    image: DecorationImage(
                                      image: CachedNetworkImageProvider(item.image),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Subtotale:',
                                    style: TextStyle(fontSize: 13, color: Colors.grey),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '€${subtotal.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Text(
                                    'Totale:',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '€${total.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(String title, int stepNumber) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentStep = stepNumber;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: _currentStep == stepNumber ? const Color(0xFF1C304E) : const Color(0xFFececec),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: _currentStep == stepNumber ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF1C304E)),
        prefixIcon: Icon(icon, color: const Color(0xFF1C304E)),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFF1C304E),
            width: 2.0,
          ),
        ),
      ),
    );
  }
}