import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String text, {bool isError = false}) {
  const Color primaryOrange = Color(0xFFFF8C42);
  const Color errorRed = Color(0xFFE53935);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: isError ? errorRed : primaryOrange,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      duration: const Duration(seconds: 3),
      elevation: 6,
    ),
  );
}




// showDialog(
//                   barrierDismissible: false,
//                   context: context,
//                   builder: (context) {
//                     return AlertDialog(
//                       title: Text(
//                         'Delete Product',
//                         style: Theme.of(context).textTheme.titleMedium,
//                       ),
//                       content: Text(
//                         'Are you sure you want to remove the product from your cart?',
//                       ),
//                       actions: [
//                         TextButton(
//                           onPressed: () {
//                             Navigator.pop(context);
//                           },
//                           child: Text(
//                             'No',
//                             style: TextStyle(
//                               color: Colors.blue,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                         TextButton(
//                           onPressed: () {
//                             Provider.of<CartProvider>(
//                               context,
//                               listen: false,
//                             ).removeProduct(
//                               cartItem,
//                             ); // Equivalanet context.read<CartProvider>().removeProduct(cartItem);
//                             Navigator.pop(context);
//                           },
//                           child: Text(
//                             'Yes',
//                             style: TextStyle(
//                               color: Colors.red,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ],
//                     );
//                   },
// )
