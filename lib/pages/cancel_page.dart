import 'package:flutter/material.dart';
// Import your custom app bar
import 'app_bar.dart';

class CancelPage extends StatelessWidget {
  const CancelPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use the custom app bar from app_bar.dart
      appBar: buildAppBar(context),
      body: const Center(
        child: Text(
          'Your payment was cancelled.',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
