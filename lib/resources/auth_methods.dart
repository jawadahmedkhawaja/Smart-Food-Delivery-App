import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/snack_bar.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ---------------- SIGN UP ----------------
  Future<bool> signUp(
    BuildContext context,
    String emailAddress,
    String password,
    String userName,
    String userType,
  ) async {
    try {
      // Create user
      final UserCredential credential = await _auth
          .createUserWithEmailAndPassword(
            email: emailAddress.trim(),
            password: password.trim(),
          );

      final User? user = credential.user;

      if (user != null) {
        // Store user data in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'userName': userName.trim(),
          'email': user.email,
          'isEmailVerified': false,
          'role': userType.trim().toLowerCase(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      showSnackBar(context, 'Account created successfully! Please log in.');
      return true;
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message ?? 'Something went wrong');
      return false;
    } catch (e) {
      showSnackBar(context, e.toString());
      return false;
    }
  }

  // ---------------- SIGN IN ----------------
  Future<bool> signIn(
    BuildContext context,
    String emailAddress,
    String password,
  ) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: emailAddress.trim(),
        password: password.trim(),
      );
      return true;
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message ?? 'Invalid credentials');
      return false;
    } catch (e) {
      showSnackBar(context, e.toString());
      return false;
    }
  }

  // ---------------- SIGN OUT ----------------
  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      showSnackBar(context, 'Signed out successfully.');
    } catch (e) {
      showSnackBar(context, 'Error signing out: $e');
    }
  }

  // ---------------- EMAIL VERIFICATION ----------------
  Future<void> sendVerificationEmail(BuildContext context) async {
    final User? user = _auth.currentUser;

    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      showSnackBar(
        context,
        'Verification email sent! Please check your inbox.',
      );
    } else {
      showSnackBar(context, 'Your email is already verified.');
    }
  }

  // ---------------- CHECK EMAIL VERIFICATION ----------------
  Future<bool> checkEmailVerificationStatus() async {
    User? user = _auth.currentUser;

    if (user != null) {
      await user.reload();
      user = _auth.currentUser;

      final bool verified = user!.emailVerified;

      await _firestore.collection('users').doc(user.uid).update({
        'isEmailVerified': verified,
      });

      return verified;
    }
    return false;
  }

  // ---------------- UTILITIES ----------------
  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;


  // ---------------- GET USER NAME ----------------
  Future<String?> getUserName() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return null;

      final doc =
          await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        return doc.data()?['userName'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  
}
