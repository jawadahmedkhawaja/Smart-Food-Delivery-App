import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../resources/auth_methods.dart';
import 'admin_card.dart';
import 'orders_per_day.dart';
import 'pie_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ✅ Corrected data fetching logic
  Future<Map<String, dynamic>> getDataFromFirestore() async {
    // Count users by roles (correct way)
    final totalUsersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isNotEqualTo: 'admin')
        .count()
        .get();

    final totalRestaurantsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'resturant')
        .count()
        .get();

    final totalCustomersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'customer')
        .count()
        .get();

    final ordersSnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .get();

    double totalRevenue = 0;
    int activeOrders = 0;

    for (var doc in ordersSnapshot.docs) {
      final data = doc.data();
      if (data.containsKey('price')) {
        totalRevenue += (data['price'] as num).toDouble();
      }
      if (data['status'] == 'active') activeOrders++;
    }

    return {
      'totalUsers': totalUsersSnapshot.count,
      'totalRestaurants': totalRestaurantsSnapshot.count,
      'totalCustomers': totalCustomersSnapshot.count,
      'totalRevenue': totalRevenue,
      'activeOrders': activeOrders,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admininstration'),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              AuthMethods().signOut(context);
              Navigator.of(context).pushReplacementNamed('/login-signup');
            },
            icon: const Icon(
              Icons.logout_outlined,
              color: Colors.black,
              size: 15,
            ),
          ),
        ],
      ),

      // ✅ Scrollable + async safe body
      body: FutureBuilder<Map<String, dynamic>>(
        future: getDataFromFirestore(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data found'));
          }

          final data = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // ✅ First Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdminCard(
                      icon: Icons.person,
                      label: 'Total Users',
                      value: data['totalUsers'].toString(),
                    ),
                    AdminCard(
                      icon: Icons.restaurant,
                      label: 'Restaurants',
                      value: data['totalRestaurants'].toString(),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // ✅ Second Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdminCard(
                      icon: Icons.directions_bike,
                      label: 'Active Orders',
                      value: data['activeOrders'].toString(),
                    ),
                    AdminCard(
                      icon: Icons.attach_money,
                      label: 'Total Revenue',
                      value: '\$${data['totalRevenue'].toStringAsFixed(2)}',
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                const Column(
                  children: [
                    SizedBox(height: 300, child: OrdersLineChart()),
                    SizedBox(height: 300, child: RoleDistributionChart()),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
