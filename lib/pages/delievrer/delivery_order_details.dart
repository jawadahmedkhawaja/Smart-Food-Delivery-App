import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DeliveryOrderDetails extends StatefulWidget {
  final Map<String, dynamic> data;
  const DeliveryOrderDetails({super.key, required this.data});

  @override
  State<DeliveryOrderDetails> createState() => _DeliveryOrderDetailsState();
}

class _DeliveryOrderDetailsState extends State<DeliveryOrderDetails> {
  late Map<String, dynamic> data;
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  Position? currentPosition;
  StreamSubscription<Position>? positionStream;

  @override
  void initState() {
    super.initState();
    data = widget.data;
    _initializeMap();
    _startLocationTracking();
  }

  @override
  void dispose() {
    positionStream?.cancel();
    mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    // Get current position
    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        currentPosition = position;
      });
      _updateMarkers();
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  void _startLocationTracking() {
    positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((position) {
          setState(() {
            currentPosition = position;
          });
          _updateMarkers();

          // Update map camera to follow delivery boy
          if (mapController != null) {
            mapController!.animateCamera(
              CameraUpdate.newLatLng(
                LatLng(position.latitude, position.longitude),
              ),
            );
          }
        });
  }

  void _updateMarkers() {
    final newMarkers = <Marker>{};

    // Customer marker
    if (data['location'] != null) {
      final loc = data['location'] as Map<String, dynamic>;
      newMarkers.add(
        Marker(
          markerId: const MarkerId('customer'),
          position: LatLng(
            (loc['lat'] as num).toDouble(),
            (loc['lng'] as num).toDouble(),
          ),
          infoWindow: InfoWindow(
            title: 'Customer',
            snippet: data['customerName'] ?? 'Delivery Location',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    // Delivery boy current position marker
    if (currentPosition != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('delivery_boy'),
          position: LatLng(
            currentPosition!.latitude,
            currentPosition!.longitude,
          ),
          infoWindow: const InfoWindow(
            title: 'Your Location',
            snippet: 'Delivery Person',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    setState(() {
      markers = newMarkers;
    });
  }

  Future<DocumentSnapshot> getRestaurant(String uid) async {
    return await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(uid)
        .get();
  }

  Future<void> updateStatus(String newStatus) async {
    final orderId = data['orderId'];

    // Capture scaffold messenger before async operation
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update(
        {'status': newStatus},
      );

      if (!mounted) return;

      setState(() {
        data['status'] = newStatus;
      });

      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Status updated to: $newStatus')),
      );
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error updating status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _initializeMap();
              setState(() {});
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: getRestaurant(data['restaurantId']),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (asyncSnapshot.hasError) {
            return Center(child: Text('Error: ${asyncSnapshot.error}'));
          }

          final doc = asyncSnapshot.data as DocumentSnapshot;
          final restaurantData = doc.data() as Map<String, dynamic>?;

          // Add restaurant marker when data is available
          if (restaurantData != null &&
              restaurantData['location'] != null &&
              !markers.any((m) => m.markerId.value == 'restaurant')) {
            final restLoc = restaurantData['location'] as Map<String, dynamic>;
            markers.add(
              Marker(
                markerId: const MarkerId('restaurant'),
                position: LatLng(
                  (restLoc['lat'] as num).toDouble(),
                  (restLoc['lng'] as num).toDouble(),
                ),
                infoWindow: InfoWindow(
                  title: 'Restaurant',
                  snippet: restaurantData['name'] ?? 'Pickup Location',
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueOrange,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Google Map
                SizedBox(
                  height: 350,
                  child: data['location'] != null
                      ? GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                              (data['location']['lat'] as num).toDouble(),
                              (data['location']['lng'] as num).toDouble(),
                            ),
                            zoom: 13,
                          ),
                          markers: markers,
                          myLocationEnabled: true,
                          onMapCreated: (controller) {
                            mapController = controller;
                          },
                        )
                      : const Center(child: Text('Location not available')),
                ),

                // Order Details Card
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFFF8C42), Color(0xFFFFA559)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Center(
                              child: Text(
                                'Delivery Details',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _detailRow(
                              title: 'Restaurant',
                              value: restaurantData?['name'] ?? 'N/A',
                              context: context,
                            ),
                            const SizedBox(height: 12),
                            _detailRow(
                              title: 'Restaurant Address',
                              value: restaurantData?['address'] ?? 'N/A',
                              context: context,
                            ),
                            const SizedBox(height: 12),
                            _detailRow(
                              title: 'Customer',
                              value: data['customerName'] ?? 'N/A',
                              context: context,
                            ),
                            const SizedBox(height: 12),
                            _detailRow(
                              title: 'Delivery Address',
                              value: data['address'] ?? 'N/A',
                              context: context,
                            ),
                            const SizedBox(height: 12),
                            _detailRow(
                              title: 'Total Amount',
                              value:
                                  'Rs ${data['total']?.toStringAsFixed(2) ?? '0.00'}',
                              context: context,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Status Section
                      const Text(
                        'Order Status',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Current Status Display
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _getStatusColor(data['status']),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Current: ${data['status'] ?? 'Pending'}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Status buttons
                      data['status'] == 'Delivered'
                          ? const Center(
                              child: Text(
                                '✓ Order Delivered',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : Column(
                              children: [
                                _statusButton(
                                  label: 'Picked Up',
                                  active: data['status'] == 'Ready for Pickup',
                                  onTap: () => updateStatus('Picked Up'),
                                ),
                                const SizedBox(height: 10),
                                _statusButton(
                                  label: 'On The Way',
                                  active: data['status'] == 'Picked Up',
                                  onTap: () => updateStatus('On the Way'),
                                ),
                                const SizedBox(height: 10),
                                _statusButton(
                                  label: 'Delivered',
                                  active: data['status'] == 'On the Way',
                                  onTap: () => updateStatus('Delivered'),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Ready for Pickup':
        return Colors.blue;
      case 'Picked Up':
        return Colors.purple;
      case 'On the Way':
        return Colors.teal;
      case 'Delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _detailRow({
    required String title,
    required String value,
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.white.withOpacity(0.9),
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _statusButton({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: active ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: active ? const Color(0xFFFF8C42) : Colors.grey,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: active ? 4 : 0,
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
