import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_pages/cart_provider.dart';
import 'home_page.dart';
import 'cart_pages/cart_page.dart';
import 'orders_page.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  int currentPage = 0;

  final List<Widget> pages = [const HomePage(), const CartPage(), const OrdersPage()];

  @override
  Widget build(BuildContext context) {
    const Color primaryOrange = Color(0xFFFF8C42);
    const Color background = Color(0xFFF9F9F9);

    return Scaffold(
      backgroundColor: background,

      body: IndexedStack(index: currentPage, children: pages),

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(blurRadius: 8, offset: Offset(0, -2))],
        ),
        child: BottomNavigationBar(
          currentIndex: currentPage,
          onTap: (value) {
            setState(() {
              currentPage = value;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: primaryOrange,
          unselectedItemColor: Colors.grey.shade600,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          iconSize: 28,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                label: Text('${context.watch<CartProvider>().cart.length}'),
                child: const Icon(Icons.shopping_cart_outlined),
              ),
              activeIcon: const Icon(Icons.shopping_cart),
              label: 'Cart',
            ),

            const BottomNavigationBarItem(
              icon: Icon(Icons.delivery_dining_outlined),
              activeIcon: Icon(Icons.delivery_dining),
              label: 'Orders',
            ),
          ],
        ),
      ),
    );
  }
}
