import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_details_page.dart';
import 'product_model.dart';
import 'shop_page.dart';
import 'app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'checkout.dart';

class CartPage extends StatefulWidget {
  final AppBar Function(BuildContext) appBarBuilder;

  const CartPage({Key? key, required this.appBarBuilder}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Product> cartItems = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user; // Make user nullable

  @override
  void initState() {
    super.initState();

    user = _auth.currentUser;

    if (user == null) {
      // Redirect to LoginPage if not logged in
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      });
    } else {
      _fetchCartItems();
    }
  }

  Future<void> _fetchCartItems() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('cart')
          .where('userId', isEqualTo: user!.uid)
          .get();

      List<Product> items = querySnapshot.docs.map<Product>((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Product(
          description: data['description'] ?? '',
          id: data['productId'] ?? 0,
          image: data['image'] ?? '',
          name: data['name'] ?? '',
          price: (data['price'] as num?)?.toDouble() ?? 0.0,
          category: data['category'] ?? '',
          quantity: data['quantity'] ?? 1,
        );
      }).toList();

      setState(() {
        cartItems = items;
      });
    } catch (e) {
      print('Error fetching cart items: $e');
    }
  }

  Future<void> _removeFromCart(int productId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('cart')
          .where('userId', isEqualTo: user!.uid)
          .where('productId', isEqualTo: productId)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      setState(() {
        cartItems.removeWhere((item) => item.id == productId);
      });
    } catch (e) {
      print('Error removing item from cart: $e');
    }
  }

  double _calculateTotalPrice() {
    double total = 0;
    for (var item in cartItems) {
      total += item.price * item.quantity;
    }
    return total;
  }

  Future<void> _updateCartQuantity(int productId, int newQuantity) async {
    if (newQuantity < 1) {
      _removeFromCart(productId);
      return;
    }

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('cart')
          .where('userId', isEqualTo: user!.uid)
          .where('productId', isEqualTo: productId)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.update({'quantity': newQuantity});
      }

      setState(() {
        final index = cartItems.indexWhere((item) => item.id == productId);
        if (index != -1) {
          cartItems[index].quantity = newQuantity;
        }
      });
    } catch (e) {
      print('Error updating cart quantity: $e');
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _buildCartItem({
    required Product item,
    required Function(int) onRemove,
    required Function(int, int) onUpdateQuantity,
    Function()? onTap,
  }) {
    return _AnimatedHoverContainer(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Image.network(
                item.image,
                width: 90.0,
                height: 90.0,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(
                    width: 90,
                    height: 90,
                    child: Icon(Icons.image_not_supported, size: 40),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Quantity: '),
                        IconButton(
                          icon: const Icon(Icons.remove),
                          constraints: const BoxConstraints(maxHeight: 24),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            onUpdateQuantity(item.id, item.quantity - 1);
                          },
                        ),
                        Text('${item.quantity}'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          constraints: const BoxConstraints(maxHeight: 24),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            onUpdateQuantity(item.id, item.quantity + 1);
                          },
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Price: \$${item.price.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.deepOrangeAccent),
              onPressed: () {
                onRemove(item.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double total = _calculateTotalPrice();
    return Scaffold(
      appBar: widget.appBarBuilder(context),
      body: cartItems.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Your Cart",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Your cart is empty.",
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0)),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShopPage(
                              appBarBuilder: buildAppBar,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Browse Products',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionHeader("Your Cart"),
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return _buildCartItem(
                        item: item,
                        onRemove: _removeFromCart,
                        onUpdateQuantity: _updateCartQuantity,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailsPage(
                                product: item,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                // Centered, deepOrangeAccent color, increased font size for total
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 20),
                  child: Text(
                    'Total: \$${total.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 24.0,
                          color: Colors.deepOrangeAccent,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10),
                  child: ElevatedButton(
                    onPressed: total > 0
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CheckoutPage(totalAmount: total),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                    ),
                    child: Text(
                      'Checkout',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
    );
  }
}

/// A container that provides a subtle hover scaling effect on desktop/web.
class _AnimatedHoverContainer extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _AnimatedHoverContainer({Key? key, required this.child, this.onTap})
      : super(key: key);

  @override
  State<_AnimatedHoverContainer> createState() =>
      _AnimatedHoverContainerState();
}

class _AnimatedHoverContainerState extends State<_AnimatedHoverContainer> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final scale = _hovering ? 1.02 : 1.0;

    return MouseRegion(
      onEnter: (_) => setState(() {
        _hovering = true;
      }),
      onExit: (_) => setState(() {
        _hovering = false;
      }),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          child: widget.child,
        ),
      ),
    );
  }
}
