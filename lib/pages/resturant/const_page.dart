import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'declination_page.dart';
import 'pending_page.dart';
import 'resturant_dashboard.dart';

class ConstPage extends StatelessWidget {
  const ConstPage({super.key});

  Future<String?> checkStatus(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(uid)
          .get();

      if (doc.exists && doc.data()!.containsKey('status')) {
        return doc['status'] as String?;
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching status: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder<String?>(
      future: checkStatus(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator.adaptive()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final status = snapshot.data;

        if (status == 'pending') {
          return pendingPage(context);
        } else if (status == 'declined') {
          return declinationPage();
        } else {
          return const ResturantDashboard();
        }
      },
    );
  }
}
