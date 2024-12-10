import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home_page.dart';
import 'register_page.dart';
import 'app_bar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Form Key for validation
  final _formKey = GlobalKey<FormState>();

  // Sign-in method
  Future<void> _signIn() async {
    if (_formKey.currentState?.validate() != true) {
      // If form is not valid, do not proceed
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Attempt to sign in
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Close the loading indicator
      Navigator.of(context).pop();

      // Navigate to HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      // Close the loading indicator
      Navigator.of(context).pop();

      String message;

      if (e.code == 'user-not-found') {
        message = 'No user found with this email.';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      } else {
        message = 'An unknown error occurred.';
      }

      // Show error message
      _showSnackBar(message);
    } catch (e) {
      // Close the loading indicator
      Navigator.of(context).pop();

      // Show general error message
      _showSnackBar('Failed to sign in: $e');
    }
  }

  // Display SnackBar for messages
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  // Dispose controllers when not needed
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Build the login UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            children: [
              // Header Text
              const Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Login to your account to continue',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),
              // Login Form
              Form(
                key: _formKey,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.fromSwatch().copyWith(
                      primary: Colors.deepOrangeAccent,
                    ),
                    inputDecorationTheme: const InputDecorationTheme(
                      labelStyle: TextStyle(color: Colors.deepOrangeAccent),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.deepOrangeAccent),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.deepOrangeAccent),
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Email input
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon:
                              Icon(Icons.email, color: Colors.deepOrangeAccent),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        cursorColor: Colors.deepOrangeAccent,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email.';
                          }
                          // Simple email regex
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                              .hasMatch(value.trim())) {
                            return 'Please enter a valid email.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // Password input
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon:
                              Icon(Icons.lock, color: Colors.deepOrangeAccent),
                        ),
                        obscureText: true,
                        cursorColor: Colors.deepOrangeAccent,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your password.';
                          }
                          if (value.trim().length < 6) {
                            return 'Password must be at least 6 characters.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      // Sign-in button
                      ElevatedButton(
                        onPressed: _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black, // Button color
                          foregroundColor: Colors.white, // Text color
                          minimumSize:
                              const Size(double.infinity, 50), // Button size
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Navigate to RegisterPage
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account?",
                            style: TextStyle(
                                fontSize: 16.0, color: Colors.black54),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const RegisterPage()),
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.black, // Text color
                            ),
                            child: const Text(
                              'Register',
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      // Back to HomePage button
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomePage()),
                          );
                        },
                        child: const Text(
                          'Back to Home',
                          style:
                              TextStyle(fontSize: 16.0, color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
