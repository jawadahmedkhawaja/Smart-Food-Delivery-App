import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addDummyUsersToFirestore() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final List<Map<String, dynamic>> dummyUsers = [
    // 5 Customers
    {'userName': 'Ayesha Khan', 'email': 'ayesha.khan@gmail.com', 'role': 'customer'},
    {'userName': 'Ahmed Raza', 'email': 'ahmed.raza@gmail.com', 'role': 'customer'},
    {'userName': 'Sara Malik', 'email': 'sara.malik@gmail.com', 'role': 'customer'},
    {'userName': 'Bilal Ahmed', 'email': 'bilal.ahmed@gmail.com', 'role': 'customer'},
    {'userName': 'Hira Fatima', 'email': 'hira.fatima@gmail.com', 'role': 'customer'},

    // 10 Restaurants
    {'userName': 'Pizza Palace', 'email': 'contact@pizzapalace.com', 'role': 'restaurant'},
    {'userName': 'The Biryani Spot', 'email': 'info@biryanispot.com', 'role': 'restaurant'},
    {'userName': 'Burger Barn', 'email': 'support@burgerbarn.com', 'role': 'restaurant'},
    {'userName': 'Chopstick Express', 'email': 'hello@chopstickexpress.com', 'role': 'restaurant'},
    {'userName': 'Cafe Aroma', 'email': 'care@cafearoma.com', 'role': 'restaurant'},
    {'userName': 'Grill House', 'email': 'info@grillhouse.com', 'role': 'restaurant'},
    {'userName': 'Sweet Treats', 'email': 'orders@sweettreats.com', 'role': 'restaurant'},
    {'userName': 'Spice Hub', 'email': 'contact@spicehub.com', 'role': 'restaurant'},
    {'userName': 'Urban Eatery', 'email': 'urban@eatery.com', 'role': 'restaurant'},
    {'userName': 'Food Fusion', 'email': 'hello@foodfusion.com', 'role': 'restaurant'},

    // 15 Delivery Drivers
    {'userName': 'Zeeshan Ali', 'email': 'zeeshan.ali@gmail.com', 'role': 'delivery'},
    {'userName': 'Kashif Mehmood', 'email': 'kashif.mehmood@gmail.com', 'role': 'delivery'},
    {'userName': 'Umair Khan', 'email': 'umair.khan@gmail.com', 'role': 'delivery'},
    {'userName': 'Noman Qureshi', 'email': 'noman.qureshi@gmail.com', 'role': 'delivery'},
    {'userName': 'Farhan Malik', 'email': 'farhan.malik@gmail.com', 'role': 'delivery'},
    {'userName': 'Adil Hussain', 'email': 'adil.hussain@gmail.com', 'role': 'delivery'},
    {'userName': 'Hamza Tariq', 'email': 'hamza.tariq@gmail.com', 'role': 'delivery'},
    {'userName': 'Usman Javed', 'email': 'usman.javed@gmail.com', 'role': 'delivery'},
    {'userName': 'Saad Iqbal', 'email': 'saad.iqbal@gmail.com', 'role': 'delivery'},
    {'userName': 'Talha Arif', 'email': 'talha.arif@gmail.com', 'role': 'delivery'},
    {'userName': 'Ali Imran', 'email': 'ali.imran@gmail.com', 'role': 'delivery'},
    {'userName': 'Rizwan Khalid', 'email': 'rizwan.khalid@gmail.com', 'role': 'delivery'},
    {'userName': 'Hassan Rafiq', 'email': 'hassan.rafiq@gmail.com', 'role': 'delivery'},
    {'userName': 'Qasim Shah', 'email': 'qasim.shah@gmail.com', 'role': 'delivery'},
    {'userName': 'Fahad Mustafa', 'email': 'fahad.mustafa@gmail.com', 'role': 'delivery'},
  ];

  for (final user in dummyUsers) {
    final docRef = firestore.collection('users').doc();

    await docRef.set({
      'uid': docRef.id,
      'userName': user['userName'],
      'email': user['email'],
      'role': user['role'],
      'isEmailVerified': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  print('✅ Dummy users added successfully!');
}
