
import 'package:flutter/material.dart';

class ItemDetailPage extends StatelessWidget {
  Map<String, dynamic> data;
  ItemDetailPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Item Detail')),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Expanded(
            child: Card(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(data['imageUrl'], width: 500,height: 300,),
                  ),
        
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      data['name'],
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 2,
                    ),
                  ),
        
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      data['description'],
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  Text(
                    'Price \$${data['price']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
