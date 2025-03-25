import 'package:dalfapp/pages/Login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;
  late Map<String, dynamic> userData;
  bool isLoading = true;

  // Controllers for editable fields
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController addressController;
  late TextEditingController cityController;
  late TextEditingController postalCodeController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('userData');

    setState(() {
      userData = userDataString != null ? json.decode(userDataString) : {};
      _initializeControllers();
      isLoading = false;
    });
  }

  void _initializeControllers() {
    nameController =
        TextEditingController(text: userData['fullname']?.toString() ?? '');
    emailController =
        TextEditingController(text: userData['email']?.toString() ?? '');
    addressController =
        TextEditingController(text: userData['address']?.toString() ?? '');
    cityController =
        TextEditingController(text: userData['city']?.toString() ?? '');
    postalCodeController =
        TextEditingController(text: userData['cap']?.toString() ?? '');
    phoneController =
        TextEditingController(text: userData['phone']?.toString() ?? '');
  }

  Future<void> _updateUserData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Prepare the data to update (only changed fields)
      final Map<String, dynamic> updatedFields = {};
      final Map<String, dynamic> currentData = userData;

      if (nameController.text != currentData['fullname']) {
        updatedFields['fullname'] = nameController.text;
      }
      if (emailController.text != currentData['email']) {
        updatedFields['email'] = emailController.text;
      }
      if (addressController.text != currentData['address']) {
        updatedFields['address'] = addressController.text;
      }
      if (cityController.text != currentData['city']) {
        updatedFields['city'] = cityController.text;
      }
      if (postalCodeController.text != currentData['cap']) {
        updatedFields['cap'] = postalCodeController.text;
      }
      if (phoneController.text != currentData['phone']) {
        updatedFields['phone'] = phoneController.text;
      }

      // Only call API if there are changes
      if (updatedFields.isNotEmpty) {
        // Call your API to update user data
        final response = await http.put(
          Uri.parse('https://your-api-endpoint.com/users/update'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'userId': userData['cpc'],
            'updates': updatedFields,
          }),
        );

        if (response.statusCode == 200) {
          // Update local storage with new data
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          final updatedUserData = {...userData, ...updatedFields};
          await prefs.setString('userData', json.encode(updatedUserData));

          setState(() {
            userData = updatedUserData;
            isEditing = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profilo aggiornato con successo')),
          );
        } else {
          throw Exception('Failed to update profile');
        }
      } else {
        setState(() {
          isEditing = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Errore durante l\'aggiornamento del profilo: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    addressController.dispose();
    cityController.dispose();
    postalCodeController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1C304C)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40),
                  // Profile Header
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Color(0xFF1C304C),
                              width: 3,
                            ),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                'https://ui-avatars.com/api/?name=${userData['fullname']?.toString() ?? 'User'}&background=1C304C&color=fff',
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          userData['fullname']?.toString() ?? 'Nessun nome',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          userData['email']?.toString() ?? 'Nessuna email',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
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

          // Edit/Cancel Button (only appears when editing)
          if (isEditing)
            Positioned(
              top: 45,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isEditing = false;
                    _initializeControllers(); // Reset controllers
                  });
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(22, 0, 0, 0),
                        blurRadius: 4,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.close,
                      color: const Color.fromARGB(255, 20, 20, 20),
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Client Data Section
  Widget _buildDataRow(IconData icon, String label, Widget valueWidget) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xFF1C304C).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Color(0xFF1C304C),
              size: 20,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6),
                valueWidget is Text
                    ? Text(
                        valueWidget.data ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      )
                    : valueWidget,
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build Data Section
  Widget _buildDataSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(22, 0, 0, 0),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informazioni Personali',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C304C),
            ),
          ),
          SizedBox(height: 16),
          _buildDataRow(
            Icons.person,
            'Nome',
            isEditing
                ? TextField(
                    controller: nameController,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                  )
                : Text(userData['fullname']?.toString() ?? 'Nessun nome'),
          ),
          Divider(height: 1, color: Colors.grey[200]),
          _buildDataRow(
            Icons.email,
            'Email',
            isEditing
                ? TextField(
                    controller: emailController,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                  )
                : Text(userData['email']?.toString() ?? 'Nessuna email'),
          ),
          Divider(height: 1, color: Colors.grey[200]),
          _buildDataRow(
            Icons.location_on,
            'Indirizzo',
            isEditing
                ? TextField(
                    controller: addressController,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                  )
                : Text(userData['address']?.toString() ?? 'Nessun indirizzo'),
          ),
          Divider(height: 1, color: Colors.grey[200]),
          _buildDataRow(
            Icons.location_city,
            'Città',
            isEditing
                ? TextField(
                    controller: cityController,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                  )
                : Text(userData['city']?.toString() ?? 'Nessuna città'),
          ),
          Divider(height: 1, color: Colors.grey[200]),
          _buildDataRow(
            Icons.markunread_mailbox,
            'CAP',
            isEditing
                ? TextField(
                    controller: postalCodeController,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                  )
                : Text(userData['cap']?.toString() ?? 'Nessun CAP'),
          ),
          Divider(height: 1, color: Colors.grey[200]),
          _buildDataRow(
            Icons.phone,
            'Telefono',
            isEditing
                ? TextField(
                    controller: phoneController,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                  )
                : Text(userData['phone']?.toString() ?? 'Nessun telefono'),
          ),
          if (isEditing) ...[
            SizedBox(height: 25),
            Center(
              child: ElevatedButton(
                onPressed: _updateUserData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1C304C),
                  padding: EdgeInsets.symmetric(horizontal: 62, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 1,
                ),
                child: Text(
                  'Salva Modifiche',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Horizontal Scrollable Buttons
  Widget _buildSliderNavigation(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(22, 0, 0, 0),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildNavigationButton('Ordini Recenti', Icons.history, () {}),
            SizedBox(width: 8),
            _buildNavigationButton('Modifica Profilo', Icons.edit, () {
              setState(() {
                isEditing = true;
              });
            }),
            SizedBox(width: 8),
            _buildNavigationButton('Impostazioni', Icons.settings, () {}),
            SizedBox(width: 8),
            _buildNavigationButton('Logout', Icons.logout, () {
              clearUserData(context);
            }),
          ],
        ),
      ),
    );
  }

  // Navigation Button Widget
  Widget _buildNavigationButton(
      String label, IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Color(0xFF1C304C).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Color(0xFF1C304C), size: 20),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF1C304C),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> clearUserData(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Remove data from SharedPreferences
    await prefs.remove('userData');
    await prefs.remove('isLoggedIn');
    await prefs.remove('rememberMe');
    // Navigate to LoginScreen after clearing user data
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }
}
