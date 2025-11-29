import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class OrdersLineChart extends StatefulWidget {
  const OrdersLineChart({super.key});

  @override
  State<OrdersLineChart> createState() => _OrdersLineChartState();
}

class _OrdersLineChartState extends State<OrdersLineChart> {
  List<int> ordersPerDay = [0, 0, 0, 0, 0, 0, 0];
  List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrdersData();
  }

  Future<void> fetchOrdersData() async {
    try {
      // Get orders from the past 7 days
      final DateTime now = DateTime.now();
      final DateTime sevenDaysAgo = now.subtract(const Duration(days: 7));

      final ordersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('createdAt', isGreaterThanOrEqualTo: sevenDaysAgo)
          .get();

      // Initialize counts for each day
      final List<int> counts = [0, 0, 0, 0, 0, 0, 0];

      // Count orders for each day
      for (var doc in ordersSnapshot.docs) {
        final data = doc.data();
        if (data['createdAt'] != null) {
          final Timestamp timestamp = data['createdAt'] as Timestamp;
          final DateTime orderDate = timestamp.toDate();

          // Get day of week (1 = Monday, 7 = Sunday)
          final int dayOfWeek = orderDate.weekday;

          // Increment count for that day (array is 0-indexed)
          counts[dayOfWeek - 1]++;
        }
      }

      setState(() {
        ordersPerDay = counts;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching orders data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withOpacity(0.15),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.orangeAccent),
        ),
      );
    }

    final maxY = ordersPerDay.isEmpty
        ? 10.0
        : (ordersPerDay.reduce((a, b) => a > b ? a : b) * 1.2).clamp(
            5.0,
            double.infinity,
          );
    const minY = 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withOpacity(0.15),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Orders Per Day (Last 7 Days)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orangeAccent,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 190,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 1,
                      getTitlesWidget: (value, _) {
                        final int index = value.toInt();
                        if (index < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              days[index],
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: (maxY / 5).clamp(1, double.infinity),
                      getTitlesWidget: (value, _) => Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                ),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    color: Colors.orangeAccent,
                    barWidth: 4,
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.orangeAccent.withAlpha(40),
                          Colors.orangeAccent.withAlpha(05),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    dotData: FlDotData(
                      getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                        radius: 5,
                        color: Colors.white,
                        strokeWidth: 3,
                        strokeColor: Colors.orangeAccent,
                      ),
                    ),
                    spots: [
                      for (int i = 0; i < ordersPerDay.length; i++)
                        FlSpot(i.toDouble(), ordersPerDay[i].toDouble()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
