import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ecommerce_vkool/data/model/order.dart';


class OrderRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  OrderRepository({required this.firestore, required this.auth});

  Future<List<OrderProduct>> fetchOrders() async {
    final user = auth.currentUser;
    if (user == null) return [];

    final snapshot = await firestore
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => OrderProduct.fromFirestore(doc.id, doc.data()))
        .toList();
  }
}
