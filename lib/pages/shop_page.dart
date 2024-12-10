import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:focusable_control_builder/focusable_control_builder.dart';
import 'product_details_page.dart';
import 'product_model.dart';
import 'app_bar.dart';

class ShopPage extends StatefulWidget {
  final AppBar Function(BuildContext) appBarBuilder;
  final String? category;

  const ShopPage({Key? key, required this.appBarBuilder, this.category})
      : super(key: key);

  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  TextEditingController searchController = TextEditingController();

  List<Product> products = [];
  List<Product> searchResults = [];
  List<Category> categories = [];
  bool isLoading = true;

  // A set of selected categories from the filter panel
  Set<String> selectedCategories = {};

  @override
  void initState() {
    super.initState();
    _initializePage();

    searchController.addListener(() {
      filterSearchResults();
    });
  }

  Future<void> _initializePage() async {
    await _loadProductData();

    // Once products are loaded, derive categories
    final uniqueCategories = products.map((p) => p.category).toSet();
    categories = uniqueCategories.map((catName) {
      return Category(
        name: catName,
        image: "", // Not using images for categories
      );
    }).toList();

    // If a category was passed, select it and apply it
    if (widget.category != null && widget.category!.isNotEmpty) {
      setState(() {
        searchController.text = widget.category!;
        selectedCategories.add(widget.category!);
      });
    }

    // Initially show all products since no filters or search are applied
    searchResults = products;

    setState(() {
      isLoading = false;
    });
  }

  // Load products from Firestore
  Future<void> _loadProductData() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('products').get();

      final productList =
          querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();

      setState(() {
        products = productList;
      });
    } catch (e) {
      print('Error loading products: $e');
    }
  }

  void filterSearchResults() {
    if (isLoading) return; // Don't filter if still loading

    final query = searchController.text.trim().toLowerCase();

    // Start with all products
    List<Product> results = products;

    // Filter by selected categories if any
    if (selectedCategories.isNotEmpty) {
      results = results.where((product) {
        return selectedCategories.contains(product.category);
      }).toList();
    }

    // Further filter by search query if present
    if (query.isNotEmpty) {
      results = results.where((product) {
        final matchesName = product.name.toLowerCase().contains(query);
        final matchesCategory = product.category.toLowerCase().contains(query);
        return matchesName || matchesCategory;
      }).toList();
    }

    setState(() {
      searchResults = results;
    });
  }

  Widget _buildCategoryCheckboxes() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        final isSelected = selectedCategories.contains(cat.name);
        return CheckboxListTile(
          activeColor: Colors.deepOrangeAccent, // Change checkmark color
          title: Text(cat.name),
          value: isSelected,
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                selectedCategories.add(cat.name);
              } else {
                selectedCategories.remove(cat.name);
              }
            });
            filterSearchResults();
          },
        );
      },
    );
  }

  Widget _buildShopCard(Product product) {
    final priceRecord = "\$${product.price.toStringAsFixed(2)}";

    return FocusableControlBuilder(
      builder: (context, state) {
        final isHovered = state.isHovered;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailsPage(product: product),
              ),
            );
          },
          child: AnimatedScale(
            scale: isHovered ? 1.0 : 0.9,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Card(
              color: Colors.white,
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  bottomRight: Radius.circular(16.0),
                ),
                side: BorderSide(
                  color: isHovered ? Colors.black : Colors.transparent,
                  width: 2.0,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          product.image,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.error, size: 40);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      product.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      priceRecord,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrangeAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 15.0, 16.0, 10.0),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: "Search products...",
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              searchController.clear();
              filterSearchResults();
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }

  Widget _buildProductsSection() {
    double screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 830;

    if (isLoading) {
      // While loading
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (searchResults.isEmpty && products.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.0),
          child: Text(
            'No products found.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: searchResults.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          // Show 4 items per row (crossAxisCount=4),
          // adjust if screen is small if needed
          crossAxisCount: isSmallScreen ? 2 : 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: isSmallScreen ? 2 / 2.8 : 2 / 2.5,
        ),
        itemBuilder: (context, index) {
          return _buildShopCard(searchResults[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBarBuilder(context),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left-side filter panel
          Container(
            width: 250,
            color: Colors.white,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Categories',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 10),
                  _buildCategoryCheckboxes(),
                ],
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 10),
                  _buildProductsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
