import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../utils/snack_bar.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  Stream<Map<String, List<Map<String, dynamic>>>> getRoleBasedUsersStream() {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    // addDummyUsersToFirestore();
    return firestore.collection('users').snapshots().map((snapshot) {
      final List<Map<String, dynamic>> customers = [];
      final List<Map<String, dynamic>> restaurants = [];
      final List<Map<String, dynamic>> deliveries = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();

        final user = {
          'id': doc.id,
          'name': data['userName'] ?? 'No Name',
          'email': data['email'] ?? 'No Email',
          'role': data['role'] ?? 'unknown',
        };

        switch (user['role']) {
          case 'customer':
            customers.add(user);
            break;
          case 'resturant':
            restaurants.add(user);
            break;
          case 'delivery':
            deliveries.add(user);
            break;
          default:
            break;
        }
      }

      return {
        'customers': customers,
        'restaurants': restaurants,
        'deliveries': deliveries,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, List<Map<String, dynamic>>>>(
      stream: getRoleBasedUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.orange),
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('No data found'));
        }

        final data = snapshot.data!;
        final customers = data['customers'] ?? [];
        final restaurants = data['restaurants'] ?? [];
        final deliveries = data['deliveries'] ?? [];

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: Colors.orange.shade50,
            appBar: AppBar(
              backgroundColor: Colors.orange.shade600,
              title: const Text(
                'Users Page - Admin',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              bottom: const TabBar(
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(text: 'Customers'),
                  Tab(text: 'Restaurants'),
                  Tab(text: 'Delivery'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _buildUserList(customers, 'Customer'),
                _buildUserList(restaurants, 'Restaurant'),
                _buildUserList(deliveries, 'Delivery'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserList(List<Map<String, dynamic>> users, String role) {
    if (users.isEmpty) {
      return Center(
        child: Text(
          'No $role users found.',
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final name = user['name'] ?? 'No Name';
        final email = user['email'] ?? 'No Email';

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade200, Colors.orange.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.shade200.withOpacity(0.6),
                blurRadius: 6,
                offset: const Offset(2, 3),
              ),
            ],
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange.shade700,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            subtitle: Text(
              email,
              style: const TextStyle(color: Colors.black87),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              onPressed: () async {
                 final userId = user['id'];
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user['id'])
                    .delete();
                  await FirebaseFirestore.instance
          .collection('delivery')
          .doc(userId)
          .delete();

      // DELETE from 'customer' Collection (if exists)
       await FirebaseFirestore.instance
          .collection('customers')
          .doc(userId)
          .delete();
                    await FirebaseFirestore.instance
                    .collection('restaurants')
                    .doc(user['id'])
                    .delete();

                    
                showSnackBar(context, '$name deleted');
              },
            ),
          ),
        );
      },
    );
  }
}
