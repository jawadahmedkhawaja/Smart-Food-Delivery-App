import 'package:flutter/material.dart';

import '../../resources/auth_methods.dart';
import '../../utils/snack_bar.dart';

class AddAdmin extends StatefulWidget {
  const AddAdmin({super.key});

  @override
  State<AddAdmin> createState() => _AddAdminState();
}

class _AddAdminState extends State<AddAdmin> {
  final signUpKey = GlobalKey<FormState>();

  final signUpEmailController = TextEditingController();

  final signUpPasswordController = TextEditingController();

  final signUpUserNameController = TextEditingController();
  bool isVisible = false;

  @override
  Widget build(BuildContext context) {
    const Color primaryOrange = Color(0xFFFF8C42);
    const Color accentOrange = Color(0xFFFFA559);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Colors.grey),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: signUpKey,
        child: Padding(
          padding: const EdgeInsets.only(top: 200),
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
                  const Text(
                    'Add an Admin',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
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
                    controller: signUpPasswordController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                    obscureText: !isVisible,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline),
                      labelText: 'Password',
                      border: border,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() => isVisible = !isVisible);
                        },
                        icon: Icon(
                          isVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () async {
                      if (signUpKey.currentState!.validate()) {
                        final email = signUpEmailController.text.trim();
                        final password = signUpPasswordController.text.trim();
                        final username = signUpUserNameController.text.trim();

                        if (email.isEmpty ||
                            password.isEmpty ||
                            username.isEmpty) {
                          showSnackBar(context, 'Please fill all fields');
                          return;
                        }

                        await AuthMethods().signUp(
                          context,
                          email,
                          password,
                          username,
                          'admin',
                        );
                        showSnackBar(
                          context,
                          'Admin ($username) Created Successfully!',
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentOrange,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Add Admin'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
