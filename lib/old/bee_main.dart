import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StyleHive',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const LandingPage(),
    const SearchPage(),
    const UserProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[600],
        onTap: _onItemTapped,
      ),
    );
  }
}

// Landing Page (Home)
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StyleHive'),
        centerTitle: true,
        backgroundColor: Colors.amber[600],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Fashion Header
            const Text(
              'Discover the Latest Fashion Trends',
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20.0),
            // Octagonal Fashion Showcase
            Expanded(
              child: GridView.builder(
                itemCount: 8, // Number of products
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // how many items in a row
                  crossAxisSpacing: 20.0,
                  mainAxisSpacing: 20.0,
                ),
                itemBuilder: (context, index) {
                  return OctagonShape(
                    image: AssetImage('assets/images/product_${index + 1}.png'), // Placeholder image path
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailPage(
                            imagePath: 'assets/images/product_${index + 1}.png',
                            productName: 'Product ${index + 1}',
                            productPrice: '\$${(index + 1) * 20}',
                            productDescription: 'Description of Product ${index + 1}',
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 50.0),
            // More Products Button
            ElevatedButton(
              onPressed: () {
                // Navigate to product categories or more product listings
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                textStyle: const TextStyle(fontSize: 18.0),
              ),
              child: const Text('More Products...'),
            ),
          ],
        ),
      ),
    );
  }
}

// Search Page
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Apparel'),
        backgroundColor: Colors.amber[600],
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Search Page'),
      ),
    );
  }
}

// User Profile Page
class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.amber[600],
        centerTitle: true,
      ),
      body: const Center(
        child: Text('User Profile Page'),
      ),
    );
  }
}

// Octagon Shape Container
class OctagonShape extends StatelessWidget {
  final ImageProvider image;
  final VoidCallback onTap;

  const OctagonShape({super.key, required this.image, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Get the screen size for adaptive resizing
    double screenWidth = MediaQuery.of(context).size.width;
    double octagonSize = screenWidth * 0.5; // Adjust size as necessary

    return GestureDetector(
      onTap: onTap,
      child: ClipPath(
        clipper: OctagonClipper(),
        child: Container(
          width: octagonSize,
          height: octagonSize,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.amber[600]!, width: 3.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image(
              image: image,
              fit: BoxFit.cover,
            ),
          )
        ),
      ),
    );
  }
}

// Octagon Clipper
class OctagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;
    Path path = Path();

    path.moveTo(w * 0.3, 0); // Top left
    path.lineTo(w * 0.7, 0); // Top right
    path.lineTo(w, h * 0.3); // Right upper corner
    path.lineTo(w, h * 0.7); // Right bottom corner
    path.lineTo(w * 0.7, h); // Bottom right
    path.lineTo(w * 0.3, h); // Bottom left
    path.lineTo(0, h * 0.7); // Left bottom corner
    path.lineTo(0, h * 0.3); // Left upper corner
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

// Product Detail Page
class ProductDetailPage extends StatelessWidget {
  final String imagePath;
  final String productName;
  final String productPrice;
  final String productDescription;

  const ProductDetailPage({super.key, 
    required this.imagePath,
    required this.productName,
    required this.productPrice,
    required this.productDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(productName),
        backgroundColor: Colors.amber[600],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(imagePath, height: 300, fit: BoxFit.cover),
            const SizedBox(height: 20),
            Text(
              productName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              productPrice,
              style: const TextStyle(fontSize: 20, color: Colors.green),
            ),
            const SizedBox(height: 20),
            Text(
              productDescription,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
