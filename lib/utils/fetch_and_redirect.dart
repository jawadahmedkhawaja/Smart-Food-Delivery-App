import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../pages/resturant/restuarant_detial_form.dart';
import '../pages/resturant/resturant_dashboard.dart';
Future<void> redirectBasedOnRole(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return; // no logged-in user

  try {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!userDoc.exists) {
      // Optional: force logout if user data missing
      await FirebaseAuth.instance.signOut();
      return;
    }

    final role = userDoc.data()?['role'];
    switch (role) {
      case 'resturant':
        final res = await FirebaseFirestore.instance
            .collection('restaurants')
            .doc(userDoc.id)
            .get();
        if (res.exists) {
          // go to dashboard
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const ResturantDashboard()),
            (route) => false,
          );
        } else {
          // go to restaurant info form
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const InfoForm()),
            (route) => false,
          );
        }
        break;

      case 'customer':
        Navigator.pushReplacementNamed(context, '/customer');
        break;

      case 'delivery':
        Navigator.pushReplacementNamed(context, '/delievrer');
        break;

      case 'admin':
        Navigator.pushReplacementNamed(context, '/admin');
        break;

      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User role not recognized.')),
        );
        break;
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
