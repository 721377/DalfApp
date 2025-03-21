import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C304C), // Background color
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo at the Top
            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Image.asset(
                'assets/logo.png', // Replace with your logo path
                height: 80, // Adjust size as needed
              ),
            ),

            // Welcome Message
            Column(
              children: [
                Text(
                  "Benvenuti a Dalf Butcher",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Dove la qualità è la nostra esperienza",
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),

            // Center Image of Butcher
            Image.asset(
              'assets/butcher.png', // Replace with your butcher image
              width: 250, // Adjust size
              height: 250,
              fit: BoxFit.contain,
            ),

            // "Get Started" Button
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to next page
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded corners
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: const Text(
                  "Iniziamo", // Italian for "Get Started"
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF1C304C), // Text in dark blue
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
