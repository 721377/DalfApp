import 'dart:async';
import 'dart:convert';
import 'package:dalfapp/widgets/CustomSnackbar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:dalfapp/settings/settings.dart';
import 'Login.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _AddressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _capController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

Future<void> _registerUser() async {
  if (!_formKey.currentState!.validate()) return;
  if (_passwordController.text != _confirmPasswordController.text) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Le password non corrispondono')),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    final response = await http.post(
      Uri.parse(Settings.register),
      headers: {
        "Content-Type": "application/json",
        "X-API-TOKEN": Settings.apiToken,
      },
      body: json.encode({
        'fullname': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'address': _AddressController.text.trim(),
        'cap': _capController.text.trim(),
        'phone': _phoneController.text.trim(),
        'city': _cityController.text.trim(),
      }),
    ).timeout(const Duration(seconds: 30));

    final responseData = json.decode(response.body);
    // ignore: avoid_print
    print(response.body);
    if (response.statusCode == 200 && responseData['status'] == true) {
      // Save to SharedPreferences only after successful server registration
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isRegistered', true);
      await prefs.setString('email', _emailController.text.trim());
      // Don't store password in plaintext!
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
      showCustomSnackBar(
        context: context,
        message: responseData['message'] ?? 'Registrazione completata',
        type: SnackBarType.success,
      );
    } 
    else if (response.statusCode == 409) {
      // User already exists
      showCustomSnackBar(
        context: context,
        message: 'Email già registrata',
        type: SnackBarType.error,
      );
    }
    else {
      // Other server errors
      showCustomSnackBar(
        context: context,
        message: responseData['message'] ?? 'Errore del server',
        type: SnackBarType.error,
      );
    }
  } on TimeoutException {
    showCustomSnackBar(
      context: context,
      message: 'Timeout. Riprova più tardi',
      type: SnackBarType.error,
    );
  } catch (e) {
    showCustomSnackBar(
      context: context,
      message: 'Errore di connessione',
      type: SnackBarType.error,
    );
    debugPrint('Error: $e');
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBackButton(),
                const SizedBox(height: 20),
                _buildTitle(),
                const SizedBox(height: 30),
                _buildFullNameField(),
                const SizedBox(height: 20),
                _buildAdressField(),
                const SizedBox(height: 20),
                _buildPhoneField(),
                const SizedBox(height: 20),
                _buildEmailField(),
                const SizedBox(height: 20),
                _buildCityAndCapFields(),
                const SizedBox(height: 20),
                _buildPasswordField(),
                const SizedBox(height: 20),
                _buildConfirmPasswordField(),
                const SizedBox(height: 30),
                _buildRegisterButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.black),
      onPressed: () => Navigator.pop(context),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Crea un account',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1C304E),
      ),
    );
  }

  Widget _buildFullNameField() {
    return TextFormField(
      controller: _fullNameController,
      decoration: _inputDecoration('Nome Completo', Icons.person),
      validator: (value) => value!.isEmpty ? 'Campo obbligatorio' : null,
    );
  }
 Widget  _buildAdressField(){
    return TextFormField(
      controller: _AddressController,
      decoration: _inputDecoration('Inderizzio', Icons.location_pin),
      validator: (value) => value!.isEmpty ? 'Campo obbligatorio' : null,
    );
 }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      decoration: _inputDecoration('Numero di Telefono', Icons.phone),
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value!.isEmpty) return 'Campo obbligatorio';
        if (!RegExp(r'^[0-9]{10,15}$').hasMatch(value)) {
          return 'Inserisci un numero valido';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: _inputDecoration('Indirizzo Email', Icons.email),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value!.isEmpty) return 'Campo obbligatorio';
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Inserisci un email valida';
        }
        return null;
      },
    );
  }

  Widget _buildCityAndCapFields() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _cityController,
            decoration: _inputDecoration('Città', Icons.location_city),
            validator: (value) => value!.isEmpty ? 'Campo obbligatorio' : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: _capController,
            decoration: _inputDecoration('CAP', Icons.map),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value!.isEmpty) return 'Campo obbligatorio';
              if (!RegExp(r'^[0-9]{5}$').hasMatch(value)) {
                return 'CAP non valido';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration:
          _passwordDecoration('Password', Icons.lock, _obscurePassword, () {
        setState(() => _obscurePassword = !_obscurePassword);
      }),
      validator: (value) {
        if (value!.isEmpty) return 'Campo obbligatorio';
        if (value.length < 6) return 'Minimo 6 caratteri';
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      decoration: _passwordDecoration(
          'Conferma Password', Icons.lock, _obscureConfirmPassword, () {
        setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
      }),
      validator: (value) => value!.isEmpty ? 'Campo obbligatorio' : null,
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _registerUser,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Registrati', style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF1C304C),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF1C304E)),
      prefixIcon: Icon(icon, color: const Color(0xFF1C304E)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Color(0xFF1C304C)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
            color: Color.fromARGB(255, 44, 74, 119), width: 2.0),
      ),
    );
  }

  InputDecoration _passwordDecoration(
      String label, IconData icon, bool obscureText, VoidCallback onPressed) {
    return _inputDecoration(label, icon).copyWith(
      suffixIcon: IconButton(
        icon: Icon(
          obscureText ? Icons.visibility_off : Icons.visibility,
          color: const Color(0xFF1C304E),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
