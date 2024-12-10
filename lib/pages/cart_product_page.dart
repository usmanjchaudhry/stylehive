// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'cart_page.dart';
import 'shop_page.dart';
import 'app_bar.dart';

class CartProductPage extends StatefulWidget {
  final String productName;
  final String productDescription;
  final String productImage;
  final double productPrice;
  final int productId;
  final int productQuantity;

  const CartProductPage({
    Key? key,
    required this.productName,
    required this.productDescription,
    required this.productImage,
    required this.productPrice,
    required this.productId,
    required this.productQuantity,
  }) : super(key: key);

  @override
  _CartProductPageState createState() => _CartProductPageState();
}

bool isAndroid() {
  if (kIsWeb) {
    return false;
  } else {
    return Platform.isAndroid;
  }
}

// Dialog when actions are performed
void _showAddToCartDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          message,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        content: const Text(
          'Would you like to shop more?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => CartPage(appBarBuilder: buildAppBar),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
            ),
            child: const Text('Go to Cart'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ShopPage(appBarBuilder: buildAppBar),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
            ),
            child: const Text('Shop More'),
          ),
        ],
      );
    },
  );
}

Future<List<dynamic>> fetchCartItems() async {
  const url = 'http://localhost:5000/api/cart'; // Endpoint URL

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load cart items: ${response.statusCode}');
    }
  } catch (error) {
    throw Exception('Error fetching cart items: $error');
  }
}

void loadCartItems() async {
  try {
    List<dynamic> cartItems = await fetchCartItems();
    print(cartItems);
  } catch (error) {
    print('Error: $error');
  }
}

class _CartProductPageState extends State<CartProductPage> {
  int quantity = 1;
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final priceText = '\$${widget.productPrice.toStringAsFixed(2)}';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cart Product Details',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Carousel Section
            SizedBox(
              height: 250,
              child: Stack(
                children: [
                  PageView.builder(
                    itemCount:
                        3, // Just displaying the same image multiple times
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Image.network(
                        widget.productImage,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.error,
                              size: 40, color: Colors.red);
                        },
                      );
                    },
                  ),
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        return Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == index
                                ? Colors.black
                                : Colors.black.withOpacity(0.3),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Product Info and Description Section
            Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.productName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      priceText,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.productDescription,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Quantity Selector Section
            Text(
              'Quantity',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _QuantityButton(
                  icon: Icons.remove,
                  onPressed: () {
                    if (quantity > 1) {
                      setState(() {
                        quantity--;
                      });
                    }
                  },
                ),
                const SizedBox(width: 15),
                Text(
                  quantity.toString(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(width: 15),
                _QuantityButton(
                  icon: Icons.add,
                  onPressed: () {
                    setState(() {
                      quantity++;
                    });
                  },
                ),
              ],
            ),

            // Spacer if needed
            const SizedBox(height: 60),

            // Since this item is presumably already in the cart,
            // we are not displaying an "Add to Cart" button.
            // If needed, you could add a "Update Quantity" or "Remove from Cart" button.
          ],
        ),
      ),
    );
  }
}

class _QuantityButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _QuantityButton({Key? key, required this.icon, required this.onPressed})
      : super(key: key);

  @override
  State<_QuantityButton> createState() => _QuantityButtonState();
}

class _QuantityButtonState extends State<_QuantityButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final scale = _hovering ? 1.1 : 1.0;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          child: CircleAvatar(
            backgroundColor: Colors.black,
            radius: 16,
            child: Icon(
              widget.icon,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
