import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoleDistributionChart extends StatefulWidget {
  const RoleDistributionChart({super.key});

  @override
  State<RoleDistributionChart> createState() => _RoleDistributionChartState();
}

class _RoleDistributionChartState extends State<RoleDistributionChart> {
  Map<String, double> roleData = {
    'Customers': 0,
    'Restaurants': 0,
    'Delivery': 0,
  };

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRoleData();
  }

  Future<void> fetchRoleData() async {
    final usersRef = FirebaseFirestore.instance.collection('users');

    final customerCount = await usersRef
        .where('role', isEqualTo: 'customer')
        .count()
        .get();
    final restaurantCount = await usersRef
        .where('role', isEqualTo: 'resturant')
        .count()
        .get();
    final deliveryCount = await usersRef
        .where('role', isEqualTo: 'delivery')
        .count()
        .get();

    setState(() {
      roleData = {
        'Customers': (customerCount.count ?? 0).toDouble(),
        'Restaurants': (restaurantCount.count ?? 0).toDouble(),
        'Delivery': (deliveryCount.count ?? 0).toDouble(),
      };
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = roleData.values.fold(0.0, (a, b) => a + b);

    return Container(
      margin: const EdgeInsets.all(5),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withAlpha(15),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.orangeAccent),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Role Distribution',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orangeAccent,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 150,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: roleData.entries.map((entry) {
                        final percentage = total == 0
                            ? 0
                            : (entry.value / total * 100).toStringAsFixed(1);
                        return PieChartSectionData(
                          color: entry.key == 'Customers'
                              ? Colors.redAccent
                              : entry.key == 'Restaurants'
                              ? Colors.orangeAccent
                              : Colors.blueAccent,
                          value: entry.value,
                          title: '$percentage%',
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 20,
                  children: [
                    _buildLegend(Colors.redAccent, 'Customers'),
                    _buildLegend(Colors.orangeAccent, 'Restaurants'),
                    _buildLegend(Colors.blueAccent, 'Delivery'),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black87),
        ),
      ],
    );
  }
}
