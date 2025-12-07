import 'package:flutter/material.dart';

class CenterTab extends StatelessWidget {

  const CenterTab({super.key});

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
        Icons.add,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}
