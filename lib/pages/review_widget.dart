import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductReviews extends StatefulWidget {
  final int productId;

  const ProductReviews({Key? key, required this.productId}) : super(key: key);

  @override
  State<ProductReviews> createState() => _ProductReviewsState();
}

class _ProductReviewsState extends State<ProductReviews> {
  final _auth = FirebaseAuth.instance;
  final TextEditingController _commentController = TextEditingController();
  int _selectedRating = 5; // Default rating

  Future<void> _submitReview() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You must be logged in to leave a review.')),
      );
      return;
    }

    final rating = _selectedRating;
    final comment = _commentController.text.trim();
    if (rating < 1 || rating > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a rating between 1 and 5')),
      );
      return;
    }

    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a review comment.')),
      );
      return;
    }

    final productRef = FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId.toString());

    await productRef.collection('reviews').add({
      'userId': currentUser.uid,
      'rating': rating,
      'comment': comment,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Clear the form
    _commentController.clear();
    setState(() {
      _selectedRating = 5;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Review added')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productRef = FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId.toString());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        Text(
          'Reviews',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        StreamBuilder<QuerySnapshot>(
          stream: productRef
              .collection('reviews')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();
            final reviewDocs = snapshot.data!.docs;
            if (reviewDocs.isEmpty) {
              return const Text('No reviews yet.');
            }

            return ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: reviewDocs.length,
              itemBuilder: (context, index) {
                final data = reviewDocs[index].data() as Map<String, dynamic>;
                final rating = data['rating'] ?? 0;
                final comment = data['comment'] ?? '';
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(5, (starIndex) {
                          return Icon(
                            starIndex < rating ? Icons.star : Icons.star_border,
                            color: starIndex < rating
                                ? Colors.yellow
                                : Colors.grey,
                            size: 16,
                          );
                        }),
                      ),
                      const SizedBox(height: 8),
                      Text(comment, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 20),
        if (_auth.currentUser != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Leave a Review',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: List.generate(5, (index) {
                  final starIndex = index + 1;
                  return IconButton(
                    icon: Icon(
                      starIndex <= _selectedRating
                          ? Icons.star
                          : Icons.star_border,
                      color: starIndex <= _selectedRating
                          ? Colors.yellow
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
              TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  labelText: 'Your review',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _submitReview,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child: const Text('Submit Review',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
      ],
    );
  }
}
