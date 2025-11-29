import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../utils/snack_bar.dart';
import 'select_delivery_boy.dart';

class OrdersDetailPage extends StatefulWidget {
  final Map<String, dynamic> order;
  final int index;

  const OrdersDetailPage({
    super.key,
    required this.order,
    required this.index,
  });

  @override
  State<OrdersDetailPage> createState() => _OrdersDetailPageState();
}

class _OrdersDetailPageState extends State<OrdersDetailPage> {
  List options = ['Accepted','Preparing','Ready for Pickup'];
  late String selectedOption;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedOption = widget.order['status'] ?? 'Accepted';
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> fetchStatus() {
    return FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.order['orderId'])
        .snapshots();
  }

  Future<void> changeStatus() async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.order['orderId'])
          .update({'status': selectedOption});

      showSnackBar(context, 'Status Changed Successfully!');

      setState(() {
        widget.order['status'] = selectedOption;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      showSnackBar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.order['items'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Order Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder(
        stream: fetchStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Some Error has Occurred: ${snapshot.error}'),
            );
          }

          final data = snapshot.data?.data();
          final orderStatus = data?['status'] ?? 'Pending';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 80,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${widget.index + 1}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            '${widget.order['customerName'] ?? 'N/A'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Items',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    NetworkImage('${item['imageUrl']}'),
                              ),
                              title: Text('${item['name']}'),
                              subtitle: Text(
                                'Quantity: ${item['quantity']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                orderStatus == 'Cancelled' || orderStatus == 'Delivered'
                    ? const Center(
                        child: Text(
                          'Order Delivered or Cancelled',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      )
                    : const Text(
                        'Update Order Status',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                      ),
                const SizedBox(height: 10),
                if (orderStatus != 'Delivered' && orderStatus != 'Cancelled') ...[

                  for (var i in options)
                  RadioListTile<String>(
                    value: '$i',
                    groupValue: selectedOption,
                    onChanged: (value) {
  setState(() {
    selectedOption = value!;

    if (selectedOption == 'Preparing') {
      options = ['Preparing', 'Ready for Pickup'];
    }

    if (selectedOption == 'Ready for Pickup') {
      options = ['Ready for Pickup'];
      setState(() => isLoading = true);
                              changeStatus();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
        return SelectDeliveryBoy(orderID: widget.order['orderId']);
      }));
    }
  });
},
                    title: Text(
                      '$i',
                      style:
                          const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  
                  
                  const SizedBox(height: 10),
                  Center(
                    child: isLoading
                        ? const CircularProgressIndicator.adaptive()
                        : ElevatedButton.icon(
                            onPressed: () {
                              setState(() => isLoading = true);
                              changeStatus();
                            },
                            icon: const Icon(Icons.update_outlined),
                            label: const Text('Update Status'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                            ),
                          ),
                  ),

                  
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
