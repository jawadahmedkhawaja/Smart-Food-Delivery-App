import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../utils/snack_bar.dart';

Future<void> uploadDetails(
  BuildContext context,
  String restaurantID,
  String name,
  String description,
  String price,
  String pathToImage,
) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    final docRef = firestore.collection('foods').doc();

    await docRef.set({
      'id': docRef.id,
      'restaurantId': restaurantID,
      'name': name,
      'price': price,
      'description': description,
      'imageUrl': pathToImage,
      'available': true,
    });
  } catch (e) {
    showSnackBar(context, e.toString());
  }
}

Future<void> addOrdersToDB(
  BuildContext context,
  List<dynamic> cartItems,
  String customerUid,
  String customerName,
  String restaurantId,
  String address,
  double total,
  dynamic position,
) async {
  try {
    final docRef = FirebaseFirestore.instance.collection('orders').doc();

    Map<String, double>? location;
    if (position != null) {
      if (position is Position) {
        location = {
          'lat': position.latitude.toDouble(),
          'lng': position.longitude.toDouble(),
        };
      } else if (position is Map) {
        location = {
          'lat': (position['lat'] as num).toDouble(),
          'lng': (position['lng'] as num).toDouble(),
        };
      }
    }

    await docRef.set({
      'orderId': docRef.id,
      'customerId': customerUid,
      'customerName': customerName,
      'restaurantId': restaurantId,
      'items': cartItems,
      'address': address,
      'total': total,
      'delieverID': null,
      'location': location,
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  } catch (e) {
    showSnackBar(context, e.toString());
  }
}
