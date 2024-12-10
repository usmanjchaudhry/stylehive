import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_details_page.dart';
import 'app_bar.dart';
import 'product_model.dart';
import 'shop_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math' as math;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    _loadProductData();
  }

  Future<void> _loadProductData() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('products').get();
      List<Product> productList =
          querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();

      setState(() {
        products = productList;
      });
    } catch (e) {
      print('Error loading products: $e');
    }
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 500, // Increased scroll amount
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 500, // Increased scroll amount
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildProductCard(Product product, double cardWidth) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsPage(product: product),
          ),
        );
      },
      child: _AnimatedHoverContainer(
        width: cardWidth,
        height: 220, // Reduced height so no overflow on hover
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8.0)),
                child: Image.network(
                  product.image,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: 120,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error, size: 40);
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 5),
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.deepOrangeAccent,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      height: 250.0,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://i.ibb.co/QJHkQW0/orange.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.error);
            },
          ),
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'StyleHive',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 50.0,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '“A streetwear brand”',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                        fontSize: 25.0,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedProductsSection(double cardHeight, double cardWidth) {
    // Limit the carousel to 4 items total
    int displayCount = math.min(products.length, 4);

    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                'Shop Latest Apparel',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrangeAccent,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: cardHeight,
            child: Stack(
              children: [
                Row(
                  children: [
                    const SizedBox(width: 50),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: displayCount,
                        itemBuilder: (context, index) {
                          var product = products[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: _buildProductCard(product, cardWidth),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 50),
                  ],
                ),
                // Left arrow button with some horizontal padding from the screen edge
                Positioned(
                  left: 16,
                  top: cardHeight / 2 - 25,
                  child: FloatingActionButton(
                    backgroundColor: Colors.black,
                    mini: true,
                    onPressed: _scrollLeft,
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                // Right arrow button with some horizontal padding from the screen edge
                Positioned(
                  right: 16,
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
        ],
      ),
    );
  }

  Widget _buildBrandStorySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Text(
            'Our Story',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrangeAccent,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Founded with a vision to revolutionize fashion, StyleHive brings you carefully curated apparel that blends style, sustainability, and affordability. Our team of designers and trend-setters scour the globe to bring you the latest collections, ensuring that you always look and feel your best.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 16.0,
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          Image.network(
            'https://i.ibb.co/BwtswSr/street-Wear.jpg',
            fit: BoxFit.fitWidth,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.error, size: 40);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'What Our Customers Say',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrangeAccent,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          _buildTestimonialCard(
            '“I love the variety and quality of clothes at StyleHive. I always find something new and exciting!”',
            '– Sarah K.',
          ),
          const SizedBox(height: 30),
          _buildTestimonialCard(
            '“The customer service is top-notch, and their sustainable approach makes me feel good about my purchases.”',
            '– James P.',
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard(String quote, String author) {
    return Card(
      elevation: 3,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              quote,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 16.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              author,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      color: Colors.grey[900],
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Contact Us',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.facebook,
                    color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon:
                    const FaIcon(FontAwesomeIcons.twitter, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.instagram,
                    color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            '© ${DateTime.now().year} StyleHive. All rights reserved.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double cardHeight = math.min(screenHeight * 0.4, 400);
    // cardWidth so that exactly 2 items visible + spacing and margins
    double cardWidth = (screenWidth - 116) / 2;

    return Scaffold(
      appBar: buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeroSection(),
            _buildFeaturedProductsSection(cardHeight, cardWidth),
            _buildBrandStorySection(),
            _buildTestimonialsSection(),
            const SizedBox(height: 40),
            _buildFooter(),
          ],
        ),
      ),
    );
  }
}

class _AnimatedHoverContainer extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const _AnimatedHoverContainer({
    Key? key,
    required this.child,
    this.onTap,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<_AnimatedHoverContainer> createState() =>
      _AnimatedHoverContainerState();
}

class _AnimatedHoverContainerState extends State<_AnimatedHoverContainer> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        _hovering ? Colors.deepOrangeAccent : Colors.transparent;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 2.0),
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.white,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
