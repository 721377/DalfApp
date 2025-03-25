import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dalfapp/pages/Procedtopay.dart';
import 'package:dalfapp/pages/Register.dart';
import 'package:flutter/material.dart';
import '../widgets/Bottomnavbar.dart'; // Import your custom bottom bar
import 'HomePage.dart'; // Import your pages
import 'ProductAll.dart';
import 'PromotionPage.dart';
import 'ProfilePage.dart';
import 'Login.dart';
import 'Register.dart';
import 'Welcomepage.dart';
import 'package:flutter/services.dart'; // Ensure you have this imported

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  int _selectedCategoryIndex = 0;
  String? _selectedCategory;
  bool _isConnected = true;

  // List of pages to display based on the selected tab
  List<Widget> get _pages {
    return [
      HomePage(
        onCategorySelected: (category) {
          _onCategorySelected(0, category); // Pass the selected category
        },
      ),
      ProductsPage(
        category:
            _selectedCategory, // Pass the selected category to ProductsPage
      ),
      PromotionPage(),
      // LoginScreen(),
      // RegisterScreen(),
      // LoginPage(),
      ProfilePage(),
      // WelcomePage(),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onCategorySelected(int index, String? category) {
    setState(() {
      _selectedCategoryIndex = index;
      _selectedCategory = category;
      _currentIndex =
          1; // Switch to the ProductsPage when a category is selected
    });
  }

  Future<void> checkInternetConnection(BuildContext context) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _isConnected = false;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("No Internet Connection"),
          content: Text("Please check your internet settings and try again."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        _isConnected = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Check for internet connection when the MainScreen is loaded
    checkInternetConnection(context);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Color(0xFF1C304E),
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor:
            Color.fromARGB(255, 255, 255, 255), // Set navigation bar color
        systemNavigationBarIconBrightness: Brightness.dark, // Set icon color
      ),
    );
    
  }

  // Pull-to-refresh function
  Future<void> _handleRefresh() async {
    await Future.delayed(Duration(seconds: 2)); // Simulate a network call
    checkInternetConnection(context);
  }

  @override
  Widget build(BuildContext context) {
    
    return 
     AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Color(0xFF1C304E), // Force status bar color
        statusBarIconBrightness: Brightness.light, // Light icons
      ),
      child: Scaffold(
        // backgroundColor: const Color.fromARGB(0, 255, 255, 255),
        // Use IndexedStack to maintain the state of each page
        body: IndexedStack(
          index: _currentIndex,
          children: _pages, // Use the _pages list here
        ),

        // Custom bottom navigation bar
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(bottom: 12.0, left: 8.0, right: 8.0),
          child: ModernBottomBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
          ),
        ),
      ),
    );
  }
}
