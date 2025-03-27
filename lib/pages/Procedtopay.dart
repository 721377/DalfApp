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
  Map<String, String> _originalUserData = {};
  bool _isProcessingPayment = false;

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
  late OrderService _orderService;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
     _orderService = OrderService(cartProvider);

    // Add listeners to controllers
    _fullNameController.addListener(_checkForChanges);
    _phoneController.addListener(_checkForChanges);
    _emailController.addListener(_checkForChanges);
    _addressController.addListener(_checkForChanges);
    _cityController.addListener(_checkForChanges);
    _capController.addListener(_checkForChanges);
  }

  // @override
  // void dispose() {
  //   _scrollController.dispose();
  //   _fullNameController.dispose();
  //   _phoneController.dispose();
  //   _emailController.dispose();
  //   _addressController.dispose();
  //   _cityController.dispose();
  //   _capController.dispose();
  //   _cardNumberController.dispose();
  //   _cardNameController.dispose();
  //   _expiryDateController.dispose();
  //   _cvvController.dispose();
  //   _paypalEmailController.dispose();
  //   super.dispose();
  // }

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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Metodo di Pagamento',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800]),
        ),
        const SizedBox(height: 20),

        // Horizontal payment options
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildPaymentOption(
                'Carta di credito',
                'images/Dalf_carne/creditcard.png',
                'credit_card',
              ),
              _buildPaymentOption(
                'PayPal',
                'images/Dalf_carne/paypal.png',
                'paypal',
              ),
              // Add more payment options here if needed
            ],
          ),
        ),
        const SizedBox(height: 25),

        // Payment Forms
        if (_selectedPaymentMethod == 'credit_card') _buildCreditCardForm(),
        if (_selectedPaymentMethod == 'paypal') _buildPaypalForm(),
      ],
    ),
  );
}

Widget _buildPaymentOption(String title, String iconAsset, String value) {
  final bool isCreditCard = value == 'credit_card';
  
  return GestureDetector(
    onTap: () => setState(() => _selectedPaymentMethod = value),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(right: 12, bottom: 8),
      constraints: const BoxConstraints(minWidth: 120),
      decoration: BoxDecoration(
        color: _selectedPaymentMethod == value
            ? const Color(0xFFE4EBFC)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:_selectedPaymentMethod == value
            ? const Color.fromARGB(255, 41, 105, 255):const Color.fromARGB(255, 233, 233, 233),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Payment method icon and title
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 38,
                margin: const EdgeInsets.only(bottom: 8),
                child: Image.asset(
                  iconAsset,
                  fit: BoxFit.contain,
                  // color: _selectedPaymentMethod == value
                  //     ? Colors.white
                  //     : null,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _selectedPaymentMethod == value
                      ? Color.fromARGB(255, 145, 145, 145)
                      : Colors.grey[800],
                ),
              ),
            ],
          ),
          
        ],
      ),
    ),
  );
}

Widget _buildCreditCardForm() {
  return Column(
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
              _cardNumberController, 'Numero Carta', Icons.credit_card, true,
              keyboardType: TextInputType.number,
              hintText: '1234 5678 9012 3456'),
          const SizedBox(height: 8),
          // Card brand logos
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Image.asset(
                'images/Dalf_carne/visa.jpg',
                width: 50,
                height: 35,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
              Image.asset(
                'images/Dalf_carne/masterc.jpg',
                width: 50,
                height: 35,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ],
      ),
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
          child: Row(
            children: [
              Image.asset(
              'images/Dalf_carne/paypal.png',
              width: 30,
              fit: BoxFit.contain),

              const SizedBox(width: 10),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(26, 36, 36, 36).withOpacity(0.1),
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
            height: 55,
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
                  icon: const Icon(Icons.keyboard_arrow_up, size: 24),
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
            height: 58,
            child: ElevatedButton(
              onPressed: _isProcessingPayment
                  ? null
                  : () async {
                      if (_currentStep == 0) {
                        if (_isDataModified) {
                          await _updateUserData();
                        }
                        if (_formKey.currentState?.validate() ?? false) {
                          setState(() => _currentStep = 1);
                        }
                      } else {
                        setState(() => _isProcessingPayment = true);
                        
                        try {
                          final result = await _orderService.sendOrder(
                            paymentMethod: _selectedPaymentMethod,
                            notes: 'Ordine dall\'app mobile',
                          );

                          setState(() => _isProcessingPayment = false);

                          if (result['success'] == true) {
                            _showSuccessDialog(context, result['order_number'].toString());
                            cartProvider.clearCart();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Errore: ${result['error'] ?? 'Si è verificato un errore'}')),
                            );
                          }
                        } catch (e) {
                          setState(() => _isProcessingPayment = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Errore durante il pagamento: ${e.toString()}')),
                              
                          );
                          print( '\n❌ \nErrore durante il pagamento: ${e.toString()}');
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: _isProcessingPayment
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
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

  void _showSuccessDialog(BuildContext context, String orderNumber) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Ordine Confermato!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  'Il tuo ordine #$orderNumber è stato effettuato con successo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Riceverai una conferma via email a breve.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1C304E),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'CONTINUA GLI ACQUISTI',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
          borderSide: BorderSide(color: const Color.fromARGB(255, 216, 216, 216)!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1C304E), width: 2),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[100],
        prefixIcon: Icon(icon, color: const Color.fromARGB(255, 34, 34, 34), size: 22),
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
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
