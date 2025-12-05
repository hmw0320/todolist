import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Message {
  // Snack Bar
  snackBar(String itemTitle, String message){
    Get.snackbar(
      itemTitle,
      message,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 2),
      colorText: Colors.white,
      backgroundColor: Colors.red
    );
  } // snackBar

  // Dialog
  showDialog(String title, String message) {
    Get.defaultDialog(
      title: title,
      middleText: message,
      backgroundColor: const Color.fromARGB(255, 193, 197, 201),
      barrierDismissible: false,
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
            Get.back();
          },
          style: TextButton.styleFrom(
              foregroundColor: Colors.black,
          ),
          child: const Text('OK'),
        ),
      ],
    );
  }

}