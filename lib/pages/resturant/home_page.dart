
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../resources/auth_methods.dart';
import '../../utils/snack_bar.dart';
import 'add_food.dart';
import 'item_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Stream<List<Map<String, dynamic>>> getItems() {
    return FirebaseFirestore.instance
        .collection('foods')
        .where('restaurantId', isEqualTo: AuthMethods().currentUser!.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resturant - Dashboard'),
        centerTitle: false,
        actions: [
          IconButton(
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Expanded(
              child: Card(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      width: double.infinity,
                      height: 60,
                      child: const Card(
                        color: Colors.blueGrey,
                        child: Center(
                          child: Text(
                            'Menu Items',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    StreamBuilder(
                      stream: getItems(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator.adaptive(),
                          );
                        }

                        if (snapshot.hasError) {
                          showSnackBar(context, snapshot.error.toString());
                        }

                        if (!snapshot.hasData) {
                          showSnackBar(context, 'No item to Display');
                        }

                        final data = snapshot.data;

                        return Expanded(
                          child: ListView.builder(
                            itemCount: data!.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return ItemDetailPage(
                                            data: data[index],
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  tileColor: Colors.amber,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(data[index]['imageUrl'])
                                    ),
                                  
                                  title: Text(
                                    data[index]['name'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    data[index]['description'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_forever),
                                    color: Colors.red,
                                    onPressed: () {
                                      FirebaseFirestore.instance
                                          .collection('foods')
                                          .doc(data[index]['id'])
                                          .delete();
                                      showSnackBar(
                                        context,
                                        '${data[index]['name']} deleted Successfully!',
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const AddFood();
                        },
                      ),
                    );
                  },
                  child: const Text('Add Food Item'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
