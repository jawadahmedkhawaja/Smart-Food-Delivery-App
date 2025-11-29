import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../utils/snack_bar.dart';
import 'const_page.dart';

class InfoForm extends StatefulWidget {
  const InfoForm({super.key});

  @override
  State<InfoForm> createState() => _InfoFormState();
}

class _InfoFormState extends State<InfoForm> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = true;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController statusController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRestaurantData();
  }

  // ---------------- Fetch existing restaurant data ----------------
  Future<void> _loadRestaurantData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final doc = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        nameController.text = data['name'] ?? '';
        addressController.text = data['address'] ?? '';
        contactController.text = data['contact'] ?? '';
      } else {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();

        if (userDoc.exists) {
          nameController.text = userDoc.data()?['userName'] ?? '';
        }
      }
    } catch (e) {
      showSnackBar(context, 'Error loading data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ---------------- Save or update restaurant data ----------------
  Future<void> _saveRestaurantInfo() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final restaurantData = {
        'restaurantId': uid,
        'name': nameController.text.trim(),
        'address': addressController.text.trim(),
        'contact': contactController.text.trim(),
        'status': 'pending',
        'updatedAt': DateTime.now(),
      };

      await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(uid)
          .set(restaurantData, SetOptions(merge: true));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ConstPage()),
      );

      showSnackBar(context, 'Restaurant info saved successfully!');
    } catch (e) {
      showSnackBar(context, 'Error saving info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryOrange = Color(0xFFFF8C42);
    const Color accentOrange = Color(0xFFFFA559);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Colors.grey),
    );

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Restaurant - Details')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Card(
            elevation: 6,
            shadowColor: primaryOrange.withAlpha(30),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Add Restaurant Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: nameController,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Name required' : null,
                    decoration: InputDecoration(
                      labelText: 'Restaurant Name',
                      prefixIcon: const Icon(Icons.store),
                      border: border,
                    ),
                  ),
                  const SizedBox(height: 15),

                  TextFormField(
                    controller: addressController,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Address required'
                        : null,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      prefixIcon: const Icon(Icons.location_on),
                      border: border,
                    ),
                  ),
                  const SizedBox(height: 15),

                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: contactController,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Contact required'
                        : null,
                    decoration: InputDecoration(
                      labelText: 'Contact',
                      prefixIcon: const Icon(Icons.phone),
                      border: border,
                    ),
                  ),
                  const SizedBox(height: 15),

                  ElevatedButton(
                    onPressed: _saveRestaurantInfo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentOrange,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Save Info',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
