import 'package:cloud_firestore/cloud_firestore.dart';

class OrderProduct {
  final String id;
  final String userId;
  final List<Map<String, dynamic>> items;
  final DateTime timestamp;

  OrderProduct({
    required this.id,
    required this.userId,
    required this.items,
    required this.timestamp,
  });

  factory OrderProduct.fromFirestore(String id, Map<String, dynamic> data) {
    return OrderProduct(
      id: id,
      userId: data['userId'],
      items: List<Map<String, dynamic>>.from(data['items']),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}
