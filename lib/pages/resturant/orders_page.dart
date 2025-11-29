import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../resources/auth_methods.dart';
import 'orders_detail_page.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  Stream<QuerySnapshot> getOrders() {
    final restaurantID = AuthMethods().currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('orders')
        .where('restaurantId', isEqualTo: restaurantID) 
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Orders',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Some Error has Occurred: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No Orders Yet!'));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index].data() as Map<String, dynamic>;
              
              return GestureDetector(
                onTap:() {
                  Navigator.push(context,MaterialPageRoute(builder: (context) => OrdersDetailPage(order: order,index: index,)));
                },
                child: Card(
                  
                  elevation: 15,
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Customer: ${order['customerName'] ?? 'N/A'}'),
                        Text('Total: Rs ${order['total']?.toStringAsFixed(2) ?? '0.00'}'),
                        order['status'] == 'Pending'
                            ? Text('Status: ${order['status']}', 
                                style: const TextStyle(color: Color.fromARGB(255, 255, 107, 96)))
                            : Text('Status: ${order['status']}'),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}