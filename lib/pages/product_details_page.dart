import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'product_model.dart';
import 'cart_page.dart';
import 'app_bar.dart';
import 'shop_page.dart';

class ProductDetailsPage extends StatefulWidget {
  final Product product;

  const ProductDetailsPage({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int quantity = 1;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;

  // Review fields
  int _selectedRating = 5;
  final TextEditingController _reviewController = TextEditingController();
  List<Map<String, dynamic>> reviews = [];
  bool isLoadingReviews = true;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.product.id.toString())
          .collection('reviews')
          .orderBy('timestamp', descending: true)
          .get();

      final reviewList = querySnapshot.docs.map((d) {
        return {
          'userId': d.data()['userId'],
          'rating': d.data()['rating'],
          'comment': d.data()['comment'],
          'timestamp': d.data()['timestamp'],
          'userEmail': d.data()['userEmail'] ?? '',
        };
      }).toList();

      setState(() {
        reviews = reviewList;
        isLoadingReviews = false;
      });
    } catch (e) {
      print('Error loading reviews: $e');
      setState(() {
        isLoadingReviews = false;
      });
    }
  }

  Future<void> _addToCart(BuildContext context) async {
    if (user == null) {
      // User not logged in
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      return;
    }

    try {
      final cartCollection = FirebaseFirestore.instance.collection('cart');

      // Check if product already in cart
      final querySnapshot = await cartCollection
          .where('userId', isEqualTo: user!.uid)
          .where('productId', isEqualTo: widget.product.id)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docRef = querySnapshot.docs.first.reference;
        final currentData = querySnapshot.docs.first.data();
        final currentQuantity = currentData['quantity'] ?? 1;
        final newQuantity = currentQuantity + quantity;

        await docRef.update({'quantity': newQuantity});
        _showAddToCartDialog(context, 'Quantity updated in cart');
      } else {
        // Add new cart item
        await cartCollection.add({
          'userId': user!.uid,
          'productId': widget.product.id,
          'name': widget.product.name,
          'price': widget.product.price,
          'image': widget.product.image,
          'quantity': quantity,
          'description': widget.product.description,
          'category': widget.product.category,
        });

        _showAddToCartDialog(context, 'Item added to cart');
      }
    } catch (e) {
      print('Error adding to cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add item to cart')),
      );
    }
  }

  void _showAddToCartDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            message,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          content: const Text(
            'Would you like to shop more or go to your cart?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CartPage(appBarBuilder: buildAppBar),
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.black),
              child: const Text('Go to Cart'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShopPage(appBarBuilder: buildAppBar),
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.black),
              child: const Text('Shop More'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitReview() async {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You must be logged in to leave a review')),
      );
      return;
    }

    final comment = _reviewController.text.trim();
    if (_selectedRating < 1 || _selectedRating > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a rating between 1 and 5')),
      );
      return;
    }
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a comment')),
      );
      return;
    }

    try {
      final productRef = FirebaseFirestore.instance
          .collection('products')
          .doc(widget.product.id.toString());

      final reviewRef = productRef.collection('reviews').doc();

      await reviewRef.set({
        'userId': user!.uid,
        'rating': _selectedRating,
        'comment': comment,
        'timestamp': FieldValue.serverTimestamp(),
        'userEmail': user!.email ?? '',
      });

      _reviewController.clear();
      setState(() {
        _selectedRating = 5;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review added')),
      );

      // Reload reviews
      _loadReviews();
    } catch (e) {
      print('Error adding review: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add review')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final priceText = '\$${product.price.toStringAsFixed(2)}';

    return Scaffold(
      appBar: buildAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 24.0, bottom: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Image
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    product.image,
                    height: 300,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error,
                          size: 50, color: Colors.red);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Product Info Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          product.name,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          priceText,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.deepOrangeAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          product.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Quantity Selector
              Text(
                'Quantity',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _QuantityButton(
                    icon: Icons.remove,
                    onPressed: () {
                      if (quantity > 1) {
                        setState(() => quantity--);
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
                      setState(() => quantity++);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Add to Cart Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: () => _addToCart(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                  ),
                  child: Text(
                    'Add to Cart',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Display Reviews
              Text(
                'Reviews',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 10),
              if (isLoadingReviews)
                const Center(child: CircularProgressIndicator())
              else if (reviews.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('No reviews yet.'),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: reviews.map((r) {
                    final rating = r['rating'] ?? 0;
                    final comment = r['comment'] ?? '';
                    final email = r['userEmail'] ?? '';
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            email,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(5, (index) {
                              final starIndex = index + 1;
                              return Icon(
                                starIndex <= rating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: starIndex <= rating
                                    ? Colors.deepOrangeAccent
                                    : Colors.grey,
                                size: 16,
                              );
                            }),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            comment,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 20),

              if (user != null) ...[
                Text(
                  'Leave a Review',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starIndex = index + 1;
                    return IconButton(
                      icon: Icon(
                        starIndex <= _selectedRating
                            ? Icons.star
                            : Icons.star_border,
                        color: starIndex <= _selectedRating
                            ? Colors.deepOrangeAccent
                            : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedRating = starIndex;
                        });
                      },
                    );
                  }),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.fromSwatch().copyWith(
                        primary: Colors.deepOrangeAccent,
                      ),
                    ),
                    child: TextField(
                      controller: _reviewController,
                      decoration: InputDecoration(
                        labelText: 'Comment',
                        labelStyle:
                            const TextStyle(color: Colors.deepOrangeAccent),
                        border: const OutlineInputBorder(),
                        enabledBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.deepOrangeAccent),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.deepOrangeAccent),
                        ),
                      ),
                      maxLines: 3,
                      cursorColor: Colors.deepOrangeAccent,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                    onPressed: _submitReview,
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    child: const Text(
                      'Submit Review',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ],
          ),
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
