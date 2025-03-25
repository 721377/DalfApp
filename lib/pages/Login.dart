import 'dart:convert';
import 'package:dalfapp/pages/Register.dart';
import 'package:dalfapp/widgets/CustomSnackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:dalfapp/settings/settings.dart';
import 'package:dalfapp/pages/MainScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _rememberMe = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _loginUser() async {
    final response = await http.post(
      Uri.parse(Settings.login),
      headers: {
        "Content-Type": "application/json",
        "X-API-TOKEN": Settings.apiToken,
      },
      body: json.encode({
        'email': _emailController.text,
        'password': _passwordController.text
      }),
    );
    final responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', true);
      prefs.setBool('isFirstTime', false);

      if (responseData['user'] != null) {
        prefs.setString('userData', json.encode(responseData['user']));
      }
      if(responseData['status'] == 'success'){
      // showCustomSnackBar(
      //     context: context,
      //     message: json.decode(response.body)['message'],
      //     type: SnackBarType.success);
          
             Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
      }else{
        showCustomSnackBar(
          context: context,
          message: json.decode(response.body)['message'],
          type: SnackBarType.error);
      }
    
   
    } else {
      showCustomSnackBar(
          context: context,
          message: json.decode(response.body)['message'],
          type: SnackBarType.error);
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Center(
                child: Image.asset(
                  'images/Dalf_carne/logo.png',
                  height: 90,
                ),
              ),
              const SizedBox(height: 60),

              // Centered Login Form
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 400, // Maximum width for the form
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Indirizzo Email',
                        labelStyle: const TextStyle(
                          color: Color(0xFF1C304E),
                        ),
                        border: const OutlineInputBorder(),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF1C304E),
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(
                          color: Color(0xFF1C304E),
                        ),
                        border: const OutlineInputBorder(),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF1C304E),
                            width: 2.0,
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color(0xFF1C304E),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value!;
                                });
                              },
                              activeColor: const Color(0xFF1C304E),
                            ),
                            const Text(
                              'Ricordami',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Password dimenticata?',
                            style: TextStyle(
                              color: Color(0xFF1C304E),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _loginUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1C304E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Accedi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Non hai un account? ",
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.rightToLeft,
                                duration: Duration(milliseconds: 480),
                                child: RegisterScreen(),
                                curve: Curves.easeInOut,
                              ),
                            );
                          },
                          child: const Text(
                            'Registrati',
                            style: TextStyle(
                              color: Color(0xFF1C304E),
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
    );
  }
}
