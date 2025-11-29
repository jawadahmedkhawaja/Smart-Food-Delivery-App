import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  List<Map<String, dynamic>> cart = [];

  void addItem(Map<String, dynamic> product) {
    // FIND ITEM ALREADY IN CART BY ID
    final index = cart.indexWhere((item) => item['id'] == product['id']);

    if (index != -1) {
      // Item already exists → increase quantity
      cart[index]['quantity'] = (cart[index]['quantity'] ?? 1) + 1;
    } else {
      // New item → add with quantity = 1
      cart.add({
        ...product,
        'quantity': 1,
      });
    }

    notifyListeners();
  }

  void removeItem(Map<String, dynamic> product) {
    cart.removeWhere((item) => item['id'] == product['id']);
    notifyListeners();
  }

  void updateQuantity(Map<String, dynamic> item, int newQuantity) {
    final index = cart.indexWhere((x) => x['id'] == item['id']);
    if (index != -1) {
      cart[index]['quantity'] = newQuantity;
      notifyListeners();
    }
  }

  void clearCart() {
    cart.clear();
    notifyListeners();
  }
}
