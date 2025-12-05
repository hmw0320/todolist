import 'package:flutter/material.dart';

class CenterTab extends StatelessWidget {
  final IconData icon;

  const CenterTab({
    super.key,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.lightBlue,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.blue.shade400,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}
