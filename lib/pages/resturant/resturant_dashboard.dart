import 'package:flutter/material.dart';
import '../resturant/orders_page.dart';
import 'home_page.dart';

class ResturantDashboard extends StatefulWidget {
  const ResturantDashboard({super.key});

  @override
  State<ResturantDashboard> createState() => _ResturantDashboardState();
}

class _ResturantDashboardState extends State<ResturantDashboard> {
  int currentPage = 0;
  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [const HomePage(),   const OrdersPage()];
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) {
          setState(() {
            currentPage = value;
          });
        },
        currentIndex: currentPage,
        iconSize: 30,
        unselectedFontSize: 14,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shop_outlined),
            label: 'Orders',
          ),
        ],
      ),
      body: IndexedStack(index: currentPage, children: pages),
    );
  }
}
