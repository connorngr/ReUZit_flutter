import 'package:flutter/material.dart';

class Helpers {
  /// Shows a snackbar with the given message in the provided context.
  static void showSnackBar(BuildContext context, String message, {Color backgroundColor = Colors.red, Duration duration = const Duration(seconds: 2)}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
      ),
    );
  }
}
