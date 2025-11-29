import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../resources/auth_methods.dart';
import '../utils/snack_bar.dart';
import 'forgot_password_page.dart';
import 'resturant/const_page.dart';
import 'resturant/restuarant_detial_form.dart';

class LoginAndSignUpPage extends StatefulWidget {
  const LoginAndSignUpPage({super.key});

  @override
  State<LoginAndSignUpPage> createState() => _LoginAndSignUpPageState();
}

class _LoginAndSignUpPageState extends State<LoginAndSignUpPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool isLoginVisible = false;
  bool isSignUpVisible = false;
  bool isLoading = false;

  final signUpKey = GlobalKey<FormState>();
  final loginKey = GlobalKey<FormState>();

  final signUpEmailController = TextEditingController();
  final signUpPasswordController = TextEditingController();
  final signUpUserNameController = TextEditingController();
  final signUpRoleController = TextEditingController();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    signUpEmailController.dispose();
    signUpPasswordController.dispose();
    signUpUserNameController.dispose();
    signUpRoleController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String? passwordValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Password is required';
    final password = value.trim();

    if (password.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Must contain 1 uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Must contain 1 lowercase letter';
    }
    if (!RegExp(r'\d').hasMatch(password)) return 'Must contain 1 digit';
    if (!RegExp(r'[!@#\$%\^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'Must contain 1 special character (!@#\$%^&* etc.)';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryOrange = Color(0xFFFF8C42);
    const Color accentOrange = Color(0xFFFFA559);

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Colors.grey),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text(
          'Smart Food Delivery App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Icon(Icons.fastfood_outlined, size: 32, color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(
              child: Text(
                'Sign In',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Tab(
              child: Text(
                'Sign Up',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ------------------- SIGN IN -------------------
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: loginKey,
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    shadowColor: primaryOrange.withOpacity(0.3),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: emailController,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Email is required';
                              }
                              if (!RegExp(
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                              ).hasMatch(value.trim())) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.email_outlined),
                              labelText: 'Email',
                              border: border,
                            ),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            controller: passwordController,
                            validator: passwordValidator,
                            obscureText: !isLoginVisible,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock_outline),
                              labelText: 'Password',
                              border: border,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(
                                    () => isLoginVisible = !isLoginVisible,
                                  );
                                },
                                icon: Icon(
                                  isLoginVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              ),
                            ),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPasswordPage(),
                                  ),
                                );
                              },
                              child: const Text('Forgot Password?'),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    if (loginKey.currentState!.validate()) {
                                      setState(() => isLoading = true);
                                      bool res = false;
                                      try {
                                        res = await AuthMethods().signIn(
                                          context,
                                          emailController.text.trim(),
                                          passwordController.text.trim(),
                                        );
                                      } catch (e) {
                                        showSnackBar(context, e.toString());
                                      }
                                      setState(() => isLoading = false);

                                      if (res) {
                                        final uid = FirebaseAuth
                                            .instance
                                            .currentUser
                                            ?.uid;
                                        if (uid == null) {
                                          showSnackBar(
                                            context,
                                            'User ID is null.',
                                          );
                                          return;
                                        }
                                        setState(() => isLoading = true);
                                        try {
                                          final userDoc =
                                              await FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(uid)
                                                  .get();

                                          if (userDoc.exists) {
                                            final role = userDoc
                                                .data()?['role'];
                                            switch (role) {
                                              case 'resturant':
                                                final res =
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection(
                                                          'restaurants',
                                                        )
                                                        .doc(userDoc.id)
                                                        .get();
                                                if (res.exists) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const ConstPage(),
                                                    ),
                                                  );
                                                } else {
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const InfoForm(),
                                                    ),
                                                  );
                                                }
                                                break;
                                              case 'customer':
                                                Navigator.pushReplacementNamed(
                                                  context,
                                                  '/customer',
                                                );
                                                break;
                                              case 'admin':
                                                Navigator.pushReplacementNamed(
                                                  context,
                                                  '/admin',
                                                );
                                                break;
                                              case 'delivery':
                                                Navigator.pushReplacementNamed(
                                                  context,
                                                  '/delievrer',
                                                );
                                                break;
                                              default:
                                                showSnackBar(
                                                  context,
                                                  'User role not recognized.',
                                                );
                                                setState(() {
                                                  isLoading = false;
                                                });
                                            }
                                          } else {
                                            showSnackBar(
                                              context,
                                              'User data not found in Firestore.',
                                            );
                                            setState(() => isLoading = false);
                                          }
                                        } catch (e) {
                                          showSnackBar(context, e.toString());
                                          setState(() => isLoading = false);
                                        }
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryOrange,
                              minimumSize: const Size(double.infinity - 20, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text('Log In'),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account?"),
                              TextButton(
                                onPressed: () => _tabController.animateTo(1),
                                child: const Text('Sign up'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ------------------- SIGN UP -------------------
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: signUpKey,
              child: Card(
                elevation: 6,
                shadowColor: primaryOrange.withAlpha(30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: signUpUserNameController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Full Name is required';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person_outline),
                          labelText: 'Full Name',
                          border: border,
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: signUpEmailController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email is required';
                          }
                          if (!RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                          ).hasMatch(value.trim())) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email_outlined),
                          labelText: 'Email',
                          border: border,
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: signUpPasswordController,
                        validator: passwordValidator,
                        obscureText: !isSignUpVisible,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline),
                          labelText: 'Password',
                          border: border,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(
                                () => isSignUpVisible = !isSignUpVisible,
                              );
                            },
                            icon: Icon(
                              isSignUpVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        onChanged: (value) {
                          signUpRoleController.text = value ?? '';
                        },
                        items: const [
                          DropdownMenuItem(
                            value: 'resturant',
                            child: Text('Restaurant'),
                          ),
                          DropdownMenuItem(
                            value: 'customer',
                            child: Text('Customer'),
                          ),
                          DropdownMenuItem(
                            value: 'delivery',
                            child: Text('Delivery'),
                          ),
                        ],
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.assignment_ind_outlined),
                          labelText: 'Select Role',
                          border: border,
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                      const SizedBox(height: 25),
                      ElevatedButton(
                        onPressed: () async {
                          if (signUpKey.currentState!.validate()) {
                            final email = signUpEmailController.text.trim();
                            final password = signUpPasswordController.text
                                .trim();
                            final username = signUpUserNameController.text
                                .trim();
                            final role = signUpRoleController.text
                                .trim()
                                .toLowerCase();

                            if (email.isEmpty ||
                                password.isEmpty ||
                                username.isEmpty ||
                                role.isEmpty) {
                              showSnackBar(context, 'Please fill all fields');
                              return;
                            }

                            final bool res = await AuthMethods().signUp(
                              context,
                              email,
                              password,
                              username,
                              role,
                            );

                            if (res) _tabController.animateTo(0);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentOrange,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Sign Up'),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account?'),
                          TextButton(
                            onPressed: () => _tabController.animateTo(0),
                            child: const Text('Log in'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
