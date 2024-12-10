import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_bar.dart';

class SuccessPage extends StatefulWidget {
  const SuccessPage({Key? key}) : super(key: key);

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _processOrderAndClearCart();
  }

  Future<void> _processOrderAndClearCart() async {
    final user = _auth.currentUser;
    if (user == null) {
      print("No user logged in.");
      return;
    }

    final cartCollection = FirebaseFirestore.instance.collection('cart');
    final querySnapshot =
        await cartCollection.where('userId', isEqualTo: user.uid).get();

    if (querySnapshot.docs.isNotEmpty) {
      print("Cart items found. Creating order...");
      List<Map<String, dynamic>> items = [];
      double totalAmount = 0.0;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final price = (data['price'] as num?)?.toDouble() ?? 0.0;
        final quantity = data['quantity'] ?? 1;
        totalAmount += price * quantity;

        items.add({
          'productId': data['productId'],
          'name': data['name'],
          'price': price,
          'quantity': quantity,
        });
      }

      await FirebaseFirestore.instance.collection('orders').add({
        'userId': user.uid,
        'items': items,
        'totalAmount': totalAmount,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Clear the cart
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      print("Order created and cart cleared.");
    } else {
      print("No cart items found, no order created.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: const Center(
        child: Text(
          'Your payment was successful!\nYour cart has been cleared.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
