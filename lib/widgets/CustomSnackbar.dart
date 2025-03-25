import 'package:flutter/material.dart';

enum SnackBarType { success, error, warning }

void showCustomSnackBar({
  required BuildContext context,
  required String message,
  required SnackBarType type,
  String? actionLabel,
  VoidCallback? onActionPressed,
}) {
  // Define icon and color based on the type
  IconData icon;
  Color iconColor;
  Color textColor;

  switch (type) {
    case SnackBarType.success:
      icon = Icons.check_circle;
      iconColor =  Colors.green.shade600;
      textColor = Colors.green.shade700;
      break;
    case SnackBarType.error:
      icon = Icons.error;
      iconColor = Colors.red.shade600;
      textColor = Colors.red.shade700;
      break;
    case SnackBarType.warning:
      icon = Icons.warning;
      iconColor = Colors.orange.shade600;
      textColor = Colors.orange.shade700;
      break;
  }

  final snackBar = SnackBar(
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    backgroundColor: Colors.white, // White background
     // Floating effect with shadow
    content: Row(
      children: [
        Icon(icon, color: iconColor, size: 24), // Status Icon
        SizedBox(width: 12), // Space between icon and text
        Expanded(
          child: Text(
            message,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textColor, // Text color based on type
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
    action: actionLabel != null
        ? SnackBarAction(
            label: actionLabel,
            textColor: textColor, // Action button color based on type
            onPressed: onActionPressed ?? () {},
          )
        : null,
    duration: Duration(seconds: 3),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
