import 'package:flutter/material.dart';

class ModernBottomBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ModernBottomBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  _ModernBottomBarState createState() => _ModernBottomBarState();
}

class _ModernBottomBarState extends State<ModernBottomBar> {
  @override
  Widget build(BuildContext context) {
    return  Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C304E), // White background
          borderRadius: BorderRadius.circular(30), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(101, 0, 0, 0).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30), // Rounded corners for the bar
          child: Stack(
            children: [
              BottomNavigationBar(
                currentIndex: widget.currentIndex,
                onTap: widget.onTap,
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent, // Transparent background
                selectedItemColor: Colors.transparent, // Hide selected icon color
                unselectedItemColor: const Color.fromARGB(255, 255, 255, 255), // Unselected icon color
                selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                unselectedLabelStyle: const TextStyle(fontSize: 12),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.search),
                    label: 'Search',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.discount_outlined),
                    label: 'Promotion',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.account_circle),
                    label: 'Profile',
                  ),
                ],
                iconSize: 30, // Icon size
                showSelectedLabels: true,
                showUnselectedLabels: true,
                elevation: 0, // Remove elevation
              ),
              // Animated circle background with icon
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: (MediaQuery.of(context).size.width - 32) / 4 * widget.currentIndex + 32, // Adjust position for padding
                bottom: 8,
                child: Container(
                  width: 50, // Circle size
                  height: 50, // Circle size
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(25), // Circle shape
                  ),
                  child: Center(
                    child: _getIconForIndex(widget.currentIndex), // Icon on top of the circle
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  
  }

  // Helper function to get the icon for the current index
  Widget _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return const Icon(Icons.home, color: Color(0xFF1C304E), size: 30);
      case 1:
        return const Icon(Icons.search, color: Color(0xFF1C304E), size: 30);
      case 2:
        return const Icon(Icons.discount_outlined, color: Color(0xFF1C304E), size: 30);
      case 3:
        return const Icon(Icons.account_circle, color: Color(0xFF1C304E), size: 30);
      default:
        return const Icon(Icons.home, color: Color(0xFF1C304E), size: 30);
    }
  }
}
