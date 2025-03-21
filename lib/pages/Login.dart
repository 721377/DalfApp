import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginRegisterScreen(),
    );
  }
}

class LoginRegisterScreen extends StatefulWidget {
  @override
  _LoginRegisterScreenState createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  bool isRegistering = false;

  void toggleRegister() {
    setState(() {
      isRegistering = !isRegistering;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image with Overlay
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/Dalf_carne/butcherimgWr.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: const Color.fromARGB(206, 0, 0, 0), // Reduced opacity to 0.5
            ),
          ),

          // Logo Fixed at the Top
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Image.asset(
                  'images/Dalf_carne/logo.png',
                  width: 150,
                  height: 150,
                ),
              ),
            ),
          ),

          // Login Form
          if (!isRegistering)
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 200), // Space for the logo
                    _buildLoginForm(),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: toggleRegister,
                      child: Text(
                        "Don't have an account? Register",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Register Box (Slides Up)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            bottom: isRegistering ? 0 : -MediaQuery.of(context).size.height,
            left: 0,
            right: 0,
            child: _buildRegisterForm(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.all(20),
      decoration: _boxDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Login", style: _titleStyle()),
          const SizedBox(height: 20),
          _buildTextField(Icons.email, "Email"),
          const SizedBox(height: 15),
          _buildTextField(Icons.lock, "Password", isPassword: true),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: _buttonStyle(primary: Colors.black),
            child: const Text("Login"),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Register", style: _titleStyle(color: Colors.black)),
            const SizedBox(height: 20),
            _buildTextField(Icons.person, "Full Name"),
            const SizedBox(height: 15),
            _buildTextField(Icons.email, "Email"),
            const SizedBox(height: 15),
            _buildTextField(Icons.phone, "Phone Number"),
            const SizedBox(height: 15),
            _buildTextField(Icons.location_on, "Address"),
            const SizedBox(height: 15),
            _buildTextField(Icons.lock, "Password", isPassword: true),
            const SizedBox(height: 15),
            _buildTextField(Icons.lock, "Confirm Password", isPassword: true),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: _buttonStyle(primary: Colors.black),
              child: const Text("Register"),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: toggleRegister,
              child: Text(
                "Already have an account? Login",
                style: GoogleFonts.poppins(color: Colors.black, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(IconData icon, String hint, {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF1C304C)),
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: const Color(0xFF1C304C).withOpacity(0.7)),
        filled: true,
        fillColor: Colors.grey[100],
        border: _inputBorder(),
        enabledBorder: _inputBorder(borderColor: Colors.grey[300]!),
        focusedBorder: _inputBorder(borderColor: const Color(0xFF1C304C)),
      ),
    );
  }

  OutlineInputBorder _inputBorder({Color borderColor = Colors.grey}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: borderColor, width: 1),
    );
  }

  ButtonStyle _buttonStyle({Color primary = Colors.white}) {
    return ElevatedButton.styleFrom(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      shadowColor: Colors.black26,
      elevation: 5,
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          spreadRadius: 2,
        ),
      ],
    );
  }

  TextStyle _titleStyle({Color color = Colors.white}) {
    return GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }
}