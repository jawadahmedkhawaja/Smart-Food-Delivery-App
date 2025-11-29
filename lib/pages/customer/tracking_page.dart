
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackingPage extends StatefulWidget {
  final dynamic order;
  const TrackingPage({super.key, required this.order});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  bool _autoFollow = true;
  StreamSubscription<DocumentSnapshot>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _startLocationTracking();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _startLocationTracking() {
    if (widget.order['delieverID'] == null) return;

    _locationSubscription = FirebaseFirestore.instance
        .collection('delivery_locations')
        .doc(widget.order['delieverID'])
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data() as Map<String, dynamic>;
        final double lat = (data['lat'] as num?)?.toDouble() ?? 0.0;
        final double lng = (data['lng'] as num?)?.toDouble() ?? 0.0;

        final deliveryPosition = LatLng(lat, lng);

        // Update markers
        _updateMarkers(deliveryPosition: deliveryPosition);

        // Auto-follow delivery person
        if (_autoFollow && _mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLng(deliveryPosition),
          );
        }
      }
    });
  }

  Future<void> _updateMarkers({required LatLng deliveryPosition}) async {
    final newMarkers = <Marker>{};

    // Customer marker
    final userLocation = _convertToLatLng(widget.order['location']);
    if (userLocation.latitude != 0.0 || userLocation.longitude != 0.0) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('customer'),
          position: userLocation,
          infoWindow: InfoWindow(
            title: 'Your Location',
            snippet: widget.order['address'] ?? 'Delivery Location',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    // Delivery person marker
    newMarkers.add(
      Marker(
        markerId: const MarkerId('delivery'),
        position: deliveryPosition,
        infoWindow: const InfoWindow(
          title: 'Delivery Person',
          snippet: 'Delivering your order',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    // Restaurant marker
    if (widget.order['restaurantId'] != null) {
      try {
        final restaurantDoc = await FirebaseFirestore.instance
            .collection('restaurants')
            .doc(widget.order['restaurantId'])
            .get();

        if (restaurantDoc.exists) {
          final restaurantData = restaurantDoc.data();
          if (restaurantData != null && restaurantData['location'] != null) {
            final restLoc = restaurantData['location'] as Map<String, dynamic>;
            newMarkers.add(
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
                    BitmapDescriptor.hueOrange),
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('Error fetching restaurant: $e');
      }
    }

    if (mounted) {
      setState(() {
        _markers.clear();
        _markers.addAll(newMarkers);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tracking Order #${widget.order['orderId']?.substring(0, 8) ?? ''}'),
        actions: [
          IconButton(
            icon: Icon(
              _autoFollow ? Icons.my_location : Icons.location_searching,
              color: _autoFollow ? Colors.blue : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _autoFollow = !_autoFollow;
              });
            },
            tooltip: _autoFollow ? 'Auto-follow ON' : 'Auto-follow OFF',
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: widget.order['delieverID'] != null
            ? FirebaseFirestore.instance
                .collection('delivery_locations')
                .doc(widget.order['delieverID'])
                .snapshots()
            : null,
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading tracking information...'),
                ],
              ),
            );
          }

          // No delivery person assigned
          if (widget.order['delieverID'] == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.delivery_dining,
                      size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No Delivery Person Assigned',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Current Status: ${widget.order['status'] ?? 'Pending'}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Your order is being prepared. Delivery person will be assigned soon.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }

          // No location data
          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Location Not Available',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('Waiting for delivery person to start...'),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final double lat = (data['lat'] as num?)?.toDouble() ?? 0.0;
          final double lng = (data['lng'] as num?)?.toDouble() ?? 0.0;
          final userLocation = _convertToLatLng(widget.order['location']);

          return Column(
            children: [
              // Google Map
              Expanded(
                flex: 2,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(lat, lng),
                    zoom: 14,
                  ),
                  markers: _markers,
                  mapToolbarEnabled: false,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  onCameraMove: (_) {
                    // Disable auto-follow when user manually moves map
                    if (_autoFollow) {
                      setState(() {
                        _autoFollow = false;
                      });
                    }
                  },
                ),
              ),

              // Order Details Card
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Indicator
                        Center(
                          child: _buildStatusIndicator(
                              widget.order['status'] ?? 'Pending'),
                        ),
                        const SizedBox(height: 20),

                        // Order Info
                        _buildInfoRow(
                          icon: Icons.receipt,
                          label: 'Order Total',
                          value:
                              'Rs ${widget.order['total']?.toStringAsFixed(2) ?? '0.00'}',
                          color: Colors.green,
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          icon: Icons.location_on,
                          label: 'Delivery Address',
                          value: widget.order['address'] ?? 'N/A',
                          color: Colors.blue,
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          icon: Icons.shopping_bag,
                          label: 'Items',
                          value: '${(widget.order['items'] as List?)?.length ?? 0} items',
                          color: Colors.orange,
                        ),

                        // Distance indicator (if available)
                        if (lat != 0.0 && lng != 0.0)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.directions_bike,
                                      color: Colors.blue, size: 24),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _autoFollow
                                          ? 'Following delivery person in real-time'
                                          : 'Tap location icon to follow delivery person',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusIndicator(String status) {
    Color color;
    IconData icon;

    switch (status) {
      case 'Picked Up':
        color = Colors.purple;
        icon = Icons.check_circle;
        break;
      case 'On the Way':
        color = Colors.teal;
        icon = Icons.local_shipping;
        break;
      case 'Delivered':
        color = Colors.green;
        icon = Icons.done_all;
        break;
      default:
        color = Colors.orange;
        icon = Icons.pending;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Text(
            status,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  LatLng _convertToLatLng(dynamic locationData) {
    if (locationData is GeoPoint) {
      return LatLng(locationData.latitude, locationData.longitude);
    } else if (locationData is Map) {
      final Map<dynamic, dynamic> locationMap = locationData;
      if (locationMap.containsKey('latitude') &&
          locationMap.containsKey('longitude')) {
        return LatLng(
          (locationMap['latitude'] as num).toDouble(),
          (locationMap['longitude'] as num).toDouble(),
        );
      } else if (locationMap.containsKey('lat') &&
          locationMap.containsKey('lng')) {
        return LatLng(
          (locationMap['lat'] as num).toDouble(),
          (locationMap['lng'] as num).toDouble(),
        );
      }
    }

    return const LatLng(0.0, 0.0);
  }
}
