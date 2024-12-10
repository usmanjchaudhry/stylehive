import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Row for icon and name
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // The profile picture LOGO
                    const Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon( // Creating a Circle for the profile logo
                          Icons.circle,
                          size: 100,
                          color: Colors.teal, // Outer circle color
                        ),
                        Icon(
                          Icons.person_sharp,
                          size: 80,
                          color: Colors.white, // Inner person icon color
                        ),
                      ],
                    ),
                    const SizedBox(width: 10), // Spacing between logo and name
                    // Name and Title
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'John Paul Chua',
                          style: TextStyle(
                            fontFamily: 'Pacifico',
                            fontSize: 30.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Experienced App Developer',
                          style: TextStyle(
                            fontFamily: 'Source Sans Pro',
                            color: Colors.grey[700],
                            fontSize: 15.0,
                            letterSpacing: 2.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30.0,
                  width: 200.0,
                  child: Divider(
                    height: 100.0,
                    color: Colors.black,
                  ),
                ),
                // Row for phone and email
                 const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Address info
                    Icon(
                      Icons.location_on,
                      color: Colors.teal,
                    ),
                    SizedBox(width: 10), // Space between icon and text
                    Flexible(
                      child: Text(
                        "123 Main Street",
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Source Sans Pro',
                          fontSize: 20.0,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 35), // Reduced space between address and phone
                    // Phone info
                    Icon(
                      Icons.phone,
                      color: Colors.teal,
                    ),
                    SizedBox(width: 10), // Space between icon and text
                    Flexible(
                      child: Text(
                        '(415) 555-0198',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Source Sans Pro',
                          fontSize: 20.0,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
