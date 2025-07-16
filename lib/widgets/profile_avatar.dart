import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String firstName;
  final double radius;
  final double fontSize;
  final VoidCallback? onEditPressed;
  final bool showEditButton;

  const ProfileAvatar({
    super.key,
    required this.firstName,
    this.radius = 50,
    this.fontSize = 36,
    this.onEditPressed,
    this.showEditButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).primaryColor,
      child: Text(
        firstName.isNotEmpty ? firstName[0].toUpperCase() : '?',
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    if (!showEditButton) {
      return avatar;
    }

    return Stack(
      children: [
        avatar,
        if (onEditPressed != null)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                ),
                onPressed: onEditPressed,
              ),
            ),
          ),
      ],
    );
  }
}