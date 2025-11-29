import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/snack_bar.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool _isEmailVerified = false;
  Timer? _timer;
  Timer? _resendTimer;
  int _resendCountdown = 0;
  bool _isLoading = false;

  bool get _canResend => _resendCountdown == 0;

  @override
  void initState() {
    super.initState();
    _isEmailVerified =
        FirebaseAuth.instance.currentUser?.emailVerified ?? false;

    if (!_isEmailVerified) {
      _sendVerificationEmail();

      // Auto-check every 3 seconds
      _timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => _checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _resendTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkEmailVerified() async {
    final User? user = FirebaseAuth.instance.currentUser;
    await user?.reload();

    setState(() {
      _isEmailVerified = user?.emailVerified ?? false;
    });

    if (_isEmailVerified && user != null) {
      _timer?.cancel();

      // Update Firestore emailVerified field
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'emailVerified': true});
      } catch (e) {
        print('Error updating Firestore: $e');
      }

      // Navigate to home which will redirect to appropriate dashboard
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    }
  }

  Future<void> _sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();

        if (mounted) {
          showSnackBar(context, 'Verification email sent!');
        }

        _startResendTimer();
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'Error sending email: $e');
      }
    }
  }

  void _startResendTimer() {
    setState(() => _resendCountdown = 60);
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown == 0) {
        timer.cancel();
        setState(() {});
      } else {
        setState(() => _resendCountdown--);
      }
    });
  }

  Future<void> _manuallyCheckVerification() async {
    setState(() => _isLoading = true);
    await _checkEmailVerified();
    setState(() => _isLoading = false);

    if (_isEmailVerified) {
      // If verified, we can pop or let main.dart handle it.
      // Since main.dart redirects based on role, we might need to trigger that.
      // A simple way is to restart the app or just navigate to wrapper.
      // But since we are in a page that is likely blocking the main content,
      // we should probably just show a success dialog and then navigate.

      // Actually, if we are using the StreamBuilder in main.dart,
      // and we just reloaded the user, the stream might not emit a new event.
      // We can force a refresh by using setState in main.dart or just navigating.
      // Let's assume main.dart will check on next app start or we can use
      // Navigator.pushReplacementNamed(context, '/');
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } else {
      if (mounted) {
        showSnackBar(
          context,
          'Email not yet verified. Please check your inbox.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFFF8C42);
    const accentOrange = Color(0xFFFFA559);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text('Verify Email'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: FirebaseAuth.instance.signOut,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryOrange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isEmailVerified
                    ? Icons.mark_email_read
                    : Icons.mark_email_unread,
                size: 80,
                color: primaryOrange,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              _isEmailVerified
                  ? 'Email Verified!'
                  : 'Verify your email address',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              _isEmailVerified
                  ? 'Thank you for verifying your email. You can now access all features.'
                  : 'We have sent a verification email to:\n${FirebaseAuth.instance.currentUser?.email ?? ""}\n\nPlease check your inbox and click the link to verify your account.',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            if (!_isEmailVerified) ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _manuallyCheckVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('I have verified my email'),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: _canResend ? _sendVerificationEmail : null,
                child: Text(
                  _canResend
                      ? 'Resend Verification Email'
                      : 'Resend in ${_resendCountdown}s',
                  style: TextStyle(
                    color: _canResend ? accentOrange : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/', (route) => false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Continue to App'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
