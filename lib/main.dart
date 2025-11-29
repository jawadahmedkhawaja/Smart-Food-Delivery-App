import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'pages/admin/admin_dashboard.dart';
import 'pages/customer/cart_pages/cart_provider.dart';
import 'pages/customer/customer_dashboard.dart';
import 'pages/delievrer/delievrer_dashboard.dart';
import 'pages/login_page.dart';
import 'pages/resturant/resturant_dashboard.dart';
import 'pages/resturant/restuarant_detial_form.dart';
import 'pages/email_verification_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFFF8C42);
    const accentOrange = Color(0xFFFFA559);
    const lightBackground = Color(0xFFF9F9F9);
    const darkText = Color(0xFF222222);

    return ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Smart Food Delivery App',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: lightBackground,
          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryOrange,
            primary: primaryOrange,
            secondary: accentOrange,
            shadow: lightBackground,
            surface: Colors.white,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: primaryOrange,
            foregroundColor: Colors.white,
            elevation: 0,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.white),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryOrange, width: 2),
            ),
            prefixIconColor: primaryOrange,
            labelStyle: const TextStyle(color: darkText),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              foregroundColor: Colors.white,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: primaryOrange,
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: primaryOrange,
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
          snackBarTheme: const SnackBarThemeData(
            backgroundColor: primaryOrange,
            contentTextStyle: TextStyle(color: Colors.white),
            behavior: SnackBarBehavior.floating,
          ),
        ),

        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, authSnapshot) {
            if (authSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator.adaptive()),
              );
            }

            final user = authSnapshot.data;

            if (user == null) {
              return const LoginAndSignUpPage();
            }

            return FutureBuilder<Widget>(
              future: _redirectBasedOnRole(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator.adaptive()),
                  );
                }
                return snapshot.data!;
              },
            );
          },
        ),

        // ------------------------------------------------------
        routes: {
          '/login-signup': (context) => const LoginAndSignUpPage(),
          '/admin': (context) => const AdminDashboard(),
          '/resturant': (context) => const ResturantDashboard(),
          '/customer': (context) => const CustomerDashboard(),
          '/delievrer': (context) => const DelievrerDashboard(),
        },
      ),
    );
  }
}

/// Redirect user based on Firestore "role"
Future<Widget> _redirectBasedOnRole() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return const LoginAndSignUpPage();
  }

  await user.reload(); // Ensure we have the latest status
  if (!user.emailVerified) {
    return const EmailVerificationPage();
  }

  final uid = user.uid;

  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get();

  final role = userDoc.data()?['role'];

  switch (role) {
    case 'resturant':
      final res = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(uid)
          .get();
      return res.exists ? const ResturantDashboard() : const InfoForm();

    case 'customer':
      return const CustomerDashboard();

    case 'admin':
      return const AdminDashboard();

    case 'delivery':
      return const DelievrerDashboard();

    default:
      return const LoginAndSignUpPage();
  }
}
