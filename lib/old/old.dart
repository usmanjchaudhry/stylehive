import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
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
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  // Scroll function
  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 300,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 300,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    // Set product card dimensions based on screen size
    double cardHeight = screenHeight * 0.4; // Adjusted to 40% of screen height
    double cardWidth = screenWidth * 0.45; // Adjusted to 45% of screen width

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                // Add action for Shop button
              },
              child: const Text(
                'Shop',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const Text(
              'StyleHive',
              style: TextStyle(color: Colors.white),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    // Add action for Profile button
                  },
                  child: const Text(
                    'Profile',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    // Add action for Search button
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.shopping_cart, color: Colors.white),
                  onPressed: () {
                    // Add action for Cart button
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Big Display Image (nature.jpg)
          Container(
            height: 250.0, // Larger height for the display image
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/nature.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Section title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Shop Latest Apparel',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Product List with left and right buttons
          Expanded(
            child: Stack(
              children: [
                Row(
                  children: [
                    const SizedBox(width: 50), // Space for left button
                    Expanded(
                      child: SizedBox(
                        height: cardHeight,
                        child: ListView.builder(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          itemCount: 10, // Number of products
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: SizedBox(
                                width: cardWidth, // Adjusted width for larger product cards
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0), // Rounded corners
                                        child: Image.asset(
                                          'assets/images/product_${index % 4 + 1}.png',
                                          fit: BoxFit.contain, // Ensure entire image is visible
                                          width: double.infinity,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            'Product ${index + 1}',
                                            style: const TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          // Price label
                                          Text(
                                            '\$${(index + 1) * 20}',
                                            style: const TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 50), // Space for right button
                  ],
                ),
                // Floating left arrow button
                Positioned(
                  left: 0,
                  top: cardHeight / 2 - 25,
                  child: FloatingActionButton(
                    backgroundColor: Colors.black,
                    mini: true,
                    onPressed: _scrollLeft,
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                // Floating right arrow button
                Positioned(
                  right: 0,
                  top: cardHeight / 2 - 25,
                  child: FloatingActionButton(
                    backgroundColor: Colors.black,
                    mini: true,
                    onPressed: _scrollRight,
                    child: const Icon(Icons.arrow_forward, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40), // Padding before About Us
          // About Us Section
          Container(
            color: Colors.grey[900],
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'About Us',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'StyleHive is your go-to destination for the latest trends in fashion. We are dedicated to bringing you the most stylish, sustainable, and affordable apparel.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Contact Us',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                // Social Media Icons (Facebook, Twitter, Instagram)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.facebook, color: Colors.white),
                      onPressed: () {
                        // Add action for Facebook
                      },
                    ),
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.twitter, color: Colors.white),
                      onPressed: () {
                        // Add action for Twitter
                      },
                    ),
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.instagram, color: Colors.white),
                      onPressed: () {
                        // Add action for Instagram
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
