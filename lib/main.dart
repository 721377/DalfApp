import 'package:dalfapp/pages/Mainscreen.dart';  // Import the product detail page
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';  // Import the provider package
import 'providers/cart_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
 // Import your CartProvider

void main() => runApp(
  ChangeNotifierProvider(
    create: (context) => CartProvider(),  // Provide CartProvider
    child: MyApp(),
  ),
);

class MyApp extends StatelessWidget {
  @override 
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      home: MainScreen(), 
        //
    );
  }
}
