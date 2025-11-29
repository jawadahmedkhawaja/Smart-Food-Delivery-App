import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../../resources/auth_methods.dart';
import '../../../resources/data_to_db.dart';
import '../../../utils/snack_bar.dart';
import '../customer_dashboard.dart';
import 'cart_provider.dart';

class CheckoutPage extends StatefulWidget {
  final double price;

  const CheckoutPage({super.key, required this.price});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  dynamic currentPosition;
  String currentAddress = '';

  Future<void> fetchCurrentLocation() async {
    try {
      double lat = 0;
      double lng = 0;
      String address = '';

      if (kIsWeb) {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        lat = pos.latitude;
        lng = pos.longitude;
        address = 'Lat: $lat, Lng: $lng';
      } else {
        final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          await Geolocator.openLocationSettings();
          if (!mounted) return;
          showSnackBar(context, 'Enable location services.');
          return;
        }

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            if (!mounted) return;
            showSnackBar(context, 'Location permission denied');
            return;
          }
        }

        if (permission == LocationPermission.deniedForever) {
          if (!mounted) return;
          showSnackBar(context, 'Location permission permanently denied');
          return;
        }

        final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        lat = position.latitude;
        lng = position.longitude;
        currentPosition = position;

        final List<Placemark> placemarks = await placemarkFromCoordinates(
          lat,
          lng,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          address =
              '${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}';
        } else {
          address = 'Lat: $lat, Lng: $lng';
        }
      }

      if (!mounted) return;

      setState(() {
        currentPosition = {'lat': lat.toDouble(), 'lng': lng.toDouble()};
        currentAddress = address;
      });

      showSnackBar(context, 'Location fetched successfully!');
    } catch (e) {
      if (!mounted) return;
      showSnackBar(context, 'Failed to fetch location: $e');
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getCurrentUserData() async {
    final currentUser = AuthMethods().currentUser!;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context).cart;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.deepOrangeAccent,
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: getCurrentUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (snapshot.hasError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showSnackBar(context, snapshot.error.toString());
            });
            return const Center(child: Text('Something went wrong!'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User data not found.'));
          }

          final data = snapshot.data!.data()!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // User info card
                Card(
                  elevation: 4,
                  shadowColor: Colors.deepOrangeAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.person,
                              color: Colors.deepOrangeAccent,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              data['userName'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              Icons.email,
                              color: Colors.deepOrangeAccent,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              data['email'] ?? 'No email',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (data['phone'] != null)
                          Row(
                            children: [
                              const Icon(
                                Icons.phone,
                                color: Colors.deepOrangeAccent,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                data['phone'],
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Use current location button
                ElevatedButton.icon(
                  icon: const Icon(Icons.my_location),
                  label: Text(
                    currentAddress.isEmpty
                        ? 'Use Current Location'
                        : 'Location Fetched',
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.deepOrangeAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: fetchCurrentLocation,
                ),

                const SizedBox(height: 20),

                // Order summary
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Order Summary',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(height: 20, thickness: 1.5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Items', style: TextStyle(fontSize: 16)),
                            Text(
                              '${cart.length} items',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Price',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Rs ${widget.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Confirm order button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: currentPosition == null
                        ? null
                        : () async {
                            if (cart.isEmpty) {
                              showSnackBar(context, 'Cart is empty.');
                              return;
                            }

                            try {
                              final userName = await AuthMethods()
                                  .getUserName();

                              await addOrdersToDB(
                                context,
                                cart,
                                AuthMethods().currentUser!.uid,
                                userName!,
                                cart[0]['restaurantId'],
                                currentAddress,
                                widget.price,
                                currentPosition,
                              );

                              Provider.of<CartProvider>(
                                context,
                                listen: false,
                              ).clearCart();

                              showSnackBar(
                                context,
                                'Order Confirmed Successfully!',
                              );

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CustomerDashboard(),
                                ),
                              );
                            } catch (e) {
                              showSnackBar(context, e.toString());
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentPosition == null
                          ? Colors.grey
                          : Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Confirm Order',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
