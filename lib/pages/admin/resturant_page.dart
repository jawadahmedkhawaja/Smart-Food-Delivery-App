import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../utils/snack_bar.dart';

class RestaurantPage extends StatefulWidget {
  const RestaurantPage({super.key});

  @override
  State<RestaurantPage> createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  Stream<List<Map<String, dynamic>>> getPendingRestaurants() {
    return FirebaseFirestore.instance
        .collection('restaurants')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'restaurantId': doc.id,
              'name': data['name'] ?? 'N/A',
              'address': data['address'] ?? 'N/A',
              'contact': data['contact'] ?? 'N/A',
            };
          }).toList();
        });
  }

  Future<void> _changeStatus(String id, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('restaurants').doc(id).update(
        {'status': newStatus},
      );

      showSnackBar(context, 'Restaurant marked as $newStatus');
    } catch (e) {
      showSnackBar(context, 'Error updating status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Restaurant Approvals'),
        backgroundColor: Colors.redAccent,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getPendingRestaurants(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data;

          if (data == null || data.isEmpty) {
            return const Center(child: Text('No new restaurants to approve!'));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final restaurant = data[index];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: const BorderSide(color: Colors.redAccent),
                ),
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow('Restaurant Name', restaurant['name']),
                      _infoRow('Address', restaurant['address']),
                      _infoRow('Contact', restaurant['contact']),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () => _changeStatus(
                              restaurant['restaurantId'],
                              'active',
                            ),
                            child: const Text(
                              'Approve',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => _changeStatus(
                              restaurant['restaurantId'],
                              'declined',
                            ),
                            child: const Text(
                              'Decline',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$title: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
