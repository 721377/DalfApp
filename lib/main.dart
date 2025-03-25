import 'package:dalfapp/pages/Login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

import 'pages/Mainscreen.dart';
import 'pages/WelcomePage.dart'; // Import your welcome page // Import your login page
import 'providers/cart_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter initializes before running
  runApp(
    ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget _defaultHome = Scaffold(body: Center(child: CircularProgressIndicator())); // Show loader initially

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  // Function to check if the user is new or logged in
  Future<void> _checkUserStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

    if (isFirstTime) {
      setState(() => _defaultHome = WelcomePage());
    } else if (!isLoggedIn) {
      setState(() => _defaultHome = LoginScreen());
    } else {
      setState(() => _defaultHome = MainScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      home: _defaultHome,
    );
  }
}
