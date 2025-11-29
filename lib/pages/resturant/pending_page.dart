import 'package:flutter/material.dart';
import '../../resources/auth_methods.dart';

Widget pendingPage(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.orange,
    body: Center(child: Padding(
      padding: const EdgeInsets.all(70.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Your approval is pending, Be Patient...'),
          const Divider(),
          IconButton.filled(
              onPressed: () {
                 AuthMethods().signOut(context);
                Navigator.of(context).pushReplacementNamed('/login-signup');
              },
              icon: const Icon(
                Icons.logout_outlined,
                color: Colors.black,
                size: 15,
                
              ),
              
            ),
            
        ],
      ),
    )),
  );
}
