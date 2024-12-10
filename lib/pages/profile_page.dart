import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'login_page.dart';
import 'home_page.dart';

class ProfilePage extends StatefulWidget {
  final AppBar Function(BuildContext) appBarBuilder;

  const ProfilePage({Key? key, required this.appBarBuilder}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  bool isLoading = false;
  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> userReviews = [];

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      });
    } else {
      _loadOrders();
      _loadUserReviews();
    }
  }

  Future<void> _loadOrders() async {
    setState(() => isLoading = true);

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: user!.uid)
          .orderBy('timestamp', descending: true)
          .get();

      final orderList = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'items': data['items'] ?? [],
          'totalAmount': data['totalAmount'] ?? 0.0,
          'timestamp': data['timestamp'],
        };
      }).toList();

      setState(() {
        orders = orderList;
      });
    } catch (e) {
      print('Error loading orders: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadUserReviews() async {
    if (user == null) return;
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collectionGroup('reviews')
          .where('userId', isEqualTo: user!.uid)
          .orderBy('timestamp', descending: true)
          .get();

      final rawReviews = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'productId': doc.reference.parent.parent?.id ?? '',
          'rating': data['rating'] ?? 0,
          'comment': data['comment'] ?? '',
          'timestamp': data['timestamp'],
          'userEmail': data['userEmail'] ?? '',
        };
      }).toList();

      // Fetch product names for each review
      for (var review in rawReviews) {
        final productId = review['productId'];
        if (productId.isNotEmpty) {
          try {
            final productDoc = await FirebaseFirestore.instance
                .collection('products')
                .doc(productId)
                .get();

            final productName = (productDoc.exists && productDoc.data() != null)
                ? (productDoc.data()!['name'] as String? ?? productId)
                : productId;

            review['productName'] = productName;
          } catch (e) {
            print('Error fetching product name for $productId: $e');
            review['productName'] = review['productId'];
          }
        } else {
          review['productName'] = 'Unknown Product';
        }
      }

      setState(() {
        userReviews = rawReviews;
      });
    } catch (e) {
      print('Error loading user reviews: $e');
    }
  }

  String _getUserName(String email) {
    if (email.contains('@')) {
      return email.split('@').first;
    }
    return email;
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const SizedBox.shrink();
    }

    final String email = user!.email ?? "No Email";
    final String userName = _getUserName(email);

    return Scaffold(
      appBar: widget.appBarBuilder(context),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(userName, email),
                  const SizedBox(height: 20),
                  _buildSectionHeader(context, "Account Settings",
                      icon: Icons.settings),
                  const SizedBox(height: 10),
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: Text("Email: $email",
                        style: Theme.of(context).textTheme.bodyMedium),
                    subtitle: const Text("Tap to edit your email address"),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _showEditEmailDialog(context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text("Change Password"),
                    subtitle: const Text("Tap to change your password"),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _showChangePasswordDialog(context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text("Logout"),
                    subtitle: const Text("Tap to logout of your account"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _handleLogout,
                  ),
                  const Divider(height: 20, thickness: 1),
                  _buildSectionHeader(context, "Previous Orders",
                      icon: Icons.history),
                  const SizedBox(height: 10),
                  if (orders.isEmpty)
                    _buildEmptyOrdersMessage()
                  else
                    _buildOrdersList(),
                  const SizedBox(height: 20),
                  _buildSectionHeader(context, "Your Reviews",
                      icon: Icons.rate_review),
                  const SizedBox(height: 10),
                  if (userReviews.isEmpty)
                    const Text("You haven't left any reviews yet.",
                        style: TextStyle(fontSize: 16, color: Colors.grey))
                  else
                    _buildUserReviewsList(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader(String userName, String email) {
    return Card(
      color: const Color.fromARGB(255, 255, 255, 255),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.deepOrangeAccent,
              radius: 24.0,
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hello, $userName",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 24.0,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Welcome back to your account",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title,
      {IconData? icon}) {
    // Check if the title is one of the three specified
    bool specialTitle = (title == "Account Settings" ||
        title == "Previous Orders" ||
        title == "Your Reviews");

    final textColor = specialTitle ? Colors.deepOrangeAccent : Colors.black87;
    final iconColor = specialTitle ? Colors.deepOrangeAccent : Colors.black87;
    final fontSize = specialTitle ? 22.0 : 18.0; // Increased font size

    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 8),
        ],
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
                color: textColor,
              ),
        ),
      ],
    );
  }

  Widget _buildEmptyOrdersMessage() {
    return const Center(
      child: Text(
        "You have no previous orders.",
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  Widget _buildOrdersList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: orders.map((order) {
        final total = order['totalAmount'] ?? 0.0;
        final items = order['items'] as List<dynamic>;
        final timestamp = order['timestamp'];
        DateTime date = DateTime.now();
        if (timestamp is Timestamp) {
          date = timestamp.toDate();
        }

        final formattedDate = DateFormat.yMMMd().add_jm().format(date);

        return Card(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Order ID: ${order['id']}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  "Date: $formattedDate",
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Text(
                  "Total: \$${total.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Items:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: items.map((item) {
                    final itemData = item as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        "${itemData['name']} x${itemData['quantity']}  \$${itemData['price']}",
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUserReviewsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: userReviews.map((r) {
        final rating = r['rating'] ?? 0;
        final comment = r['comment'] ?? '';
        final productName = r['productName'] ?? r['productId'];
        final timestamp = r['timestamp'];
        DateTime date = DateTime.now();
        if (timestamp is Timestamp) {
          date = timestamp.toDate();
        }
        final formattedDate = DateFormat.yMMMd().add_jm().format(date);

        return Card(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Product: $productName",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    final starIndex = index + 1;
                    return Icon(
                      starIndex <= rating ? Icons.star : Icons.star_border,
                      color: starIndex <= rating
                          ? Colors.deepOrangeAccent
                          : Colors.grey,
                      size: 16,
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(comment, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 4),
                Text("Date: $formattedDate",
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showEditEmailDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String newEmail = '';
    String password = '';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Theme(
          data: ThemeData.dark().copyWith(
            dialogBackgroundColor: Colors.black,
            textTheme:
                ThemeData.dark().textTheme.apply(bodyColor: Colors.white),
            inputDecorationTheme: const InputDecorationTheme(
              labelStyle: TextStyle(color: Colors.white),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
            ),
          ),
          child: AlertDialog(
            title:
                const Text('Edit Email', style: TextStyle(color: Colors.white)),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: user!.email,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'New Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      } else if (!RegExp(
                              r'^([a-zA-Z0-9_\.\-])+\@([a-zA-Z0-9\-]+\.)+([a-zA-Z0-9]{2,4})+$')
                          .hasMatch(value)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                    onChanged: (value) => newEmail = value,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Enter your password to confirm'
                        : null,
                    onChanged: (value) => password = value,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child:
                    const Text('Cancel', style: TextStyle(color: Colors.white)),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
              TextButton(
                child:
                    const Text('Save', style: TextStyle(color: Colors.white)),
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    Navigator.of(dialogContext).pop();
                    await _updateEmail(newEmail, password);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateEmail(String newEmail, String password) async {
    setState(() => isLoading = true);

    try {
      final credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: password,
      );
      await user!.reauthenticateWithCredential(credential);
      await user!.updateEmail(newEmail);
      await user!.reload();
      user = FirebaseAuth.instance.currentUser;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email updated successfully')));
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'email-already-in-use') {
        message = 'This email is already in use.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password.';
      } else {
        message = 'An error occurred. Please try again.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showChangePasswordDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String newPassword = '';
    String currentPassword = '';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Theme(
          data: ThemeData.dark().copyWith(
            dialogBackgroundColor: Colors.black,
            textTheme:
                ThemeData.dark().textTheme.apply(bodyColor: Colors.white),
            inputDecorationTheme: const InputDecorationTheme(
              labelStyle: TextStyle(color: Colors.white),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
            ),
          ),
          child: AlertDialog(
            title: const Text('Change Password',
                style: TextStyle(color: Colors.white)),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    style: const TextStyle(color: Colors.white),
                    decoration:
                        const InputDecoration(labelText: 'Current Password'),
                    obscureText: true,
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Please enter your current password'
                        : null,
                    onChanged: (value) => currentPassword = value,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    style: const TextStyle(color: Colors.white),
                    decoration:
                        const InputDecoration(labelText: 'New Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a new password';
                      } else if (value.length < 6) {
                        return 'Password should be at least 6 characters';
                      }
                      return null;
                    },
                    onChanged: (value) => newPassword = value,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child:
                    const Text('Cancel', style: TextStyle(color: Colors.white)),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
              TextButton(
                child:
                    const Text('Change', style: TextStyle(color: Colors.white)),
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    Navigator.of(dialogContext).pop();
                    await _changePassword(currentPassword, newPassword);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _changePassword(
      String currentPassword, String newPassword) async {
    setState(() => isLoading = true);

    try {
      final credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: currentPassword,
      );
      await user!.reauthenticateWithCredential(credential);
      await user!.updatePassword(newPassword);
      await user!.reload();
      user = FirebaseAuth.instance.currentUser;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password changed successfully')));
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'weak-password') {
        message = 'The password is too weak.';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect current password.';
      } else {
        message = 'An error occurred. Please try again.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }
}
