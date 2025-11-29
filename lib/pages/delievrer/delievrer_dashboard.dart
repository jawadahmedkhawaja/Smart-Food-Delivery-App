import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../resources/auth_methods.dart';
import 'delivery_order_details.dart';

class DelievrerDashboard extends StatefulWidget {
  const DelievrerDashboard({super.key});

  @override
  State<DelievrerDashboard> createState() => _DelievrerDashboardState();
}

class _DelievrerDashboardState extends State<DelievrerDashboard> {
  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      startLocationTracking(AuthMethods().currentUser!.uid);
    }
  }

  Stream<QuerySnapshot> getOrders() {
    return FirebaseFirestore.instance
        .collection('orders')
        .where('delieverID', isEqualTo: AuthMethods().currentUser!.uid)
        .snapshots();
  }

  Future<void> requestLocationPermission() async {
    if (kIsWeb) return;

    final status = await Permission.locationWhenInUse.status;
    if (!status.isGranted) await Permission.locationWhenInUse.request();

    final bgStatus = await Permission.locationAlways.status;
    if (!bgStatus.isGranted) await Permission.locationAlways.request();

    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }
  }

  Future<void> startLocationTracking(String deliveryBoyId) async {
    await requestLocationPermission();

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((position) async {
      await FirebaseFirestore.instance
          .collection('delivery_locations')
          .doc(deliveryBoyId)
          .set({
            'lat': position.latitude,
            'lng': position.longitude,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    });
  }

  Future<void> updateStatus(
    BuildContext context,
    String orderId,
    String status,
  ) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final String uid = AuthMethods().currentUser!.uid;

      if (status == 'Delivered') {
        await FirebaseFirestore.instance.collection('delievrers').doc(uid).set({
          'ordersDelivered': FieldValue.increment(1),
        }, SetOptions(merge: true));
      }

      await FirebaseFirestore.instance.collection('orders').doc(orderId).update(
        {'status': status},
      );

      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Status changed to $status')),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome Deliverer'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              await AuthMethods().signOut(context);
              if (!context.mounted) return;
              navigator.pushReplacementNamed('/login-signup');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 70,
                child: Card(
                  shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  color: Colors.orange,
                  child: const Center(child: Text('Assigned Orders')),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: getOrders(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No orders assigned yet',
                          style: TextStyle(fontSize: 18),
                        ),
                      );
                    }

                    final orders = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final doc = orders[index];
                        final data = doc.data() as Map<String, dynamic>;

                        return Card(
                          color: Colors.blueGrey,
                          margin: const EdgeInsets.all(10),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DeliveryOrderDetails(data: data),
                                ),
                              );
                            },
                            title: Text(data['customerName'] ?? 'No Name'),
                            subtitle: Text(
                              "Address: ${data['address'] ?? 'No Address'}",
                            ),
                            trailing: Text(
                              data['status'] ?? 'Pending',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
