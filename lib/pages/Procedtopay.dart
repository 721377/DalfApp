import 'package:cached_network_image/cached_network_image.dart';
import 'package:dalfapp/services/GeneraOrder.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../providers/cart_provider.dart';
import '../pages/Cart.dart';
import '../services/nexi_payment.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  int _currentStep = 0;
  bool _isDataModified = false;
  String _selectedPaymentMethod = 'credit_card';
  final _formKey = GlobalKey<FormState>();
  double _shippingPrice = 5.99;
  final ScrollController _scrollController = ScrollController();

  // Original user data for comparison
  Map<String, String> _originalUserData = {};

  // Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _capController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardNameController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _paypalEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();

    // Add listeners to controllers
    _fullNameController.addListener(_checkForChanges);
    _phoneController.addListener(_checkForChanges);
    _emailController.addListener(_checkForChanges);
    _addressController.addListener(_checkForChanges);
    _cityController.addListener(_checkForChanges);
    _capController.addListener(_checkForChanges);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _capController.dispose();
    _cardNumberController.dispose();
    _cardNameController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _paypalEmailController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('userData');

    if (userDataString != null) {
      final userData = json.decode(userDataString);
      setState(() {
        _fullNameController.text = userData['fullname'] ?? '';
        _phoneController.text = userData['phone'] ?? '';
        _emailController.text = userData['email'] ?? '';
        _addressController.text = userData['address'] ?? '';
        _cityController.text = userData['city'] ?? '';
        _capController.text = userData['cap'] ?? '';

        // Store original data for comparison
        _originalUserData = {
          'fullname': userData['fullname'] ?? '',
          'phone': userData['phone'] ?? '',
          'email': userData['email'] ?? '',
          'address': userData['address'] ?? '',
          'city': userData['city'] ?? '',
          'cap': userData['cap'] ?? '',
        };
        _isDataModified = false;
      });
    }
  }

  void _checkForChanges() {
    if (!mounted) return;

    final hasChanged = _fullNameController.text.trim() !=
            (_originalUserData['fullname'] ?? '').trim() ||
        _phoneController.text.trim() !=
            (_originalUserData['phone'] ?? '').trim() ||
        _emailController.text.trim() !=
            (_originalUserData['email'] ?? '').trim() ||
        _addressController.text.trim() !=
            (_originalUserData['address'] ?? '').trim() ||
        _cityController.text.trim() !=
            (_originalUserData['city'] ?? '').trim() ||
        _capController.text.trim() != (_originalUserData['cap'] ?? '').trim();

    if (_isDataModified != hasChanged) {
      setState(() => _isDataModified = hasChanged);
    }
  }

  Future<void> _updateUserData() async {
    if (_formKey.currentState?.validate() ?? false) {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('userData');

      if (userDataString != null) {
        final userData = json.decode(userDataString);

        // Update only changed fields
        final updatedData = {
          ...userData,
          'fullname': _fullNameController.text,
          'phone': _phoneController.text,
          'email': _emailController.text,
          'address': _addressController.text,
          'city': _cityController.text,
          'cap': _capController.text,
        };

        await prefs.setString('userData', json.encode(updatedData));

        // Update original data
        setState(() {
          _originalUserData = {
            'fullname': _fullNameController.text,
            'phone': _phoneController.text,
            'email': _emailController.text,
            'address': _addressController.text,
            'city': _cityController.text,
            'cap': _capController.text,
          };
          _isDataModified = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dati aggiornati con successo!')),
        );
      }
    }
  }

  void _processPayment() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Pagamento con $_selectedPaymentMethod completato!')),
      );
    }
  }

  Widget _buildUserDetailsStep() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildTextField(
                _fullNameController, 'Nome Completo', Icons.person, true),
            const SizedBox(height: 15),
            _buildTextField(
                _phoneController, 'Numero di Telefono', Icons.phone, true),
            const SizedBox(height: 15),
            _buildTextField(
                _emailController, 'Indirizzo Email', Icons.email, true),
            const SizedBox(height: 15),
            _buildTextField(
                _addressController, 'Indirizzo', Icons.location_on, true),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                    child: _buildTextField(
                        _cityController, 'Città', Icons.location_city, true)),
                const SizedBox(width: 10),
                Expanded(
                    child: _buildTextField(
                        _capController, 'CAP', Icons.map, true)),
              ],
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentStep() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        children: [
          Text(
            'Metodo di Pagamento',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800]),
          ),
          const SizedBox(height: 20),

          // Credit Card Option
          _buildPaymentOption(
            'Carta di Credito',
            'Visa, Mastercard, etc.',
            Icons.credit_card,
            'credit_card',
          ),
          const SizedBox(height: 15),

          // PayPal Option
          _buildPaymentOption(
            'PayPal',
            'Paga con il tuo account PayPal',
            Icons.payment,
            'paypal',
          ),
          const SizedBox(height: 25),

          // Payment Forms
          if (_selectedPaymentMethod == 'credit_card') _buildCreditCardForm(),
          if (_selectedPaymentMethod == 'paypal') _buildPaypalForm(),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
      String title, String subtitle, IconData icon, String value) {
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedPaymentMethod == value
                ? const Color(0xFF1C304E)
                : Colors.grey[300]!,
            width: _selectedPaymentMethod == value ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _selectedPaymentMethod == value
                    ? const Color(0xFF1C304E).withOpacity(0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon,
                  color: _selectedPaymentMethod == value
                      ? const Color(0xFF1C304E)
                      : Colors.grey[600]),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                ],
              ),
            ),
            Icon(
              _selectedPaymentMethod == value
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: _selectedPaymentMethod == value
                  ? const Color(0xFF1C304E)
                  : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditCardForm() {
    return Column(
      children: [
        _buildTextField(
            _cardNumberController, 'Numero Carta', Icons.credit_card, true,
            keyboardType: TextInputType.number,
            hintText: '1234 5678 9012 3456'),
        const SizedBox(height: 15),
        _buildTextField(
            _cardNameController, 'Nome sulla Carta', Icons.person_outline, true,
            hintText: 'MARIO ROSSI'),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                  _expiryDateController, 'Scadenza', Icons.calendar_today, true,
                  hintText: 'MM/AA', keyboardType: TextInputType.datetime),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildTextField(_cvvController, 'CVV', Icons.lock, true,
                  hintText: '123', keyboardType: TextInputType.number),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaypalForm() {
    return Column(
      children: [
        _buildTextField(
            _paypalEmailController, 'Email PayPal', Icons.email, true,
            keyboardType: TextInputType.emailAddress,
            hintText: 'mario.rossi@example.com'),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.info, color: Colors.blue),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Sarai reindirizzato a PayPal per completare il pagamento',
                  style: TextStyle(fontSize: 14, color: Colors.blueGrey),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.cartItems;
    final subtotal = cartProvider.totalPrice - cartProvider.ivaPrice;
    final total = cartProvider.totalPrice + _shippingPrice;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(26, 15, 15, 15).withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cart items preview
          SizedBox(
            height: 60,
            child: Row(
              children: [
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(item.image),
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 24),
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => CartPage())),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Price breakdown
          _buildPriceRow('Subtotale:', '€${subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 6),
          _buildPriceRow(
              'Spedizione:', '€${_shippingPrice.toStringAsFixed(2)}'),
          const SizedBox(height: 6),
          _buildPriceRow(
              'IVA:', '€${cartProvider.ivaPrice.toStringAsFixed(2)}'),
          const Divider(height: 16, thickness: 1),
          _buildPriceRow(
            'Totale:',
            '€${total.toStringAsFixed(2)}',
            isTotal: true,
          ),
          const SizedBox(height: 12),

          // Dynamic action button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () async {
                if (_currentStep == 0) {
                  if (_isDataModified) {
                    await _updateUserData(); // Ensure the update completes
                  }

                  if (_formKey.currentState?.validate() ?? false) {
                    setState(() => _currentStep = 1);

                    // Ensure async call for the payment process only after validation
                    // Handle payment result
                  }
                } else {
                  // Step 2: Process Payment
                  await OrderService.sendOrder(paymentMethod: 'test');
                  // Handle payment result
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1C304E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                _currentStep == 0
                    ? (_isDataModified
                        ? 'SALVA MODIFICHE'
                        : 'PROCEDI AL PAGAMENTO')
                    : 'PAGA ORA',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal
                ? const Color.fromARGB(255, 12, 12, 12)
                : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    bool enabled, {
    TextInputType keyboardType = TextInputType.text,
    String hintText = '',
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLength: hintText == 'MM/AA' ? 5 : null, // Limit for expiry field
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: TextStyle(fontSize: 15, color: Colors.grey[600]),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1C304E), width: 2),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[100],
        prefixIcon: Icon(icon, color: Colors.grey[600], size: 22),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        counterText: '',
      ),
      onChanged: (value) {
        if (hintText == 'MM/AA' && value.length == 2 && !value.contains('/')) {
          controller.text = '$value/';
          controller.selection = TextSelection.fromPosition(
            TextPosition(offset: controller.text.length),
          );
        }
      },
      validator: (value) =>
          value?.isEmpty ?? true ? 'Campo obbligatorio' : null,
    );
  }

  Widget _buildStepIndicator(String title, int stepNumber) {
    return GestureDetector(
      onTap: () {
        if (_formKey.currentState?.validate() ?? false) {
          setState(() => _currentStep = stepNumber);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: _currentStep == stepNumber
              ? const Color(0xFF1C304E)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: _currentStep == stepNumber ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header with step indicators
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  _buildStepIndicator('Dettagli', 0),
                  const SizedBox(width: 10),
                  _buildStepIndicator('Pagamento', 1),
                  const Spacer(),
                ],
              ),
            ),

            // Main content area
            Expanded(
              child: IndexedStack(
                index: _currentStep,
                children: [
                  _buildUserDetailsStep(),
                  _buildPaymentStep(),
                ],
              ),
            ),

            // Order summary
            Consumer<CartProvider>(
              builder: (context, cartProvider, child) {
                return _buildOrderSummary(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
