import 'package:flutter/material.dart';

class seenLogo extends StatelessWidget {
  const seenLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Image.asset("assets/seen_Logo__standard-removebg-preview.png"),
      ),
    );
  }
}
