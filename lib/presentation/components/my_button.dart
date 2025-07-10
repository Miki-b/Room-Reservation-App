import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String buttonText;
  final void Function()? onTap;

  const MyButton({super.key, required this.buttonText, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap, // Directly use the callback
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.secondary, // Button color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Rounded corners
        ),
        minimumSize: const Size(double.infinity, 55), // Full width button
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: Text(
        buttonText, // Use dynamic text
        style: const TextStyle(
          color: Colors.white, // Text color
        ),
      ),
    );
  }
}
