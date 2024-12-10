import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String description;
  final int id;
  final String image;
  final String name;
  final double price;
  final String category; // New field for category
  int quantity; // mutable

  Product({
    required this.description,
    required this.id,
    required this.image,
    required this.name,
    required this.price,
    required this.category,
    this.quantity = 1,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Product(
      description: data['description'] ?? '',
      id: data['id'] ?? 0,
      image: data['image'] ?? '',
      name: data['name'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      category: data['category'] ?? '',
      quantity: data['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'id': id,
      'image': image,
      'name': name,
      'price': price,
      'category': category,
      'quantity': quantity,
    };
  }
}

class Category {
  final String name;
  final String image;

  Category({
    required this.name,
    required this.image,
  });

  factory Category.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Category(
      name: data['name'] ?? '',
      image: data['image'] ?? '',
    );
  }
}
