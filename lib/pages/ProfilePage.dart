import 'package:flutter/material.dart';
import 'package:dalfapp/widgets/HomeAppBar.dart';  // Make sure this import is correct

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add the HomeAppBar at the top
              HomeAppBar(),

              SizedBox(height: 32),

              // Profile Header
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Color(0xFF1C304C),
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'John Doe', // Replace with dynamic name
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'john.doe@example.com', // Replace with dynamic email
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32),

              // Horizontal Scrollable Buttons
              _buildSliderNavigation(context),

              SizedBox(height: 32),

              // Client Data Section
              _buildDataSection(context),
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // Client Data Section
  Widget _buildDataSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDataRow(Icons.person, 'Name', 'John Doe'), // Replace with dynamic name
          Divider(height: 20, color: Colors.grey[300]),
          _buildDataRow(Icons.email, 'Email', 'john.doe@example.com'), // Replace with dynamic email
          Divider(height: 20, color: Colors.grey[300]),
          _buildDataRow(Icons.lock, 'Password', 'test12%&'), // Replace with dynamic password
          Divider(height: 20, color: Colors.grey[300]),
          _buildDataRow(Icons.location_on, 'Address', '123 Main St, City, Country'), // Replace with dynamic address
        ],
      ),
    );
  }

  // Data Row Widget
  Widget _buildDataRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFF1C304C), size: 24),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Horizontal Scrollable Buttons
  Widget _buildSliderNavigation(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,  // Container background color changed to white
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildNavigationButton('Track Order', Icons.local_shipping, () {
              // Navigate to Track Order Page
            }),
            SizedBox(width: 8), // Add spacing between buttons
            _buildNavigationButton('Last Orders', Icons.history, () {
              // Navigate to Last Orders Page
            }),
            SizedBox(width: 8), // Add spacing between buttons
            _buildNavigationButton('Modify Profile', Icons.edit, () {
              // Navigate to Modify Profile Page
            }),
            SizedBox(width: 8), // Add spacing between buttons
            _buildNavigationButton('Settings', Icons.settings, () {
              // Navigate to Settings Page
            }),
          ],
        ),
      ),
    );
  }

  // Navigation Button Widget (with icon and text in the same row)
  Widget _buildNavigationButton(String label, IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Adjusted padding
        decoration: BoxDecoration(
          color: Color(0xFF1C304C),  // Button background color changed to black
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center icon and text
          children: [
            Icon(icon, color: Colors.white, size: 20),  // Icon
            SizedBox(width: 8), // Spacing between icon and text
            Text(
              label,
              style: TextStyle(
                fontSize: 14,  // Adjusted font size for text
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}