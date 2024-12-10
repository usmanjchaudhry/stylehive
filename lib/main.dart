import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'pages/home_page.dart';
import 'pages/success_page.dart';
import 'pages/cancel_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set your Stripe publishable key:
  Stripe.publishableKey =
      'your-publishable-key-here'; // Replace with your actual key

  runApp(const StyleHiveApp());
}

class StyleHiveApp extends StatelessWidget {
  const StyleHiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StyleHive',
      theme: ThemeData(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/success': (context) => const SuccessPage(),
        '/cancel': (context) => const CancelPage(),
      },
    );
  }
}
