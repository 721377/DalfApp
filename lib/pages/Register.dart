import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Login.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _capController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text == _confirmPasswordController.text) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isRegistered', true);
        await prefs.setString('fullName', _fullNameController.text);
        await prefs.setString('phone', _phoneController.text);
        await prefs.setString('email', _emailController.text);
        await prefs.setString('city', _cityController.text);
        await prefs.setString('cap', _capController.text);
        await prefs.setString('password', _passwordController.text);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Le password non corrispondono.')),
        );
      }
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
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Spacer(),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 20),
                _buildTextField(
                    _fullNameController, 'Nome Completo', Icons.person),
                const SizedBox(height: 20),
                _buildTextField(
                    _phoneController, 'Numero di Telefono', Icons.phone),
                const SizedBox(height: 20),
                _buildTextField(
                    _emailController, 'Indirizzo Email', Icons.email),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                          _cityController, 'Città', Icons.location_city),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTextField(_capController, 'CAP', Icons.map),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildPasswordField(_passwordController, 'Password', Icons.lock,
                    _obscurePassword, () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                }),
                const SizedBox(height: 20),
                _buildPasswordField(
                    _confirmPasswordController,
                    'Conferma Password',
                    Icons.lock,
                    _obscureConfirmPassword, () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                }),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _registerUser,
                    child: const Text('Registrati',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFF1C304E), // Label color
        ),
        prefixIcon: Icon(icon, color: Color(0xFF1C304E)),
        filled: true,
        fillColor: const Color.fromARGB(255, 255, 255, 255),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.black)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Color(0xFF1C304E), width: 2.0)),
      ),
      validator: (value) => value!.isEmpty ? 'Campo obbligatorio' : null,
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label,
      IconData icon, bool obscureText, VoidCallback onToggleVisibility) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFF1C304E), // Label color
        ),
        prefixIcon: Icon(icon, color: Color(0xFF1C304E)),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility,
              color: Color(0xFF1C304E)),
          onPressed: onToggleVisibility,
        ),
        filled: true,
        fillColor: const Color.fromARGB(255, 255, 255, 255),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.black)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Color(0xFF1C304E), width: 2.0)),
      ),
      validator: (value) => value!.isEmpty ? 'Campo obbligatorio' : null,
    );
  }
}
