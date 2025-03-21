import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:provider/provider.dart'; // Add this import
import '../providers/cart_provider.dart'; // Import your CartProvider
import '../pages/Cart.dart'; // Ensure this path matches your project structure

class HomeAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Positioned(
          left: 0, // Add padding from the left side
          right: 0, // Add padding from the right side
          top: 0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color.fromARGB(
                  255, 8, 8, 8), // Moved inside BoxDecoration
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(19, 0, 0, 0),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: Offset(0, 5),
                ),
              ],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(52),
                bottomRight: Radius.circular(52),
              ),
            ),
            child: Row(
              children: [
                // Sort Icon
                Icon(
                  Icons.sort,
                  size: 30,
                  color: Color.fromARGB(255, 247, 247, 248),
                ),

                Spacer(),

                // Logo
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Container(
                    height: 70,
                    width: 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: AssetImage('images/Dalf_carne/logo.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                Spacer(),

                // Cart Icon with Badge
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CartPage()),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 32,
                          color: Color.fromARGB(255, 247, 247, 248),
                        ),
                        Positioned(
                          top: -5,
                          right: -5,
                          child: badges.Badge(
                            badgeStyle: badges.BadgeStyle(
                              badgeColor: Colors.redAccent,
                              padding: EdgeInsets.all(6),
                            ),
                            badgeContent: Text(
                              cartProvider.cartItems.length
                                  .toString(), // Dynamic cart count
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
