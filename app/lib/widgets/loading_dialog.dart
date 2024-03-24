import 'package:flutter/material.dart';
import 'package:evflutterapp/utils/images.dart';
import 'package:lottie/lottie.dart';

class LoadingDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return const Center(
          child: SizedBox(
            width: 100, // Adjust width as needed
            height: 100, // Adjust height as needed
            child: CircularProgressIndicator(
              backgroundColor: Colors.green,
              color: Colors.orange,
            ),
          ),
        );
      },
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}
